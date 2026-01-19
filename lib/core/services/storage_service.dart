import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  static final _supabase = Supabase.instance.client;

  static Future<String> uploadUserPhoto({
    required File file,
    required int index,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception("Not logged in");

    final path = "${user.id}/$index.jpg";

    await _supabase.storage
        .from("user_photos")
        .upload(
          path,
          file,
          fileOptions: const FileOptions(
            cacheControl: "3600",
            upsert: true,
          ),
        );

    // signed URL OR public URL (we keep private, so signed)
    final signedUrl = await _supabase.storage
        .from("user_photos")
        .createSignedUrl(path, 60 * 60 * 24); // 24h

    return signedUrl;
  }

  static Future<void> deleteUserPhoto({
    required int index,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception("Not logged in");

    final path = "${user.id}/$index.jpg";

    await _supabase.storage.from("user_photos").remove([path]);
  }
}
