import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/profile_provider.dart';
import '../providers/matching_provider.dart';
import '../../../core/theme/app_colors.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({Key? key}) : super(key: key);

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _isLoading = false;
  int _selectedPlanIndex = 1;

  final List<Map<String, dynamic>> _premiumFeatures = [
    {
      'icon': Icons.rocket_launch,
      'title': 'Profile Boosts',
      'description':
          'Get up to 10x more matches with periodic profile boosts',
      'highlight': true,
    },
    {
      'icon': Icons.visibility_off,
      'title': 'Incognito Mode',
      'description':
          'Browse profiles privately without being seen',
      'highlight': false,
    },
    {
      'icon': Icons.favorite,
      'title': 'See Who Likes You',
      'description':
          'Know your admirers before you swipe',
      'highlight': true,
    },
    {
      'icon': Icons.public,
      'title': 'Global Mode',
      'description':
          'Match with people worldwide, not just locally',
      'highlight': false,
    },
    {
      'icon': Icons.support_agent,
      'title': 'Priority Support',
      'description':
          'Get faster responses from our dedicated support team',
      'highlight': false,
    },
    {
      'icon': Icons.verified,
      'title': 'Exclusive Badges',
      'description':
          'Stand out with premium badges on your profile',
      'highlight': true,
    },
    {
      'icon': Icons.star,
      'title': 'Exclusive Content',
      'description':
          'Access premium articles, tips, and events',
      'highlight': false,
    },
  ];

  final List<Map<String, dynamic>> _plans = [
    {
      'name': 'Monthly',
      'price': '14.99',
      'period': 'per month',
      'savings': 'Save 0%',
      'popular': false,
    },
    {
      'name': '6 Months',
      'price': '9.99',
      'period': 'per month',
      'savings': 'Save 33%',
      'popular': false,
    },
    {
      'name': 'Yearly',
      'price': '7.99',
      'period': 'per month',
      'savings': 'Save 47%',
      'popular': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    final provider =
        Provider.of<ProfileProvider>(context);
    final matchingProvider =
        Provider.of<MatchingProvider>(context);

    final isPremium = true;

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Premium',
          style: TextStyle(
            color: isDarkMode
                ? Colors.white
                : AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor:
            isDarkMode ? Colors.grey.shade900 : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDarkMode
              ? Colors.white
              : Colors.grey.shade800,
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // Premium Icon
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary
                            .withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.diamond,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Title
                  Center(
                    child: Text(
                      isPremium
                          ? 'You are a Premium Member'
                          : 'Unlock Premium Features',
                      style: TextStyle(
                        color: isDarkMode
                            ? Colors.white
                            : AppColors.primaryLight,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Center(
                    child: Text(
                      isPremium
                          ? 'Enjoy all premium features'
                          : 'Get the most out of your dating experience',
                      style: TextStyle(
                        color: isDarkMode
                            ? Colors.grey.shade400
                            : Colors.grey.shade700,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  if (isPremium) ...[
                    Text(
                      'Premium Features',
                      style: TextStyle(
                        color: isDarkMode
                            ? Colors.white
                            : AppColors.textPrimaryLight,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Incognito Mode Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.grey.shade900
                            : Colors.grey.shade50,
                        borderRadius:
                            BorderRadius.circular(12),
                        border: Border.all(
                          color: isDarkMode
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding:
                                const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary
                                  .withValues(alpha: 0.1),
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.visibility_off,
                              size: 24,
                              color: AppColors.primary,
                            ),
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Incognito Mode',
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white
                                        : AppColors
                                            .textPrimaryLight,
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Browse profiles privately without being seen by others',
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Switch(
                            value:
                                matchingProvider.isIncognitoMode,
                            onChanged: (value) async {
                              try {
                                await matchingProvider
                                    .toggleIncognitoMode(
                                  value,
                                );

                                if (mounted) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        value
                                            ? 'Incognito mode enabled'
                                            : 'Incognito mode disabled',
                                      ),
                                      backgroundColor: value
                                          ? Colors.green
                                          : Colors.grey,
                                      behavior:
                                          SnackBarBehavior.floating,
                                      margin:
                                          const EdgeInsets.all(10),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Error: $e'),
                                      backgroundColor:
                                          Colors.red,
                                      behavior:
                                          SnackBarBehavior.floating,
                                      margin:
                                          const EdgeInsets.all(10),
                                    ),
                                  );
                                }
                              }
                            },
                            activeColor:
                                AppColors.primary,
                            activeTrackColor:
                                AppColors.primary
                                    .withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
