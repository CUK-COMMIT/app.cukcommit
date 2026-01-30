import 'package:cuk_commit/core/constants/color_constants.dart';
import 'package:cuk_commit/core/constants/text_styles.dart';
import 'package:cuk_commit/core/routes/route_names.dart';
import 'package:cuk_commit/features/chat/providers/chat_provider.dart';

import 'package:cuk_commit/shared/layout/main_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final chatProvider = Provider.of<ChatProvider>(context);
    final chatRooms = chatProvider.chatRooms;

    //dummy data for new matches
    final List<Map<String, dynamic>> newMatches = [
      {
        'id': '1',
        'name': "David",
        'image': ["assets/images/profile11.jpg"],
        'isOnline': true,
        'gender': "Male",
        'bio': "I am a software engineer",
        'interests': ["Music", "Movies", "Travel"],
        "department": "CSE",
        "program": "UG",
        "year": "3",
      },
      {
        'id': '2',
        'name': "Emily",
        'image': ["assets/images/profile21.jpg"],
        'isOnline': true,
        'gender': "Female",
        'bio': "I am a software engineer",
        'interests': ["Music", "Movies", "Travel"],
        "department": "CSE",
        "program": "UG",
        "year": "3",
      },
      {
        'id': '3',
        'name': "Michael",
        'image': ["assets/images/profile31.jpg"],
        'isOnline': true,
        'gender': "Male",
        'bio': "I am a software engineer",
        'interests': ["Music", "Movies", "Travel"],
        "department": "CSE",
        "program": "UG",
        "year": "3",
      },
    ];

    return MainLayout(
      currentIndex: 1,
      child: Scaffold(
        backgroundColor: isDarkMode
            ? AppColors.backgroundDark
            : Colors.grey.shade50,
        appBar: AppBar(
          title: Text(
            'Messages',
            style: TextStyle(
              color: isDarkMode ? Colors.white : AppColors.primaryLight,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          centerTitle: true,
          backgroundColor: isDarkMode
              ? AppColors.backgroundDark
              : Colors.grey.shade50,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.search,
                color: isDarkMode ? Colors.white : Colors.grey.shade800,
              ),
            ),
          ],
        ),
        body: chatProvider.isLoading
            ? Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  // New matches section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'New Matches',
                            style: AppTextStyles.h3Light.copyWith(
                              color: isDarkMode
                                  ? Colors.white
                                  : AppColors.textPrimaryLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // navigates to discover screen to see all potential matches
                              Navigator.pushNamed(context, RouteNames.discover);
                            },
                            child: Text(
                              "See All",
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // new Matches horizontal list
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 110,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: newMatches.length,
                        itemBuilder: (context, index) {
                          final match = newMatches[index];
                          return GestureDetector(
                            onTap: () {
                              //navigate to match priview
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Column(
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              AppColors.primary,
                                              Colors.purple,
                                            ],
                                          ),
                                        ),
                                        child: Container(
                                          padding: EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isDarkMode
                                                ? AppColors.backgroundDark
                                                : Colors.white,
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              50,
                                            ),
                                            child: Image.asset(
                                              match['image'][0],
                                              width: 64,
                                              height: 64,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),

                                      if (match['isOnline'])
                                        Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                            width: 14,
                                            height: 14,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.green,
                                              border: Border.all(
                                                color: isDarkMode
                                                    ? AppColors.backgroundDark
                                                    : Colors.white,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),
                                  Text(
                                    match['name'],
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white
                                          : AppColors.textPrimaryLight,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // messages section header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                      child: Text(
                        "Messages",
                        style: AppTextStyles.h3Light.copyWith(
                          color: isDarkMode
                              ? Colors.white
                              : AppColors.textPrimaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  //Message List
                  chatRooms.isEmpty
                      ? SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isDarkMode
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade200,
                                  ),
                                  child: Icon(
                                    Icons.chat_bubble_outline_rounded,
                                    size: 48,
                                    color: isDarkMode
                                        ? Colors.grey.shade500
                                        : Colors.grey.shade400,
                                  ),
                                ),

                                const SizedBox(height: 24),
                                Text(
                                  "No messages yet",
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.grey.shade800,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 40),
                                  child: Text(
                                    "Start matching with peoples to begin conversations",
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade600,
                                      // fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      RouteNames.discover,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 24,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: const Text("Discover"),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final chatRoom = chatRooms[index];
                            return Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.grey.shade900
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    offset: const Offset(0, 2),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),

                              child: InkWell(
                                onTap: () {
                                  // navigate to chat screen with chatRoom object
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      Stack(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.1),
                                                  offset: const Offset(0, 2),
                                                  blurRadius: 8,
                                                ),
                                              ],
                                            ),

                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              child: SizedBox(
                                                height: 56,
                                                width: 56,
                                                child: Image.asset(
                                                  chatRoom.matchImage,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),

                                          if (chatRoom.isMatchOnline)
                                            Positioned(
                                              bottom: 0,
                                              right: 0,
                                              child: Container(
                                                height: 14,
                                                width: 14,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.green,
                                                  border: Border.all(
                                                    color: isDarkMode
                                                        ? Colors.grey.shade900
                                                        : Colors.white,
                                                    width: 2,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),

                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  chatRoom.matchName,
                                                  style: TextStyle(
                                                    color: isDarkMode
                                                        ? Colors.white
                                                        : AppColors
                                                              .textPrimaryLight,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        chatRoom.unreadCount > 0
                                                        ? FontWeight.bold
                                                        : FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  _formatTime(
                                                    chatRoom.lastActivity ??
                                                        chatRoom.createdAt,
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        chatRoom.unreadCount > 0
                                                        ? AppColors.primary
                                                        : (isDarkMode
                                                              ? Colors
                                                                    .grey
                                                                    .shade500
                                                              : Colors
                                                                    .grey
                                                                    .shade600),
                                                    fontWeight:
                                                        chatRoom.unreadCount > 0
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    chatRoom
                                                            .lastMessage
                                                            ?.content ??
                                                        'No messages yet',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color:
                                                          chatRoom.unreadCount >
                                                              0
                                                          ? (isDarkMode
                                                                ? Colors.white
                                                                : AppColors.textPrimaryLight)
                                                          : (isDarkMode
                                                                ? Colors.grey.shade400
                                                                : Colors.grey.shade700),
                                                      fontWeight:
                                                          chatRoom.unreadCount >
                                                              0
                                                          ? FontWeight.w500
                                                          : FontWeight.normal,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    maxLines: 1,
                                                  ),
                                                ),

                                                const SizedBox(height: 8),
                                                if(chatRoom.unreadCount > 0) 
                                                Container(
                                                  padding: const EdgeInsets.all(6),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primary,
                                                    shape: BoxShape.circle,
                                                    // borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    chatRoom.unreadCount.toString(),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                    ),
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
                              ),
                            );
                          }, childCount: chatRooms.length),
                        ),
                ],
              ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays >= 1) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
