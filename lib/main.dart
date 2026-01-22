// main.dart
import 'package:cuk_commit/features/matching/providers/matching_provider.dart';
import 'package:cuk_commit/features/matching/repositories/matching_repository.dart';
import 'package:cuk_commit/features/profile/providers/profile_provider.dart';
import 'package:cuk_commit/features/profile/repositories/profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:cuk_commit/app.dart';
import 'package:cuk_commit/core/providers/theme_provider.dart';
import 'package:cuk_commit/features/onboarding/providers/onboarding_provider.dart';
import 'package:cuk_commit/features/onboarding/repositories/onboarding_repository.dart';
import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // // Optional: SharedPreferences debug init
  // try {
  //   final prefs = await SharedPreferences.getInstance();
  //   final hasWelcomeKey = prefs.containsKey('welcome_screen_seen');
  //   final welcomeValue = prefs.getBool('welcome_screen_seen') ?? false;

  //   debugPrint(
  //     'SharedPreferences initialized. Welcome screen seen: $hasWelcomeKey, Value: $welcomeValue',
  //   );
  // } catch (e) {
  //   debugPrint('Error initializing SharedPreferences: $e');
  // }

  // ===========================
  // Supabase Init (FULL SWITCH)
  // ===========================

  // Use dart-define so keys aren't hardcoded in repo
  await dotenv.load(fileName: ".env");

  final supabaseUrl = dotenv.env["SUPABASE_URL"] ?? "";
  final supabaseAnonKey = dotenv.env["SUPABASE_ANON_KEY"] ?? "";


  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw Exception(
      "Supabase env missing. Provide SUPABASE_URL and SUPABASE_ANON_KEY using --dart-define",
    );
  }



  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    debug: false,
  );

  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    final event = data.event;
    final session = data.session;

    if (event == AuthChangeEvent.signedIn && session != null) {
      // user verified / signed in
      debugPrint("SIGNED IN");
      
    }
  });


  final onboardingRepository = OnboardingRepository();
  final matchingRepository = MatchingRepository();
  final profileRepository = ProfileRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MatchingProvider(repo: matchingRepository)),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => OnboardingProvider(repository: onboardingRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(repository: profileRepository),
        ),
      ],
      child: const App(),
    ),
  );
}
