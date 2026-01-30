import 'package:flutter/material.dart';

class ContentDetailScreen extends StatelessWidget {
  final ExclusiveContent content;
  const ContentDetailScreen({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar:AppBar(
        title: Text(
          content.title,
          style : TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontWeight: fontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.grey.shade900:Colors.white,
        elevation:0,
        iconTheme:IconThemeData(
          color: isDarkMode ? Colors.grye.shade800,
        ),
      ),
      // AppBar
body: SingleChildScrollView(
  padding: EdgeInsets.all(16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ClipRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          content.imageUrl,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              width : double.infinity,
              color: isDarkMode
                  ? Colors.grey.shade800
                  : Colors.grey.shade200,
              child: Icon(
                Icons.image_not_supported,
                size: 50,
                color: isDarkMode
                    ? Colors.grey.shade400
                    : Colors.grey.shade600,
              ), 
            ); 
          },
        ), 
      ), 
      const SizedBox(height: 24),
        Text(
          content.title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDarkMode
                ? Colors.white
                : AppColors.textPrimaryLight,
          ), // TextStyle
        ), // Text

        const SizedBox(height: 8),
        Text(
          content.description,
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode
                ? Colors.grey.shade400
                : Colors.grey.shade600,
          ), // TextStyle
        ), // Text
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: content.tags.map((tag) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.5),
                  width: 1,
                ), // Border.all
              ), // BoxDecoration
              child: Text(
              tag,
              style: TextStyle(
                color: AppColors.primary,
                fontSize:12,
                fontWeight: FontWeight.w500,
              ),
              ),
            ); // Container
          }).toList(),
        ), // Wrap
        const SizedBox(height:24),
        Text(
          content.content,
          style: TextStyle(
            fontSize:16,
            height:1.6,
            color: isDarkMode ? Colors.white : AppColors.textPrimaryLight,
          
          ),
        ),

    ],
  ),
),

    );
  }
}
  