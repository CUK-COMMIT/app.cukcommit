import 'package:flutter/material.dart';
import 'package:cuk_commit/core/constants/color_constants.dart';
import 'package:cuk_commit/core/constants/text_styles.dart';
import 'package:cuk_commit/core/routes/route_names.dart';
import 'package:cuk_commit/core/widgets/custom_button.dart';
import 'package:cuk_commit/core/widgets/custom_text_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailFieldKey = GlobalKey<FormFieldState<String>>();
  final _passwordFieldKey = GlobalKey<FormFieldState<String>>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isFormValid = false;
  bool _isSubmitting = false;

  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  void initState() {
    super.initState();

    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _validateForm();
  }

  bool _isEmailValid(String email) {
    final e = email.trim();
    return RegExp(r"^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$").hasMatch(e);
  }

  bool _isPasswordValid(String password) {
    return password.length >= 6;
  }

  void _validateForm() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final valid = _isEmailValid(email) && _isPasswordValid(password);

    if (valid != _isFormValid) {
      setState(() => _isFormValid = valid);
    }
  }

  Future<void> _login() async {
    if (_isSubmitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      //  Go to signing-in loader screen
      // Navigator.pushNamed(context, RouteNames.signingIn);
      Navigator.pushNamedAndRemoveUntil(
        context,
        RouteNames.authGate,
        (route) => false,
      );

    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: ${e.message}")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: "com.app.cukcommit://login-callback/",
      );

      if (!mounted) return;

      //  Go to signing-in loader screen
      // Navigator.pushNamed(context, RouteNames.signingIn);
      // Navigator.pushNamedAndRemoveUntil(
      //   context,
      //   RouteNames.authGate,
      //   (route) => false,
      // );


    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google sign-in failed: ${e.message}")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google sign-in failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateForm);
    _passwordController.removeListener(_validateForm);

    _emailController.dispose();
    _passwordController.dispose();
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
            colors: isDarkMode
                ? [AppColors.cardDark, AppColors.backgroundDark]
                : [Colors.white, Colors.grey.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.3],
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
                  const SizedBox(height: 12),

                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: AppColors.primary,
                        size: 40,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Text(
                    'Welcome Back',
                    style: AppTextStyles.h1Light.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Sign in to continue your journey',
                    style: AppTextStyles.bodyMediumLight.copyWith(
                      color:
                          isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Email
                  CustomTextField(
                    key: _emailFieldKey,
                    controller: _emailController,
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
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
                  CustomTextField(
                    key: _passwordFieldKey,
                    controller: _passwordController,
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    keyboardType: TextInputType.visiblePassword,
                    prefixIcon: Icons.lock_outlined,
                    obscureText: !_isPasswordVisible,
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
                    suffix: IconButton(
                      onPressed: () {
                        setState(() => _isPasswordVisible = !_isPasswordVisible);
                      },
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: isDarkMode
                            ? Colors.grey.shade400
                            : Colors.grey.shade700,
                        size: 20,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Forgot password left aligned
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CustomButton(
                      text: "Forgot Password?",
                      type: ButtonType.text,
                      isFullWidth: false,
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.pushNamed(
                                context,
                                RouteNames.forgotPassword,
                              ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  CustomButton(
                    text: "Login",
                    isLoading: _isSubmitting,
                    onPressed: (_isFormValid && !_isSubmitting) ? _login : null,
                  ),

                  const SizedBox(height: 24),

                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: isDarkMode
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Or continue with',
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: isDarkMode
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300,
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _socialLoginButton(
                            icon: Icons.g_mobiledata_rounded,
                            color: isDarkMode ? Colors.white : Colors.black,
                            onPressed: _isSubmitting ? () {} : _loginWithGoogle,
                            isDarkMode: isDarkMode,
                          ),
                          const SizedBox(width: 20),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: TextStyle(
                          color: isDarkMode
                              ? Colors.grey.shade400
                              : Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.pushNamed(context, RouteNames.signup),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: const Text(
                          "Sign up",
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

  Widget _socialLoginButton({
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
