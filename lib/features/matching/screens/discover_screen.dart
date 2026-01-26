import 'package:cuk_commit/core/constants/color_constants.dart';
import 'package:cuk_commit/core/routes/route_names.dart';
import 'package:cuk_commit/features/matching/models/match_result.dart';
import 'package:cuk_commit/features/matching/providers/matching_provider.dart';
import 'package:cuk_commit/features/matching/widgets/image_gesture_detector.dart';
import 'package:cuk_commit/shared/layout/main_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late PageController _imagePageController;
  int _currentImagePage = 0;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuint),
    );

    _imagePageController = PageController();

    // Refresh matches when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<MatchingProvider>().refreshMatches();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _imagePageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // final textColor = isDarkMode ? Colors.white : Colors.black;
    final matchingProvider = context.watch<MatchingProvider>();

    Widget bodyContent;

    if (matchingProvider.isLoading) {
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (!matchingProvider.hasMatches) {
      bodyContent = Center(
        child: Text(
          "No matches found",
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 18,
            // fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      final profile = matchingProvider.currentMatch!;
      bodyContent = Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: ImageGestureDetector(
                  onTap: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      RouteNames.matchDetails,
                      arguments: profile,
                    );

                    //handle the result
                    if (!mounted) return;
                    if (result == "like") {
                      await context.read<MatchingProvider>().likeCurrent();
                    } else if (result == "dislike") {
                      await context.read<MatchingProvider>().dislikeCurrent();
                    } else if (result == "superlike") {
                      await context.read<MatchingProvider>().superLikeCurrent();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("Superlike!"),
                          backgroundColor: Colors.amber,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: const EdgeInsets.all(10),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    } else if (result == "report") {
                      await context.read<MatchingProvider>().reportCurrent();
                    }
                  },
                  onTapLeft: () {
                    if (_currentImagePage > 0) {
                      _imagePageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  onTapRight: () {
                    if (_currentImagePage < profile.images.length - 1) {
                      _imagePageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                  onHorizontalDragEnd: (details) {
                    if (details.primaryVelocity! > 0) {
                      if (_currentImagePage > 0) {
                        _imagePageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    } else if (details.primaryVelocity! < 0) {
                      if (_currentImagePage < profile.images.length - 1) {
                        _imagePageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      }
                    }
                  },
                  onLongPress: () {
                    //show share options
                    // _showShareOptions(context, profile);
                    _showPhotoShareOptions(context, profile, _currentImagePage);
                  },
                  child: Hero(
                    tag: "profile-${profile.id}-0",
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        // image: DecorationImage(
                        //   image: NetworkImage(profile.images[_currentImagePage]),
                        //   fit: BoxFit.cover,
                        // ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          children: [
                            //profile image
                            Positioned.fill(
                              child: PageView.builder(
                                controller: _imagePageController,
                                onPageChanged: (index) {
                                  setState(() {
                                    _currentImagePage = index;
                                  });
                                },
                                itemCount: profile.images.length,

                                itemBuilder: (context, index) {
                                  return Image.asset(
                                    profile.images[index],
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),

                            // gradient overaly
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.8),
                                    ],
                                    stops: const [0.6, 1.0],
                                  ),
                                ),
                              ),
                            ),

                            //profile info
                            Positioned(
                              left: 20,
                              right: 20,
                              bottom: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '${profile.name}, ${profile.program ?? ''} ',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.apartment,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        profile.department,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    profile.bio,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: profile.interests.map((interest) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withValues(
                                              alpha: 0.3,
                                            ),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          interest,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),

                            // swipe indicators
                            Positioned.fill(
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => context
                                        .read<MatchingProvider>()
                                        .dislikeCurrent(),
                                    behavior: HitTestBehavior.translucent,
                                    child: Container(
                                      color: Colors.transparent,
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.3,
                                      // height: MediaQuery.of(context).size.height * 0.3,
                                    ),
                                  ),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () => context
                                        .read<MatchingProvider>()
                                        .likeCurrent(),
                                    behavior: HitTestBehavior.translucent,
                                    child: Container(
                                      color: Colors.transparent,
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.3,
                                      // height: MediaQuery.of(context).size.height * 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // page indicator
                            Positioned(
                              top: 16,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  profile.images.length,
                                  (index) => Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _currentImagePage == index
                                          ? Colors.white
                                          : Colors.white.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // action button
          Container(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade900 : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _actionButton(
                  icon: Icons.close_rounded,
                  color: Colors.red,
                  onPressed: () =>
                      context.read<MatchingProvider>().dislikeCurrent(),
                  isDarkMode: isDarkMode,
                ),
                _actionButton(
                  icon: Icons.favorite_rounded,
                  color: AppColors.primary,
                  onPressed: () =>
                      context.read<MatchingProvider>().likeCurrent(),
                  isDarkMode: isDarkMode,
                ),
                _actionButton(
                  icon: Icons.star_rounded,
                  color: Colors.amber,
                  onPressed: () {
                    //super like
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("You super liked ${profile.name}!"),
                        backgroundColor: Colors.amber,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(10),
                        ),
                        margin: EdgeInsets.all(10),
                        duration: Duration(seconds: 1),
                      ),
                    );
                    context.read<MatchingProvider>().superLikeCurrent();
                  },
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
          ),
        ],
      );
    }

    final profile = matchingProvider.currentMatch;

    return MainLayout(
      currentIndex: 0,
      child: Scaffold(
        backgroundColor: isDarkMode
            ? AppColors.backgroundDark
            : Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: isDarkMode
              ? AppColors.backgroundDark
              : Colors.grey.shade50,
          elevation: 0,
          title: Text(
            "Discover",
            style: TextStyle(
              color: isDarkMode ? Colors.white : AppColors.textPrimaryLight,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                if (profile != null) {
                  _showShareOptions(context, profile);
                }
              },
              icon: Icon(
                Icons.share,
                color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
              ),
            ),
            IconButton(
              onPressed: () {
                //navigate to filter screen
              },
              icon: Icon(
                Icons.filter_list_rounded,
                // Icons.tune,
                color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
              ),
            ),
          ],
        ),
        body: bodyContent,
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required bool isDarkMode,
    double size = 56,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 10,
            // offset: const Offset(0, 5),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: isDarkMode ? Colors.grey.shade800 : Colors.white,
        shape: CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: CircleBorder(),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // color: isDarkMode ? Colors.grey.shade800 : Colors.white,
            ),
            child: Icon(icon, color: color, size: size * 0.5),
          ),
        ),
      ),
    );
  }

  void _showShareOptions(BuildContext context, MatchResult profile) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Share ${profile.name}'s profile",
              style: TextStyle(
                color: isDarkMode ? Colors.white : AppColors.textPrimaryLight,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(
                Icons.person,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              title: Text(
                "Share profile info",
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                //implement sharing service
                // later
              },
            ),
            ListTile(
              leading: Icon(
                Icons.photo,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              title: Text(
                "Share current photo",
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                //implement sharing service
                // later
              },
            ),
            ListTile(
              leading: Icon(
                Icons.photo_library,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              title: Text(
                "View all photos",
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, RouteNames.matchDetails);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPhotoShareOptions(
    BuildContext context,
    MatchResult profile,
    int currentImage,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Photo Options",
              style: TextStyle(
                color: isDarkMode ? Colors.white : AppColors.textPrimaryLight,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(
                Icons.share,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              title: Text(
                "Share this photo",
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                //implement sharing service
                // later
              },
            ),
            ListTile(
              leading: Icon(
                Icons.person,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              title: Text(
                "View profile details",
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, RouteNames.matchDetails);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.close,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              title: Text(
                "Cancel",
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
