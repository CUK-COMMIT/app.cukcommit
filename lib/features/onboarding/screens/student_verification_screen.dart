import 'dart:async';
import 'dart:io';

import 'package:cuk_commit/core/constants/color_constants.dart';
import 'package:cuk_commit/core/routes/route_names.dart';
import 'package:cuk_commit/features/onboarding/providers/onboarding_provider.dart';
import 'package:cuk_commit/features/onboarding/repositories/onboarding_repository.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

class StudentVerificationScreen extends StatefulWidget {
  const StudentVerificationScreen({super.key});

  @override
  State<StudentVerificationScreen> createState() =>
      _StudentVerificationScreenState();
}

class _StudentVerificationScreenState extends State<StudentVerificationScreen> {
  final _repo = OnboardingRepository();
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  File? _idImageFile;

  final TextEditingController _rollNoController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();

  String? _year;
  String? _program;

  bool _processing = false;
  bool _checkingRollExists = false;
  bool _rollAlreadyExists = false;

  final List<String> _years = const ["1st", "2nd", "3rd", "4th", "5th"];
  final List<String> _programs = const ["UG", "PG", "PhD"];

  // Examples:
  // 23UMATH002
  // 21UCSE001
  final RegExp _strictIdReg = RegExp(r'^\d{2}U[A-Z]{3,6}\d{3}$');

  @override
  void initState() {
    super.initState();
    _departmentController.addListener(_refresh);
  }

  @override
  void dispose() {
    _rollNoController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  bool get _isFormFilled =>
      (_rollNoController.text.trim().isNotEmpty) &&
      (_departmentController.text.trim().isNotEmpty) &&
      (_year != null) &&
      (_program != null) &&
      (_idImageFile != null) &&
      !_processing &&
      !_checkingRollExists &&
      !_rollAlreadyExists;

  Future<void> _pickIdImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 92,
    );
    if (picked == null) return;

    setState(() {
      _idImageFile = File(picked.path);
      _rollNoController.text = "";
      _rollAlreadyExists = false;
    });

