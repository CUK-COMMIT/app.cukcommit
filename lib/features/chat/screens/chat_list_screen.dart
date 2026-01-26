import 'package:cuk_commit/core/constants/color_constants.dart';

import 'package:cuk_commit/shared/layout/main_layout.dart';
import 'package:flutter/material.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return MainLayout(
      currentIndex: 1,
      child: Scaffold(
        backgroundColor: isDarkMode
            ? AppColors.backgroundDark
            : Colors.grey.shade50,
        appBar: AppBar(
          title: Text('Messages', style: TextStyle()),
          centerTitle: true,
        ),
      ),
    );
  }
}
