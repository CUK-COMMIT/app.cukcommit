import 'package:cuk_commit/core/constants/color_constants.dart';
import 'package:cuk_commit/core/constants/text_styles.dart';
import 'package:cuk_commit/features/icebreaker/providers/icebreaker_provider.dart';
import 'package:cuk_commit/features/icebreaker/widgets/icebreaker_card.dart';
import 'package:cuk_commit/features/matching/providers/matching_provider.dart';
import 'package:cuk_commit/shared/layout/main_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    //Dummy user data
    final Map<String, dynamic> userData = {
      'name': 'John Doe',
      'year': 2,
      'gender': 'Male',
      'bio':
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
      'images': [
        'https://images.unsplash.com/photo-1506794778202-cad84cf45f1a?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=880&q=80',
        'https://images.unsplash.com/photo-1506794778202-cad84cf45f1a?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=880&q=80',
        'https://images.unsplash.com/photo-1506794778202-cad84cf45f1a?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=880&q=80',
      ],
      'interests': ['Sports', 'Music', 'Movies', 'Books', 'Travel', 'Games'],
      'department': "CSE",
      'program': "UG",
    };
    return MainLayout(
      currentIndex: 2,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            // App bar
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: isDarkMode
                  ? AppColors.backgroundDark
                  : Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // profile image
                    Image.network(
                      userData['images'][0],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade300,
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),

                    // gardient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.7, 1.0],
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),

                    // profile info at bottom
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Column(
                        // mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${userData['name']} ${userData['program']}',
                            style: TextStyle(
                              color: Colors.white,
                              // fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.apartment,
                                size: 16,
                                color: Colors.white70,
                              ),

                              const SizedBox(width: 4),
                              Text(
                                userData['department'],
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              actions: [
                IconButton(
                  icon: Icon(Icons.settings_outlined),
                  onPressed: () {},
                ),
              ],
            ),

            // profile content
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // edit profile button
                    ElevatedButton.icon(
                      onPressed: () {},
                      label: Text("Edit Profile"),
                      icon: Icon(Icons.edit),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Badges section
                    Consumer<MatchingProvider>(
                      builder: (context, matchingProvider, child) {
                        final badges = matchingProvider.getPremiumBadges();
                        if (badges.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Premium Badges',
                              style: AppTextStyles.h3Light.copyWith(
                                color: isDarkMode
                                    ? Colors.white
                                    : AppColors.textPrimaryLight,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: badges.map((badge) {
                                return Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: badge.color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: badge.color.withValues(alpha: 0.5),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        badge.icon,
                                        size: 16,
                                        color: badge.color,
                                      ),
                                      // const SizedBox(width: 4),
                                      Text(
                                        badge.name,
                                        style: TextStyle(
                                          color: badge.color,
                                          // fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 24),
                          ],
                        );
                      },
                    ),

                    // about section
                    Text(
                      "About",
                      style: AppTextStyles.h3Light.copyWith(
                        color: isDarkMode
                            ? Colors.white
                            : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userData['bio'] ?? "No bio",
                      style: TextStyle(
                        color: isDarkMode
                            ? Colors.grey.shade300
                            : Colors.grey.shade800,
                        // fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (userData['interests'] as List<String>).map((
                        interest,
                      ) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? AppColors.primary.withValues(alpha: 0.2)
                                : AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            interest,
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.white
                                  : AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),
                    // Basic info section
                    Text(
                      "Basic Info",
                      style: AppTextStyles.h3Light.copyWith(
                        color: isDarkMode
                            ? Colors.white
                            : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),
                    _infoItem(
                      icon: Icons.apartment,
                      label: "Department",
                      value: userData['department'] ?? "Not specified",
                      isDarkMode: isDarkMode,
                    ),

                    const SizedBox(height: 8),
                    _infoItem(
                      icon: Icons.school,
                      label: "Program",
                      value: userData['gender'] ?? "Not specified",
                      isDarkMode: isDarkMode,
                    ),

                    const SizedBox(height: 8),
                    _infoItem(
                      icon: Icons.calendar_today,
                      label: "Year",
                      value: userData['year'] ?? "Not specified",
                      isDarkMode: isDarkMode,
                    ),

                    const SizedBox(height: 32),

                    OutlinedButton.icon(
                      onPressed: () {},
                      label: Text("Settings"),
                      icon: Icon(Icons.settings_outlined),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDarkMode
                            ? Colors.white
                            : AppColors.textPrimaryLight,
                        side: BorderSide(
                          color: isDarkMode
                              ? Colors.grey.shade700
                              : Colors.grey.shade300,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),

            // Icebreakers section
            SliverToBoxAdapter(
              child: Consumer<IcebreakerProvider>(
                builder: (context, icebreakerProvider, child) {
                  final answeredIcebreakers = icebreakerProvider
                      .getAnsweredIcebreaker();

                  if (answeredIcebreakers.isEmpty) {
                    return Container(); // don't show anything if no answered icebreakers
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Icebreakers",
                              style: AppTextStyles.h3Light.copyWith(
                                color: isDarkMode ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text("See all"),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          itemCount: answeredIcebreakers.length > 3
                              ? 3
                              : answeredIcebreakers.length,
                          itemBuilder: (context, index) {
                            final icebreaker = answeredIcebreakers[index];
                            final answers =
                                icebreakerProvider.userAnswers[icebreaker.id] ??
                                [];
                            return Container(
                              width: 250,
                              margin: EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.grey.shade800
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDarkMode
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: IcebreakerCard(
                                icebreaker: icebreaker,
                                answer: answers.isNotEmpty ? answers.first.answer : null,
                                isCompact: true,
                                onTap: () {
                                  // navigate to icebreaker detail page
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isDarkMode,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            color: isDarkMode ? Colors.white : AppColors.textPrimaryLight,
            // fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
