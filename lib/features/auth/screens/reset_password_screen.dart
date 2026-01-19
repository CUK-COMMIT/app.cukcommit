import 'package:flutter/material.dart';
import 'package:cuk_commit/core/constants/color_constants.dart';
import 'package:cuk_commit/core/constants/text_styles.dart';
import 'package:cuk_commit/core/routes/route_names.dart';
import 'package:cuk_commit/core/widgets/custom_button.dart';
import 'package:cuk_commit/core/widgets/custom_text_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  bool _isSubmitting = false;

  SupabaseClient get _supabase => Supabase.instance.client;

  bool _isPasswordValid(String password) => password.length >= 6;

  Future<void> _resetPassword() async {
    if (_isSubmitting) return;

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    try {
      final password = _passwordController.text.trim();

      //  Works ONLY if user opened the recovery link (passwordRecovery event)
      await _supabase.auth.updateUser(
        UserAttributes(password: password),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(" Password updated successfully")),
      );

      //  Recommended: logout after reset to avoid routing issues
      await _supabase.auth.signOut();

      if (!mounted) return;

      //  Go cleanly to login (remove all previous screens)
      Navigator.of(context).pushNamedAndRemoveUntil(
        RouteNames.login,
        (route) => false,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Reset failed: ${e.message}")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Reset failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }


  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : AppColors.textPrimaryLight;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reset Password"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [AppColors.cardDark, AppColors.backgroundDark]
                : [Colors.white, Colors.grey.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.35],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_reset_rounded,
                        color: AppColors.primary,
                        size: 40,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    "Create a new password",
                    style: AppTextStyles.h1Light.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Your new password must be at least 6 characters long.",
                    style: AppTextStyles.bodyMediumLight.copyWith(
                      color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Password
                  CustomTextField(
                    controller: _passwordController,
                    labelText: "New Password",
                    hintText: "Enter new password",
                    keyboardType: TextInputType.visiblePassword,
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: !_isPasswordVisible,
                    validator: (value) {
                      final v = value ?? '';
                      if (v.isEmpty) return "Password is required";
                      if (!_isPasswordValid(v)) return "Must be at least 6 characters";
                      return null;
                    },
                    suffix: IconButton(
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                        color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                        size: 20,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Confirm Password
                  CustomTextField(
                    controller: _confirmPasswordController,
                    labelText: "Confirm Password",
                    hintText: "Re-enter new password",
                    keyboardType: TextInputType.visiblePassword,
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: !_isConfirmPasswordVisible,
                    validator: (value) {
                      final v = value ?? '';
                      if (v.isEmpty) return "Confirm password is required";
                      if (v != _passwordController.text) return "Passwords do not match";
                      return null;
                    },
                    suffix: IconButton(
                      onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                      icon: Icon(
                        _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                        color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                        size: 20,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  CustomButton(
                    text: "Update Password",
                    isLoading: _isSubmitting,
                    onPressed: _isSubmitting ? null : _resetPassword,
                  ),

                  const SizedBox(height: 16),

                  Center(
                    child: Text(
                      "If the link expired, request a new reset email.",
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
