import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cuk_commit/core/constants/color_constants.dart';
import 'package:cuk_commit/core/constants/text_styles.dart';
import 'package:cuk_commit/core/routes/route_names.dart';
import 'package:cuk_commit/core/widgets/custom_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class RegisterationScreen extends StatefulWidget {
  const RegisterationScreen({super.key});

  @override
  State<RegisterationScreen> createState() => _RegisterationScreenState();
}

class _RegisterationScreenState extends State<RegisterationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameFieldKey = GlobalKey<FormFieldState<String>>();
  final _emailFieldKey = GlobalKey<FormFieldState<String>>();
  final _passwordFieldKey = GlobalKey<FormFieldState<String>>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _agreeToTerms = false;

  bool _isFormValid = false;
  bool _isSubmitting = false;

  static const String _termsUrl =
      'https://cuk-commit.vercel.app/terms_condition.html';
  static const String _privacyUrl =
      'https://cuk-commit.vercel.app/privacy_policy.html';

  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  void initState() {
    super.initState();

    _nameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _passswordController.addListener(_validateForm);

    _validateForm();
  }

  bool _isNameValid(String name) {
    final n = name.trim();
    return n.isNotEmpty && n.length >= 3;
  }

  bool _isEmailValid(String email) {
    final e = email.trim();
    return RegExp(r"^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$").hasMatch(e);
  }

  bool _isPasswordValid(String password) {
    return password.length >= 6;
  }

  void _validateForm() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passswordController.text;

    final valid = _isNameValid(name) &&
        _isEmailValid(email) &&
        _isPasswordValid(password) &&
        _agreeToTerms;

    if (valid != _isFormValid) {
      setState(() => _isFormValid = valid);
    }
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open link")),
      );
    }
  }

  Future<void> _createAccount() async {
    if (_isSubmitting) return;

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    try {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passswordController.text;

      // Supabase SignUp
      final res = await _supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: "com.app.cukcommit://login-callback/",
        data: {"name": name},
      );

      if (res.user == null) {
        throw Exception("Signup failed: user is null");
      }


      if (!mounted) return;

      Navigator.pushNamed(context, RouteNames.verification, arguments: email);
      // // Go to verification screen and pass email
      // Navigator.pushNamed(
      //   context,
      //   RouteNames.verification,
      //   arguments: email,
      // );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed: ${e.message}")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _signUpWithGoogle() async {
    if (_isSubmitting) return;

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please accept Terms & Privacy Policy")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Supabase OAuth (Google)
      await _supabase.auth.signInWithOAuth( 
        OAuthProvider.google,
        redirectTo: "com.app.cukcommit://login-callback/",
      );

      // After OAuth redirect, AuthGate will handle routing
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google signup failed: ${e.message}")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google signup failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // Apple signup placeholder (future implementation)
  // Future implementation requires:
  // - Supabase Apple OAuth enabled
  // - Apple Developer account
  // - iOS capabilities setup (Sign In with Apple)
  // void _signUpWithApple() {}

  @override
  void dispose() {
    _nameController.removeListener(_validateForm);
    _emailController.removeListener(_validateForm);
    _passswordController.removeListener(_validateForm);

    _nameController.dispose();
    _emailController.dispose();
    _passswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : AppColors.textPrimaryLight;

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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // IconButton(
                  //   onPressed: () => Navigator.pop(context),
                  //   icon: Icon(Icons.arrow_back_ios, size: 20, color: textColor),
                  //   padding: EdgeInsets.zero,
                  //   constraints: const BoxConstraints(),
                  // ),
                  const SizedBox(height: 50),

                  Text(
                    "Create Account",
                    style: AppTextStyles.h1Light.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Find your prefect match now",
                    style: AppTextStyles.bodyLargeLight.copyWith(
                      color: isDarkMode
                          ? Colors.grey.shade400
                          : Colors.grey.shade700,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Name
                  TextFormField(
                    key: _nameFieldKey,
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "Full Name",
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: isDarkMode
                            ? AppColors.primary
                            : AppColors.primary.withOpacity(0.7),
                      ),
                    ),
                    style: TextStyle(color: textColor),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onChanged: (_) {
                      _nameFieldKey.currentState?.validate();
                      _validateForm();
                    },
                    validator: (value) {
                      final v = (value ?? '').trim();
                      if (v.isEmpty) return "Name is required";
                      if (v.length < 3) return "Name must be at least 3 characters";
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Email
                  TextFormField(
                    key: _emailFieldKey,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Enter your email",
                      prefixIcon: Icon(
                        Icons.mail_outline_rounded,
                        color: isDarkMode
                            ? AppColors.primary
                            : AppColors.primary.withOpacity(0.7),
                      ),
                    ),
                    style: TextStyle(color: textColor),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onChanged: (_) {
                      _emailFieldKey.currentState?.validate();
                      _validateForm();
                    },
                    validator: (value) {
                      final v = (value ?? '').trim();
                      if (v.isEmpty) return "Email is required";
                      if (!_isEmailValid(v)) return "Enter a valid email";
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Password
                  TextFormField(
                    key: _passwordFieldKey,
                    controller: _passswordController,
                    obscureText: !_isPasswordVisible,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      labelText: "Enter your password",
                      prefixIcon: Icon(
                        Icons.lock_outline_rounded,
                        color: isDarkMode
                            ? AppColors.primary
                            : AppColors.primary.withOpacity(0.7),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: isDarkMode
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    style: TextStyle(color: textColor),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onChanged: (_) {
                      _passwordFieldKey.currentState?.validate();
                      _validateForm();
                    },
                    validator: (value) {
                      final v = value ?? '';
                      if (v.isEmpty) return "Password is required";
                      if (v.length < 6) return "Password must be at least 6 characters";
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Terms checkbox
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _agreeToTerms,
                          onChanged: (value) {
                            setState(() {
                              _agreeToTerms = value ?? false;
                            });
                            _validateForm();
                          },
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade700,
                              fontSize: 14,
                            ),
                            children: [
                              const TextSpan(
                                text: "By creating an account, you agree to our ",
                              ),
                              TextSpan(
                                text: "Terms of Service",
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => _openLink(_termsUrl),
                              ),
                              const TextSpan(text: " and "),
                              TextSpan(
                                text: "Privacy Policy",
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => _openLink(_privacyUrl),
                              ),
                              const TextSpan(text: "."),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  CustomButton(
                    text: "Create Account",
                    isLoading: _isSubmitting,
                    onPressed: (_isFormValid && !_isSubmitting) ? _createAccount : null,
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: isDarkMode
                              ? Colors.grey.shade800
                              : Colors.grey.shade300,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "Or sign up with",
                          style: AppTextStyles.bodyLargeLight.copyWith(
                            color: isDarkMode
                                ? Colors.grey.shade400
                                : Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: isDarkMode
                              ? Colors.grey.shade800
                              : Colors.grey.shade300,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _socialSignUpButton(
                        icon: Icons.g_mobiledata_rounded,
                        color: isDarkMode ? Colors.white : Colors.black,
                        onPressed: _signUpWithGoogle,
                        isDarkMode: isDarkMode,
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyle(
                          color: isDarkMode
                              ? Colors.grey.shade400
                              : Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, RouteNames.login);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: Text(
                          "Sign In",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialSignUpButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required bool isDarkMode,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.grey.shade800.withOpacity(0.5)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 32),
      ),
    );
  }
}
