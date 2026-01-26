import 'package:cuk_commit/features/chat/screens/chat_list_screen.dart';
import 'package:cuk_commit/features/matching/screens/match_details_screen.dart';
import 'package:cuk_commit/features/onboarding/screens/student_verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:cuk_commit/core/routes/route_names.dart';
import 'package:cuk_commit/auth_gate.dart';
import 'package:cuk_commit/features/auth/screens/forget_password_screen.dart';
import 'package:cuk_commit/features/auth/screens/login_screen.dart';
import 'package:cuk_commit/features/auth/screens/registeration_screen.dart';
import 'package:cuk_commit/features/auth/screens/reset_password_screen.dart';
import 'package:cuk_commit/features/auth/screens/verification_screen.dart';
import 'package:cuk_commit/features/matching/screens/discover_screen.dart';
import 'package:cuk_commit/features/onboarding/screens/interests_screen.dart';
import 'package:cuk_commit/features/onboarding/screens/photo_upload_screen.dart';
import 'package:cuk_commit/features/onboarding/screens/profile_setup_screen.dart';
import 'package:cuk_commit/features/onboarding/screens/welcome_screen.dart';
import 'package:cuk_commit/features/splash/screens/splash_screen.dart';

class AppRouter {
  static String get initialRoute => RouteNames.splash;

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final rawName = settings.name ?? '';
    final uri = Uri.tryParse(rawName);

    //  if deep link opened app like "/?code=..."
    final routeName = uri?.path ?? rawName;

    //  handle callback errors (otp_expired etc.)
    if (uri != null &&
        (uri.queryParameters.containsKey("error") ||
            uri.fragment.contains("error="))) {
      debugPrint(
        "Auth error: ${uri.fragment}\n${uri.queryParameters}\nIn app router",
      );
      return MaterialPageRoute(builder: (_) => const LoginScreen());
      // or AuthGate()
    }

    //  handle Supabase confirmation/recovery callback
    // ex: /?code=...  OR /login-callback?code=...
    if (uri != null &&
        (uri.queryParameters.containsKey("token") ||
            uri.fragment.contains("access_token"))) {
      debugPrint("Deep link received: ${settings.name}");
      debugPrint("URI host: ${uri.host}, path: ${uri.path}");
      debugPrint("Query params: ${uri.queryParameters}");
      debugPrint("Fragment: ${uri.fragment}");

      // Check if this is a password recovery link (type=recovery)
      // Supabase may send type in query params or in the fragment
      final typeFromQuery = uri.queryParameters['type'];
      final typeFromFragment = uri.fragment.contains('type=recovery')
          ? 'recovery'
          : null;
      final type = typeFromQuery ?? typeFromFragment;

      debugPrint("Detected type: $type");

      if (type == 'recovery' ||
          uri.host == 'reset-password' ||
          uri.path.contains('reset-password')) {
        debugPrint(
          "Password recovery link detected, routing to ResetPasswordScreen",
        );
        return MaterialPageRoute(builder: (_) => const ResetPasswordScreen());
      }

      // For email confirmation or other auth callbacks
      debugPrint("Non-recovery auth callback, routing to AuthGate");
      return MaterialPageRoute(builder: (_) => const AuthGate());
    }

    switch (routeName) {
      case RouteNames.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case RouteNames.welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());

      case RouteNames.authGate:
        return MaterialPageRoute(builder: (_) => const AuthGate());

      // Auth screens
      case RouteNames.resetPassword:
        return MaterialPageRoute(builder: (_) => const ResetPasswordScreen());

      case RouteNames.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case RouteNames.signup:
        return MaterialPageRoute(builder: (_) => const RegisterationScreen());

      case RouteNames.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgetPasswordScreen());

      case RouteNames.verification:
        final email = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => VerificationScreen(email: email),
        );

      // Onboarding screens
      case RouteNames.onboarding:
        return MaterialPageRoute(builder: (_) => const ProfileSetupScreen());

      case RouteNames.photoUpload:
        return MaterialPageRoute(builder: (_) => const PhotoUploadScreen());

      case RouteNames.interests:
        return MaterialPageRoute(builder: (_) => const InterestsScreen());

      case RouteNames.studentVerification:
        return MaterialPageRoute(
          builder: (_) => const StudentVerificationScreen(),
        );

      // Main screen
      case RouteNames.discover:
        return MaterialPageRoute(builder: (_) => const DiscoverScreen());

      case RouteNames.matchDetails:
        return MaterialPageRoute(builder: (_) => const MatchDetailsScreen());

      case RouteNames.messages:
        return MaterialPageRoute(builder: (_) => const ChatListScreen());

      default:
        //  IMPORTANT: never show "No route defined" for deep links
        // fallback to AuthGate for safety
        return MaterialPageRoute(builder: (_) => const AuthGate());
    }
  }
}
