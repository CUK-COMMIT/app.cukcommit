import 'package:flutter/material.dart';
import '../constants/color_constants.dart';

enum ButtonType { primary, secondary, text }
enum ButtonSize { small, medium, large }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool isFullWidth;
  final bool isLoading;
  final IconData? icon;
  final bool iconAfterText;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.isFullWidth = true,
    this.isLoading = false,
    this.icon,
    this.iconAfterText = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Determine button style based on type
    ButtonStyle getButtonStyle() {
      switch (type) {
        case ButtonType.primary:
          return ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: isDarkMode 
                ? Colors.grey.shade800 
                : Colors.grey.shade300,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: _getPadding(),
          );
        case ButtonType.secondary:
          return ElevatedButton.styleFrom(
            backgroundColor: isDarkMode 
                ? Colors.grey.shade800.withOpacity(0.5) 
                : Colors.grey.shade100,
            foregroundColor: AppColors.primary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: AppColors.primary.withOpacity(0.5),
                width: 1,
              ),
            ),
            padding: _getPadding(),
          );
        case ButtonType.text:
          return TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: _getPadding(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          );
      }
    }
    
    // Get button content
    Widget buttonContent() {
      final textWidget = Text(
        text,
        style: TextStyle(
          fontSize: _getFontSize(),
          fontWeight: FontWeight.w600,
        ),
      );
      
      if (isLoading) {
        return SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: type == ButtonType.primary ? Colors.white : AppColors.primary,
            strokeWidth: 2,
          ),
        );
      }
      
      if (icon != null) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: iconAfterText
              ? [textWidget, const SizedBox(width: 8), Icon(icon, size: _getIconSize())]
              : [Icon(icon, size: _getIconSize()), const SizedBox(width: 8), textWidget],
        );
      }
      
      return textWidget;
    }
    
    // Build the appropriate button based on type
    Widget button;
    switch (type) {
      case ButtonType.primary:
      case ButtonType.secondary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: getButtonStyle(),
          child: buttonContent(),
        );
        break;
      case ButtonType.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: getButtonStyle(),
          child: buttonContent(),
        );
        break;
    }
    
    return isFullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
  
  // Helper methods for sizing
  EdgeInsetsGeometry _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 20);
    }
  }
  
  double _getFontSize() {
    switch (size) {
      case ButtonSize.small:
        return 14;
      case ButtonSize.medium:
        return 16;
      case ButtonSize.large:
        return 18;
    }
  }
  
  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }
}
