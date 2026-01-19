import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:cuk_commit/core/constants/color_constants.dart';
import 'package:cuk_commit/core/routes/route_names.dart';

class SigningInScreen extends StatefulWidget {
  const SigningInScreen({super.key});

  @override
  State<SigningInScreen> createState() => _SigningInScreenState();
}

class _SigningInScreenState extends State<SigningInScreen>
    with WidgetsBindingObserver {
  Timer? _timer;
  bool _routing = false;
  int _ticks = 0;

  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // start polling as soon as screen is shown
    _startPolling();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  // When app resumes from browser -> check session immediately
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAndRouteNow();
    }
  }

  void _startPolling() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(milliseconds: 700), (_) async {
      _ticks++;

      await _checkAndRouteNow();

      // Timeout: ~20 seconds
      if (_ticks > 28 && mounted && !_routing) {
        _timer?.cancel();
        _timer = null;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login timeout. Please try again.")),
        );

        Navigator.pop(context);
      }
    });
  }

  Future<void> _checkAndRouteNow() async {
    if (!mounted || _routing) return;

    final session = _supabase.auth.currentSession;
    final user = _supabase.auth.currentUser;

    if (session == null && user == null) return;

    _routing = true;

    if (!mounted) return;

    // Important: route after frame to avoid !_debugLocked
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        RouteNames.authGate,
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 34,
                height: 34,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Signing you in...",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                "Please wait a moment",
                style: TextStyle(
                  fontSize: 13,
                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () async {
                  _timer?.cancel();
                  _timer = null;

                  // optional safety: if user wants to cancel OAuth
                  // await _supabase.auth.signOut();

                  if (!mounted) return;
                  Navigator.pop(context);
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
