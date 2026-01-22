import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cuk_commit/core/constants/color_constants.dart';
import 'package:cuk_commit/core/constants/text_styles.dart';
// import 'package:cuk_commit/core/routes/route_names.dart';
import 'package:cuk_commit/core/widgets/custom_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({
    super.key,
    this.email,
  });

  final String? email;

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  bool _isResending = false;

  // resend cooldown
  Timer? _resendCooldownTimer;
  int _resendCooldownSeconds = 0;

  @override
  void initState() {
    super.initState();
    _startResendCooldown(50);
  }

  @override
  void dispose() {
    _resendCooldownTimer?.cancel();
    super.dispose();
  }

  void _startResendCooldown([int seconds = 50]) {
    _resendCooldownTimer?.cancel();
    _resendCooldownSeconds = seconds;

    _resendCooldownTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        if (_resendCooldownSeconds > 0) {
          _resendCooldownSeconds--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  String _errorToMessage(Object e) {
    if (e is AuthException) return e.message;
    return e.toString();
  }

  Future<void> _resendVerificationEmail() async {
    if (_isResending) return;
    if (_resendCooldownSeconds > 0) return;

    final email = (widget.email ?? '').trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email missing for resend.")),
      );
      return;
    }

    setState(() => _isResending = true);

    try {
      final supabase = Supabase.instance.client;

      await supabase.auth.resend(
        type: OtpType.signup,
        email: email,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Verification email sent again.")),
      );

      _startResendCooldown(50);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to resend: ${_errorToMessage(e)}")),
      );
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  // void _continueToProfileCreation() {
  //   // IMPORTANT:
  //   // Supabase does NOT automatically log the user in after email verification.
  //   // You can still send them to onboarding UI, but upload/profile save will fail without session.
  //   // Best: redirect onboarding -> it can show "please login" if session missing.

  //   Navigator.pushNamedAndRemoveUntil(
  //     context,
  //     RouteNames.onboarding,
  //     (route) => false,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : AppColors.textPrimaryLight;

    final resendDisabled = _isResending || _resendCooldownSeconds > 0;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.3],
            colors: isDarkMode
                ? [AppColors.cardDark, AppColors.backgroundDark]
                : [Colors.white, Colors.grey.shade50],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: textColor, size: 20),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),

                const SizedBox(height: 24),

                Text(
                  'Verify your email',
                  style: AppTextStyles.h1Light.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  "We sent a verification link to your email.\n\nAfter verifying, verify your email to set up your profile.",
                  style: AppTextStyles.bodyMediumLight.copyWith(
                    color:
                        isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                  ),
                ),

                const SizedBox(height: 16),

                if ((widget.email ?? '').trim().isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.grey.shade900.withOpacity(0.35)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDarkMode
                            ? Colors.grey.shade800
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.email_outlined,
                            color: AppColors.primary.withOpacity(0.95)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.email!.trim(),
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.grey.shade200
                                  : Colors.grey.shade800,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 32),

                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mark_email_read_outlined,
                      size: 58,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // CustomButton(
                //   text: "Continue",
                //   onPressed: _continueToProfileCreation,
                // ),

                const SizedBox(height: 12),

                CustomButton(
                  text: resendDisabled
                      ? (_resendCooldownSeconds > 0
                          ? "Resend in $_resendCooldownSeconds s"
                          : "Sending...")
                      : "Resend Verification Email",
                  type: ButtonType.secondary,
                  onPressed: resendDisabled ? null : _resendVerificationEmail,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
