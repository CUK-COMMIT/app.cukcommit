import 'dart:async';

import 'package:cuk_commit/features/onboarding/screens/interests_screen.dart';
import 'package:cuk_commit/features/onboarding/screens/photo_upload_screen.dart';
import 'package:cuk_commit/features/onboarding/screens/student_verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:cuk_commit/core/routes/route_names.dart';
import 'package:cuk_commit/features/auth/screens/login_screen.dart';
import 'package:cuk_commit/features/matching/screens/discover_screen.dart';
import 'package:cuk_commit/features/onboarding/screens/profile_setup_screen.dart';
import 'package:cuk_commit/features/onboarding/repositories/onboarding_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _repo = OnboardingRepository();

  bool _loading = true;
  String? _routeTo; // RouteNames.discover / onboarding / login
  late final StreamSubscription<AuthState> _sub;

  @override
  void initState() {
    super.initState();

    _decide();

    _sub = Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      if (!mounted) return;
      setState(() => _loading = true);
      _decide();
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  Future<void> _decide() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        _routeTo = RouteNames.login;
      } else {
        final state = await _repo.getOnboardingState();

        if (state == null) {
          _routeTo = RouteNames.onboarding;
        } else {
          final bool done = (state["is_profile_completed"] ?? false) == true;
          final int step = (state["onboarding_step"] ?? 0) as int;

          if (done || step >= 4) {
            _routeTo = RouteNames.discover;
          } else {
            // Resume onboarding
            if (step == 0) _routeTo = RouteNames.onboarding;
            if (step == 1) _routeTo = RouteNames.photoUpload;
            if (step == 2) _routeTo = RouteNames.interests;
            if (step == 3) _routeTo = RouteNames.studentVerification;
          }
        }
      }
    } catch (_) {
      _routeTo = RouteNames.login;
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;
      return Scaffold(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    switch (_routeTo) {
      case RouteNames.login:
        return const LoginScreen();

      case RouteNames.onboarding:
        return const ProfileSetupScreen();

      case RouteNames.photoUpload:
        return const PhotoUploadScreen();

      case RouteNames.interests:
        return const InterestsScreen();

      case RouteNames.studentVerification:
        return const StudentVerificationScreen();

      case RouteNames.discover:
        return const DiscoverScreen();

      default:
        return const LoginScreen();
    }

  }
}
