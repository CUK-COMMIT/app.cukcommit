import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:cuk_commit/core/constants/color_constants.dart';

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
          color: isDarkMode
              ? AppColors.primary
              : AppColors.primary.withOpacity(0.7),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),

      hint: Text(
        "Select",
        style: TextStyle(color: hintColor),
      ),

      style: TextStyle(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
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

      // dropdown menu styling
      dropdownStyleData: DropdownStyleData(
        maxHeight: 240,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              blurRadius: 16,
              spreadRadius: 0,
              color: Colors.black.withOpacity(0.15),
              offset: const Offset(0, 6),
            )
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 6),
        scrollbarTheme: ScrollbarThemeData(
          radius: const Radius.circular(40),
          thickness: WidgetStateProperty.all(4),
          thumbVisibility: WidgetStateProperty.all(true),
        ),
      ),

      // button styling
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

      // item styling
      menuItemStyleData: const MenuItemStyleData(
        height: 48,
        padding: EdgeInsets.symmetric(horizontal: 14),
      ),
    );
  }
}
