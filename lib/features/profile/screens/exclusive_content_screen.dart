import 'package:cuk_commit/features/matching/models/exclusive_content.dart';
import 'package:flutter/material.dart';
import 'package:cuk_commit/core/constants/color_constants.dart';
import 'package:cuk_commit/features/matching/providers/matching_provider.dart';
import 'package:provider/provider.dart';
class ExclusiveContentScreen extends StatelessWidget {
  const ExclusiveContentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final matchingProvider = Provider.of<MatchingProvider>(context);
    final contentList = matchingProvider.availableExclusiveContent();
    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Exclusive Content'),
        backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.grey.shade800,
        ),
      ),
      body: contentList.isEmpty
          ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 64,
                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                const SizedBox(height: 16),
                Text(
                  'Exclusive Content',
                  style: TextStyle(
                    fontSize: 24,
                    color: isDarkMode ? Colors.white : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Subscribe to premium to access exclusive content ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/premium');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding:EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Upgrade to Premium',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          )
          : ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: content.length,
              itemBuilder: (context, index) {
                final item = content[index];
                return _buildContentCard(
                  context,
                  item,
                  isDarkMode,
                );
              },
            ),
    );
  }
  Widget _buildContentCard(
    BuildContext context,
    ExclusiveContent content,
    bool isDarkMode,
  )
  {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape : RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Inkwell(
        onTap: () {
          // Handle content tap
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ContentDetailScreen(
                content: content,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                content.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace){
                  return Container(
                    height: 200,width: double.infinity,
                    color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                    child: Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  );    
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 12),
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
                          ),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}