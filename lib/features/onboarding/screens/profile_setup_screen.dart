import 'dart:ui';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:cuk_commit/core/constants/color_constants.dart';
import 'package:cuk_commit/core/constants/string_constants.dart';
import 'package:cuk_commit/core/constants/text_styles.dart';
import 'package:cuk_commit/core/routes/route_names.dart';
import 'package:cuk_commit/features/onboarding/providers/onboarding_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  String _userName = "";

  @override
  void initState() {
    super.initState();

    final user = Supabase.instance.client.auth.currentUser;
    final meta = user?.userMetadata ?? {};

    _userName = (meta["name"] ?? meta["full_name"] ?? "").toString().trim();

    //  push into provider (no UI input needed)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (_userName.isNotEmpty) {
        context.read<OnboardingProvider>().updateName(_userName);
      } else {
        // Optional strict check: if you want to prevent onboarding without name
        debugPrint("⚠️ ProfileSetupScreen: metadata name missing");
      }
    });
  }

  bool _canGoNext(OnboardingProvider provider) {
    return provider.gender.isNotEmpty &&
        provider.relationshipGoal.isNotEmpty &&
        provider.matchPreference.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          AppStrings.createProfile,
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              color: Colors.black.withOpacity(0.25),
            ),
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + kToolbarHeight,
        ),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Tell us about yourself",
                style: AppTextStyles.h2Light.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "This information help us find better matches for you.",
                style: AppTextStyles.bodyLargeLight.copyWith(
                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 32),

              // Gender
              StyledDropdown(
                label: AppStrings.gender,
                icon: Icons.people_outlined,
                items: const [AppStrings.male, AppStrings.female, AppStrings.other],
                value: provider.gender.isEmpty ? null : provider.gender,
                onChanged: (val) => provider.updateGender(val ?? ''),
              ),

              const SizedBox(height: 20),

              // Relationship Goal
              StyledDropdown(
                label: AppStrings.relationshipGoal,
                icon: Icons.favorite_border_rounded,
                items: const [
                  AppStrings.relationship,
                  AppStrings.dating,
                  AppStrings.friends,
                  AppStrings.opentoall,
                  AppStrings.notSure,
                ],
                value: provider.relationshipGoal.isEmpty
                    ? null
                    : provider.relationshipGoal,
                onChanged: (val) => provider.updateRelationshipGoal(val ?? ''),
              ),

              const SizedBox(height: 20),

              // Match preference
              StyledDropdown(
                label: AppStrings.matchPrefrence,
                icon: Icons.groups_2_outlined,
                items: const [AppStrings.men, AppStrings.women, AppStrings.both],
                value:
                    provider.matchPreference.isEmpty ? null : provider.matchPreference,
                onChanged: (val) => provider.updateMatchPreference(val ?? ''),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    disabledBackgroundColor:
                        isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
                    disabledForegroundColor:
                        isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
                  ),
                  onPressed: _canGoNext(provider)
                      ? () async {
                          try {
                            await provider.saveProfileSetupStep();
                            if (!context.mounted) return;
                            Navigator.pushReplacementNamed(
                              context,
                              RouteNames.photoUpload,
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("$e")),
                            );
                          }
                        }
                      : null,
                  child: const Text(
                    AppStrings.next,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

// ============================================================================
// Styled Dropdown (dropdown_button2)
// ============================================================================

class StyledDropdown extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<String> items;
  final String? value;
  final ValueChanged<String?> onChanged;

  const StyledDropdown({
    super.key,
    required this.label,
    required this.icon,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDarkMode ? Colors.white : Colors.black;
    final hintColor = isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600;

    final fieldColor = isDarkMode
        ? Colors.grey.shade900.withOpacity(0.35)
        : Colors.grey.shade100;

    return DropdownButtonFormField2<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: fieldColor,
        prefixIcon: Icon(
          icon,
          color:
              isDarkMode ? AppColors.primary : AppColors.primary.withOpacity(0.7),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      hint: Text(
        "Select",
        style: TextStyle(color: hintColor, fontWeight: FontWeight.w500),
      ),
      style: TextStyle(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
      dropdownStyleData: DropdownStyleData(
        maxHeight: 260,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              spreadRadius: 0,
              color: Colors.black.withOpacity(0.14),
              offset: const Offset(0, 8),
            )
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 6),
        scrollbarTheme: ScrollbarThemeData(
          radius: const Radius.circular(50),
          thickness: WidgetStateProperty.all(4),
          thumbVisibility: WidgetStateProperty.all(true),
        ),
      ),
      buttonStyleData: const ButtonStyleData(
        height: 56,
        padding: EdgeInsets.only(right: 8),
      ),
      iconStyleData: IconStyleData(
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
        ),
      ),
      menuItemStyleData: const MenuItemStyleData(
        height: 48,
        padding: EdgeInsets.symmetric(horizontal: 14),
      ),
    );
  }
}
