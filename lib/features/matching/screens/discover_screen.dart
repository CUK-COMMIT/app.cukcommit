import 'package:cuk_commit/features/matching/providers/matching_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  late PageController _imagePageController;
  int _currentImagePage = 0;

  @override
  void initState() {
    super.initState();
    _imagePageController = PageController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<MatchingProvider>().init();
    });
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matchingProvider = context.watch<MatchingProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Discover"),
        actions: [
          IconButton(
            onPressed:
                matchingProvider.isLoading ? null : matchingProvider.refreshMatches,
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: Builder(
        builder: (_) {
          if (matchingProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (matchingProvider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  matchingProvider.error!,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (matchingProvider.matches.isEmpty) {
            return const Center(child: Text("No matches found"));
          }

          final match = matchingProvider.matches.first;

          return Padding(
            padding: const EdgeInsets.all(14),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  // images
                  Expanded(
                    child: PageView.builder(
                      controller: _imagePageController,
                      itemCount: match.images.length,
                      onPageChanged: (i) => setState(() => _currentImagePage = i),
                      itemBuilder: (_, i) {
                        final url = match.images[i];

                        return Stack(
                          children: [
                            Positioned.fill(
                              child: Image.network(
                                url,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(Icons.broken_image, size: 40),
                                ),
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                              ),
                            ),

                            // gradient overlay
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.transparent, Colors.black54],
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      match.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 22,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "${match.department} • ${match.year}",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        );
                      },
                    ),
                  ),

                  // bio + actions
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          match.bio.isEmpty ? "No bio available." : match.bio,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () =>
                                    matchingProvider.dislikeProfile(match.id),
                                child: const Text("Dislike"),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () =>
                                    matchingProvider.likeProfile(match.id),
                                child: const Text("Like"),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed: () => matchingProvider.reportProfile(match.id),
                            icon: const Icon(Icons.report),
                            label: const Text("Report"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
