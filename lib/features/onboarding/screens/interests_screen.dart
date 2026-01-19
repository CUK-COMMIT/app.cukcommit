import 'package:flutter/material.dart';
import 'package:cuk_commit/core/constants/color_constants.dart';
import 'package:cuk_commit/core/constants/string_constants.dart';
import 'package:cuk_commit/core/constants/text_styles.dart';
import 'package:cuk_commit/core/routes/route_names.dart';
import 'package:cuk_commit/features/onboarding/providers/onboarding_provider.dart';
import 'package:provider/provider.dart';

class InterestsScreen extends StatelessWidget {
  const InterestsScreen({super.key});

  static const List<String> interestsList = [
    "Music",
    "Movies",
    "Sports",
    "Gym",
    "Coding",
    "AI/ML",
    "Gaming",
    "Books",
    "Travel",
    "Food",
    "Photography",
    "Art",
    "Dancing",
    "Cricket",
    "Football",
    "Anime",
    "Fashion",
    "Poetry",
    "Startups",
    "Pets",
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : AppColors.textPrimaryLight;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppStrings.interests,
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: isDarkMode ? AppColors.cardDark : AppColors.primary,
        elevation: 0,
      ),
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
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Choose your interests",
                  style: AppTextStyles.h2Light.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Pick a few interests to help us match you better.",
                  style: AppTextStyles.bodyLargeLight.copyWith(
                    color: isDarkMode
                        ? Colors.grey.shade400
                        : Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 18),

                Expanded(
                  child: GridView.builder(
                    itemCount: interestsList.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 2.7,
                    ),
                    itemBuilder: (context, index) {
                      final interest = interestsList[index];
                      final selected = provider.interests.contains(interest);

                      return GestureDetector(
                        onTap: () => provider.toggleInterest(interest),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primary.withOpacity(0.85)
                                : (isDarkMode
                                    ? Colors.grey.shade900.withOpacity(0.35)
                                    : Colors.grey.shade100),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : (isDarkMode
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade300),
                              width: 1.2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              interest,
                              style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : (isDarkMode
                                        ? Colors.grey.shade200
                                        : Colors.grey.shade800),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: provider.interests.isNotEmpty
                        ? () async {
                            try {
                              await provider.completeInterestsStep();

                              if (!context.mounted) return;
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                RouteNames.studentVerification,
                                (route) => false,
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("$e")),
                              );
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      disabledBackgroundColor: isDarkMode
                          ? Colors.grey.shade800
                          : Colors.grey.shade300,
                      disabledForegroundColor: isDarkMode
                          ? Colors.grey.shade600
                          : Colors.grey.shade500,
                    ),
                    child: const Text(
                      "Next",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
