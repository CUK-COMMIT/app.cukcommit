import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService {
  //  MUST MATCH Supabase bucket name EXACTLY
  static const String bucket = "user_photo";

  static final SupabaseClient _client = Supabase.instance.client;

  /// Keep in sync with OnboardingProvider.maxPhotos
  static const int maxSlots = 6;

  // ----------------------------
  // Path helpers
  // ----------------------------

  ///  Slot based path:
  /// users/<uid>/photos/slot_<index>.<ext>
  static String slotObjectPath({
    required String uid,
    required int slotIndex,
    String ext = ".jpg",
  }) {
    return "users/$uid/photos/slot_$slotIndex$ext";
  }

  static void _validateSlot(int slotIndex) {
    if (slotIndex < 0 || slotIndex >= maxSlots) {
      throw Exception(
        "Invalid slotIndex: $slotIndex (expected 0..${maxSlots - 1})",
      );
    }
  }

  /// Normalize common extensions
  static String _safeExt(File file) {
    final ext = p.extension(file.path).toLowerCase();

    if (ext.isEmpty) return ".jpg";
    if (ext == ".jpeg") return ".jpg";

    // iOS sometimes produces HEIC
    if (ext == ".heic") return ".jpg";

    return ext;
  }

  static String _cacheBust(String url) {
    final v = DateTime.now().millisecondsSinceEpoch;
    return url.contains("?") ? "$url&v=$v" : "$url?v=$v";
  }

  // ----------------------------
  // Upload
  // ----------------------------

  /// Uploads slot-based photo and returns PUBLIC URL.
  /// ⚠️ Works only if bucket is PUBLIC.
  static Future<String> uploadUserPhotoPublic({
    required File file,
    required String uid,
    required int slotIndex,
  }) async {
    _validateSlot(slotIndex);

    final ext = _safeExt(file);
    final objectPath = slotObjectPath(uid: uid, slotIndex: slotIndex, ext: ext);

    await _client.storage.from(bucket).upload(
          objectPath,
          file,
          fileOptions: const FileOptions(
            upsert: true,
            cacheControl: "3600",
          ),
        );

    final baseUrl = _client.storage.from(bucket).getPublicUrl(objectPath);
    return _cacheBust(baseUrl);
  }

  /// Upload and return SIGNED URL (for private bucket)
  static Future<String> uploadUserPhotoSigned({
    required File file,
    required String uid,
    required int slotIndex,
    int expiresInSeconds = 60 * 60, // 1 hour
  }) async {
    _validateSlot(slotIndex);

    final ext = _safeExt(file);
    final objectPath = slotObjectPath(uid: uid, slotIndex: slotIndex, ext: ext);

    await _client.storage.from(bucket).upload(
          objectPath,
          file,
          fileOptions: const FileOptions(
            upsert: true,
            cacheControl: "3600",
          ),
        );

    final signedUrl = await _client.storage.from(bucket).createSignedUrl(
          objectPath,
          expiresInSeconds,
        );

    return _cacheBust(signedUrl);
  }

  // ----------------------------
  // Delete
  // ----------------------------

  /// Delete photo for a slot.
  /// We try multiple extensions to avoid mismatch issues.
  static Future<void> deleteUserPhotoBySlot({
    required String uid,
    required int slotIndex,
  }) async {
    _validateSlot(slotIndex);

    final folder = "users/$uid/photos";

    final possiblePaths = [
      "$folder/slot_$slotIndex.jpg",
      "$folder/slot_$slotIndex.png",
      "$folder/slot_$slotIndex.webp",
    ];

    await _client.storage.from(bucket).remove(possiblePaths);
  }

  /// Legacy: delete using public url parsing.
  /// Keep ONLY if you stored full urls previously.
  static Future<void> deleteUserPhotoByUrl({
    required String publicUrl,
  }) async {
    final uri = Uri.parse(publicUrl);
    final segments = uri.pathSegments;

    // Example public url:
    // https://xyz.supabase.co/storage/v1/object/public/user_photo/users/<uid>/photos/slot_0.jpg
    final bucketIndex = segments.indexOf(bucket);
    if (bucketIndex == -1 || bucketIndex + 1 >= segments.length) return;

    final objectPath = segments.sublist(bucketIndex + 1).join("/");
    await _client.storage.from(bucket).remove([objectPath]);
  }

  // ----------------------------
  // Fetch photos
  // ----------------------------

  /// Returns public URLs for all slots (0..5) if object exists.
  /// ⚠️ Works only if bucket is PUBLIC.
  static Future<List<String?>> getUserPhotoSlotsPublic({
    required String uid,
  }) async {
    final List<String?> slots = List<String?>.filled(maxSlots, null);

    final folder = "users/$uid/photos";
    final objects = await _client.storage.from(bucket).list(path: folder);

    for (final o in objects) {
      final name = o.name; // slot_0.jpg
      final match = RegExp(r'^slot_(\d+)\.(jpg|png|webp)$').firstMatch(name);
      if (match == null) continue;

      final idx = int.tryParse(match.group(1) ?? "");
      if (idx == null || idx < 0 || idx >= maxSlots) continue;

      final objectPath = "$folder/$name";
      final url = _client.storage.from(bucket).getPublicUrl(objectPath);

      slots[idx] = _cacheBust(url);
    }

    return slots;
  }

  /// Returns signed URLs for all slots (private bucket).
  static Future<List<String?>> getUserPhotoSlotsSigned({
    required String uid,
    int expiresInSeconds = 60 * 60, // 1 hour
  }) async {
    final List<String?> slots = List<String?>.filled(maxSlots, null);

    final folder = "users/$uid/photos";
    final objects = await _client.storage.from(bucket).list(path: folder);

    for (final o in objects) {
      final name = o.name;
      final match = RegExp(r'^slot_(\d+)\.(jpg|png|webp)$').firstMatch(name);
      if (match == null) continue;

      final idx = int.tryParse(match.group(1) ?? "");
      if (idx == null || idx < 0 || idx >= maxSlots) continue;

      final objectPath = "$folder/$name";

      final signedUrl = await _client.storage.from(bucket).createSignedUrl(
            objectPath,
            expiresInSeconds,
          );

      slots[idx] = _cacheBust(signedUrl);
    }

    return slots;
  }

  static Future<String> uploadStudentIdSigned({
    required File file,
    required String uid,
  }) async {
    final supabase = Supabase.instance.client;

    // different folder, not slot based
    final ext = file.path.split('.').last;
    final path = "users/$uid/student_verification/id_card.$ext";

    await supabase.storage.from("user_photo").upload(
          path,
          file,
          fileOptions: const FileOptions(upsert: true),
        );

    final signedUrl = await supabase.storage
        .from("user_photo")
        .createSignedUrl(path, 60 * 60 * 24 * 365); // 1 year

    return signedUrl;
  }


    static Future<void> deleteStudentId({
    required String uid,
  }) async {
    final folder = "users/$uid/student_verification";

    await _client.storage.from(bucket).remove([
      "$folder/id_card.jpg",
      "$folder/id_card.png",
      "$folder/id_card.webp",
    ]);
  }


  // ----------------------------
  // Helpers (recommended for new policies)
  // ----------------------------

  /// Use this to generate the canonical storage path in your provider/repository.
  /// This ensures it always matches the policy:
  /// bucket: user_photo
  /// folder: users/<uid>/...
  static String getUserFolder({
    required String uid,
  }) {
    return "users/$uid";
  }

  /// Strict check: does slot object name match expected naming.
  static bool isSlotFileName(String name) {
    return RegExp(r'^slot_(\d+)\.(jpg|png|webp)$').hasMatch(name);
  }
}
