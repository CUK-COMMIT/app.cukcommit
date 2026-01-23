import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/profile_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _occupationController;
  late TextEditingController _educationController;
  late TextEditingController _locationController;

  late int _age;
  bool _isloading = false;

  @override
  void initState() {
    super.initState();

    final provider =
        Provider.of<ProfileProvider>(context, listen: false);
    final profile = provider.profile;

    _nameController =
        TextEditingController(text: profile?.name ?? '');
    _bioController =
        TextEditingController(text: profile?.bio ?? '');
    _occupationController =
        TextEditingController(text: profile?.occupation ?? '');
    _educationController =
        TextEditingController(text: profile?.education ?? '');
    _locationController =
        TextEditingController(text: profile?.location ?? '');
    _age = profile?.age ?? 18;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _occupationController.dispose();
    _educationController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isloading = true;
      });

      final provider =
          Provider.of<ProfileProvider>(context, listen: false);
      final currentProfile = provider.profile;

      if (currentProfile != null) {
        final updatedProfile = currentProfile.copyWith(
          name: _nameController.text,
          bio: _bioController.text,
          occupation: _occupationController.text,
          education: _educationController.text,
          location: _locationController.text,
          age: _age,
        );

        await provider.updateProfile(updatedProfile);

        setState(() {
          _isloading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDarkMode
        ? AppColors.backgroundDark
        : Colors.grey.shade50;

    final cardColor =
        isDarkMode ? Colors.grey.shade900 : Colors.white;

    final textColor = isDarkMode
        ? Colors.white
        : AppColors.textPrimaryLight;

    final hintColor = isDarkMode
        ? Colors.grey.shade500
        : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: cardColor,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDarkMode
              ? Colors.white
              : Colors.grey.shade800,
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: cardColor,
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: isDarkMode
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: isDarkMode
                                ? Colors.grey.shade600
                                : Colors.grey.shade400,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: cardColor,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Edit Your Profile',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                        'Basic Information', isDarkMode),

                    _buildCard(
                      isDarkMode: isDarkMode,
                      cardColor: cardColor,
                      child: _buildTextField(
                        controller: _nameController,
                        labelText: 'Name',
                        icon: Icons.person_outline,
                        isDarkMode: isDarkMode,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 32),

                    CustomButton(
                      text: 'Save Changes',
                      onPressed:
                          _isloading ? null : _saveProfile,
                      isLoading: _isloading,
                      type: ButtonType.primary,
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required bool isDarkMode,
    String? hintText,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final textColor =
        isDarkMode ? Colors.white : Colors.black;

    final hintColor = isDarkMode
        ? Colors.grey.shade500
        : Colors.grey.shade600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              labelText,
              style: TextStyle(color: hintColor, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          style: TextStyle(color: textColor, fontSize: 16),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: isDarkMode
                  ? Colors.grey.shade700
                  : Colors.grey.shade400,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: isDarkMode
                ? Colors.grey.shade800.withValues(alpha: 0.3)
                : Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required Widget child,
    required bool isDarkMode,
    required Color cardColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color:
              isDarkMode ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