    await _processIdCard();
  }

  Future<void> _processIdCard() async {
    if (_idImageFile == null) return;

    setState(() {
      _processing = true;
      _checkingRollExists = false;
      _rollAlreadyExists = false;
    });

    try {
      final file = _idImageFile!;
      final inputImage = InputImage.fromFile(file);

      // 1) barcode scan first (Code128)
      final barcodeRoll = await _scanBarcodeRoll(inputImage);
      if (barcodeRoll != null) {
        _rollNoController.text = barcodeRoll;
      } else {
        // 2) fallback OCR
        final ocrRoll = await _scanOcrRoll(inputImage);
        if (ocrRoll != null) {
          _rollNoController.text = ocrRoll;
        }
      }

      // validate strict
      final roll = _rollNoController.text.trim().toUpperCase();
      if (roll.isEmpty || !_strictIdReg.hasMatch(roll)) {
        _rollNoController.text = "";
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Roll number not detected. Try a clearer ID photo."),
          ),
        );
        return;
      }

      // 3) check if roll exists
      await _checkRollAlreadyExists(roll);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("ID processing failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<String?> _scanBarcodeRoll(InputImage inputImage) async {
    try {
      final scanner = BarcodeScanner(formats: [BarcodeFormat.code128]);
      final barcodes = await scanner.processImage(inputImage);
      await scanner.close();

      for (final b in barcodes) {
        final raw = (b.rawValue ?? "").trim().toUpperCase();
        if (raw.isEmpty) continue;

        final cleaned = raw.replaceAll(RegExp(r'\s+'), '');

        if (_strictIdReg.hasMatch(cleaned)) {
          return cleaned;
        }
      }
    } catch (_) {
      // ignore barcode errors
    }
    return null;
  }

  Future<String?> _scanOcrRoll(InputImage inputImage) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final recognizedText = await textRecognizer.processImage(inputImage);

      // ignore: avoid_print
      print("OCR TEXT:\n${recognizedText.text}");

      final extracted = _extractCandidateIdFromText(recognizedText.text);

      // ignore: avoid_print
      print("EXTRACTED ROLL: $extracted");

      if (extracted.isEmpty) return null;
      if (_strictIdReg.hasMatch(extracted)) return extracted;

      return null;
    } finally {
      await textRecognizer.close();
    }
  }

  String _extractCandidateIdFromText(String text) {
    final up = text.toUpperCase();

    final candidates = <String>[];

    final matches = RegExp(r'[0-9A-Z]{8,14}').allMatches(up);
    for (final m in matches) {
      final s = (m.group(0) ?? "").trim();
      if (s.isNotEmpty) candidates.add(s);
    }

    candidates.add(up.replaceAll(RegExp(r'\s+'), ''));

    for (final c in candidates) {
      final cleaned = _normalizeOcrId(c);

      final match = _strictIdReg.firstMatch(cleaned);
      if (match != null) return match.group(0)!;

      final subMatch = RegExp(r'\d{2}U[A-Z]{3,6}\d{3}').firstMatch(cleaned);
      if (subMatch != null) {
        final sub = subMatch.group(0)!;
        if (_strictIdReg.hasMatch(sub)) return sub;
      }
    }

    return "";
  }

  String _normalizeOcrId(String input) {
    var s = input.toUpperCase();

    s = s.replaceAll(RegExp(r'[^0-9A-Z]'), '');
    s = s.replaceAll(' ', '');

    if (s.length >= 3) {
      final head = s.substring(0, s.length - 3);
      var tail = s.substring(s.length - 3);

      tail = tail
          .replaceAll('O', '0')
          .replaceAll('I', '1')
          .replaceAll('L', '1')
          .replaceAll('S', '5')
          .replaceAll('B', '8');

      s = head + tail;
    }

    s = s.replaceAllMapped(RegExp(r'(?<=\d)O|O(?=\d)'), (m) => '0');

    return s;
  }

  Future<void> _checkRollAlreadyExists(String rollNo) async {
    setState(() {
      _checkingRollExists = true;
      _rollAlreadyExists = false;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final res = await Supabase.instance.client
          .from("profiles")
          .select("id")
          .eq("roll_no", rollNo)
          .neq("id", user.id)
          .maybeSingle();

      if (res != null) {
        setState(() => _rollAlreadyExists = true);

        if (!mounted) return;
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: const Text(
        //       "This roll number is already registered.",
        //     ),
        //     action: SnackBarAction(
        //       label: "Report",
        //       onPressed: _reportIdTheft,
        //     ),
        //   ),
        // );
      }
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => _checkingRollExists = false);
    }
  }

  Future<void> _submit() async {
    if (_processing || _checkingRollExists) return;
    if (!_isFormFilled) return;

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final provider = context.read<OnboardingProvider>();

    try {
      setState(() => _processing = true);

      final roll = _rollNoController.text.trim().toUpperCase();
      final dept = _departmentController.text.trim();
      final year = _year!;
      final program = _program!;
      final idFile = _idImageFile!;

      // extra safety: recheck before insert (race condition protection)
      await _checkRollAlreadyExists(roll);
      if (_rollAlreadyExists) return;

      // upload ID photo
      final idUrl = await provider.uploadStudentIdPhoto(file: idFile);

      // save student verification info
      await _repo.saveStudentVerification(
        rollNo: roll,
        department: dept,
        year: year,
        program: program,
        idPhotoUrl: idUrl,
      );

      await _repo.markStudentVerificationSubmitted();

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        RouteNames.authGate,
        (route) => false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Student verification submitted")),
      );
    } on PostgrestException catch (e) {
      //  IMPORTANT: capture duplicate roll error
      if (e.code == "23505" ||
          (e.message.toLowerCase().contains("duplicate") &&
              e.message.toLowerCase().contains("roll"))) {
        setState(() => _rollAlreadyExists = true);

        if (!mounted) return;
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: const Text("This roll number is already registered."),
        //     action: SnackBarAction(
        //       label: "Report",
        //       onPressed: _reportIdTheft,
        //     ),
        //   ),
        // );
        return;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Submit failed: ${e.message}")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Submit failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  void _reportIdTheft() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Report ID Theft"),
        content: Text(
          "Email cukcommit@gmail.com with:\n\n"
          "- Your roll number: ${_rollNoController.text.trim().toUpperCase()}\n"
          "- Screenshot of this screen\n"
          "- Your student ID photo\n\n"
          "Subject: ID Theft Report",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : Colors.white,
      appBar: AppBar(
        title: const Text("Student Verification"),
        backgroundColor: isDarkMode ? AppColors.cardDark : AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Form(
            key: _formKey,
            onChanged: _refresh,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Upload your CUK ID card",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: isDarkMode
                        ? Colors.grey.shade900.withOpacity(0.35)
                        : Colors.grey.shade100,
                    border: Border.all(
                      color: isDarkMode
                          ? Colors.grey.shade800
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Column(
                    children: [
                      if (_idImageFile != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(
                            _idImageFile!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Container(
                          height: 180,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.badge_outlined,
                            size: 60,
                            color: isDarkMode
                                ? Colors.grey.shade500
                                : Colors.grey.shade700,
                          ),
                        ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _processing
                                  ? null
                                  : () => _pickIdImage(ImageSource.camera),
                              icon: const Icon(Icons.camera_alt_outlined),
                              label: const Text("Camera"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _processing
                                  ? null
                                  : () => _pickIdImage(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library_outlined),
                              label: const Text("Gallery"),
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                    isDarkMode ? Colors.white : Colors.black,
                                side: BorderSide(
                                  color: isDarkMode
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade400,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (_processing) ...[
                        const SizedBox(height: 12),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Processing ID...",
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                TextFormField(
                  controller: _rollNoController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Roll Number",
                    prefixIcon: const Icon(Icons.card_membership_rounded),
                    filled: true,
                    fillColor: isDarkMode
                        ? Colors.grey.shade900.withOpacity(0.35)
                        : Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                if (_rollAlreadyExists) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "This roll number is already registered.",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: _reportIdTheft,
                          icon: const Icon(Icons.report_gmailerrorred),
                          label: const Text("Report ID theft"),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 14),

                TextFormField(
                  controller: _departmentController,
                  decoration: InputDecoration(
                    labelText: "Department",
                    hintText: "e.g. Mathematics",
                    prefixIcon: const Icon(Icons.account_balance_outlined),
                    filled: true,
                    fillColor: isDarkMode
                        ? Colors.grey.shade900.withOpacity(0.35)
                        : Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) {
                    if ((v ?? "").trim().isEmpty) return "Department required";
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                DropdownButtonFormField<String>(
                  initialValue: _year,
                  items: _years
                      .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                      .toList(),
                  onChanged: _processing ? null : (v) => setState(() => _year = v),
                  decoration: InputDecoration(
                    labelText: "Year",
                    prefixIcon: const Icon(Icons.school_outlined),
                    filled: true,
                    fillColor: isDarkMode
                        ? Colors.grey.shade900.withOpacity(0.35)
                        : Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) => v == null ? "Select year" : null,
                ),

                const SizedBox(height: 14),

                DropdownButtonFormField<String>(
                  initialValue: _program,
                  items: _programs
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged:
                      _processing ? null : (v) => setState(() => _program = v),
                  decoration: InputDecoration(
                    labelText: "Program",
                    prefixIcon: const Icon(Icons.workspace_premium_outlined),
                    filled: true,
                    fillColor: isDarkMode
                        ? Colors.grey.shade900.withOpacity(0.35)
                        : Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) => v == null ? "Select program" : null,
                ),

                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isFormFilled ? _submit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _processing ? "Submitting..." : "Submit Verification",
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
