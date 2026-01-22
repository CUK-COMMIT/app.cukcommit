import 'package:flutter/material.dart';
import 'package:cuk_commit/core/constants/color_constants.dart';
import 'package:cuk_commit/core/constants/string_constants.dart';
import 'package:cuk_commit/core/constants/text_styles.dart';
import 'package:cuk_commit/core/routes/route_names.dart';
// import 'package:cuk_commit/core/services/preferences_service.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [Colors.black, Color(0xFF1A1A2E), Color(0xFF16213E)]
                : AppColors.primaryGradient,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 60),
                Column(
                  children: [
                    Text(
                      AppStrings.welcome,
                      style: AppTextStyles.bodyLargeLight.copyWith(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.findYourMatch,
                      style: AppTextStyles.bodyLargeLight.copyWith(
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.25,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 32),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        "assets/images/cukcommit_screen.jpeg",
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 64,
                              color: isDarkMode
                                  ? Colors.white38
                                  : Colors.black38,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 40),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            //mark welcome screen as seen
                            // await PreferencesService.setWelcomeSeen();

                            if (context.mounted) {
                              Navigator.pushReplacementNamed(
                                  context, 
                                  RouteNames.signup);
                            }
                          } catch (e) {
                            debugPrint(
                                'Error marking welcome screen as seen: $e');
                          }
                          
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode
                              ? AppColors.primary
                              : Colors.white,
                          foregroundColor: isDarkMode
                              ? Colors.white
                              : AppColors.primary,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          "Create Account",
                          style: AppTextStyles.buttonLarge.copyWith(
                            color: isDarkMode
                                ? Colors.white
                                : AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () async{
                          try{
                            //mark welcome screen as seen
                            // await PreferencesService.setWelcomeSeen();
                            // await PreferencesService.resetWelcomeSeen();

                            if (context.mounted) {
                              Navigator.pushReplacementNamed(
                                  context, 
                                  RouteNames.login);
                            }
                          } catch(e) {
                            debugPrint(
                                'Error marking welcome screen as seen: $e');
                          }
                        },
                        child: Text(
                          "Already have an account? Log In",
                          style: AppTextStyles.buttonLarge.copyWith(
                            color: isDarkMode
                                ? Colors.white70
                                : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
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
