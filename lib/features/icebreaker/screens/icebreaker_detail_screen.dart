import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cuk_commit/features/icebreaker/models/icebreaker.dart';
import 'package:cuk_commit/features/icebreaker/providers/icebreaker_provider.dart';

class IcebreakerDetailScreen extends StatefulWidget {
  final Icebreaker icebreaker;

  const IcebreakerDetailScreen({
    super.key,
    required this.icebreaker,
  });

  @override
  State<IcebreakerDetailScreen> createState() =>
      _IcebreakerDetailScreenState();
}

class _IcebreakerDetailScreenState
    extends State<IcebreakerDetailScreen> {
  final TextEditingController _answerController =
      TextEditingController();

  bool _isSubmitting = false;
  bool _isPublic = true;

  @override
  void initState() {
    super.initState();

    // pre-fill with existing answer if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<IcebreakerProvider>(context, listen: false);

      final answer =
          provider.userAnswers(widget.icebreaker.id) ?? [];

      if (answer.isNotEmpty) {
        _answerController.text = answer.first.answerText;
        setState(() {
          _isPublic = answer.first.isPublic;
        });
      }
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode =
        theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Icebreaker'),
        backgroundColor:
            theme.appBarTheme.backgroundColor,
        foregroundColor:
            theme.appBarTheme.foregroundColor,
        elevation: theme.appBarTheme.elevation,
      ),
      body: Consumer<IcebreakerProvider>(
        builder: (context, provider, child) {
          final answer =
              provider.userAnswers(widget.icebreaker.id) ??
                  [];
          final hasAnswered = answer.isNotEmpty;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // Question Card
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius:
                        BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary
                            .withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(20),
                    child: Padding(
                      padding:
                          const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: theme
                                  .colorScheme.onPrimary
                                  .withValues(
                                      alpha: 0.2),
                              borderRadius:
                                  BorderRadius.circular(
                                      30),
                              border: Border.all(
                                color: theme
                                    .colorScheme.onPrimary
                                    .withValues(
                                        alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              widget.icebreaker.category
                                  .toUpperCase(),
                              style: TextStyle(
                                color: theme
                                    .colorScheme.onPrimary,
                                fontSize: 12,
                                fontWeight:
                                    FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Difficulty Stars
                          Row(
                            children: List.generate(
                              5,
                              (index) => Padding(
                                padding:
                                    const EdgeInsets.only(
                                        left: 2),
                                child: Icon(
                                  index <
                                          widget.icebreaker
                                              .difficulty
                                      ? Icons.star_rounded
                                      : Icons
                                          .star_border_rounded,
                                  color: index <
                                          widget.icebreaker
                                              .difficulty
                                      ? Colors.amber
                                      : theme
                                          .colorScheme
                                          .onPrimary
                                          .withValues(
                                              alpha: 0.3),
                                  size: 18,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Question Text
                          Text(
                            widget.icebreaker.question,
                            style: TextStyle(
                              color: theme
                                  .colorScheme.onPrimary,
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.bold,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Tags
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: widget
                                .icebreaker.tags
                                .map(
                                  (tag) => Container(
                                    padding:
                                        const EdgeInsets
                                            .symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration:
                                        BoxDecoration(
                                      color: theme
                                          .colorScheme
                                          .onPrimary
                                          .withValues(
                                              alpha: 0.15),
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                                  20),
                                    ),
                                    child: Text(
                                      '#$tag',
                                      style: TextStyle(
                                        color: theme
                                            .colorScheme
                                            .onPrimary,
                                        fontSize: 12,
                                        fontWeight:
                                            FontWeight
                                                .w500,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Answer Section
                AnimatedOpacity(
                  opacity: 1.0,
                  duration:
                      const Duration(milliseconds: 500),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.edit_note_rounded,
                            color:
                                theme.colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Your Answer',
                            style: theme
                                .textTheme.titleLarge
                                ?.copyWith(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: isDarkMode
                                  ? Colors.black
                                      .withValues(
                                          alpha: 0.1)
                                  : Colors.grey
                                      .withValues(
                                          alpha: 0.1),
                              blurRadius: 10,
                              offset:
                                  const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _answerController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText:
                                'Type your answer here...',
                            filled: true,
                            fillColor: isDarkMode
                                ? Colors.grey.shade900
                                : Colors.grey.shade50,
                            border:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                      16),
                              borderSide: BorderSide(
                                color: theme
                                    .colorScheme.primary,
                                width: 1.5,
                              ),
                            ),
                            contentPadding:
                                const EdgeInsets.all(20),
                          ),
                          style: theme
                              .textTheme.bodyLarge
                              ?.copyWith(
                            height: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Privacy Toggle
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.grey
                                  .withValues(alpha: 0.5)
                              : Colors.grey.shade100,
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isPublic
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: _isPublic
                                  ? theme
                                      .colorScheme.primary
                                  : theme
                                      .colorScheme
                                      .onBackground
                                      .withValues(
                                          alpha: 0.5),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Make answer visible to matches',
                              ),
                            ),
                            Switch(
                              value: _isPublic,
                              onChanged: (value) {
                                setState(() {
                                  _isPublic = value;
                                });
                              },
                              activeColor:
                                  theme.colorScheme.primary,
                              activeTrackColor: theme
                                  .colorScheme.primary
                                  .withValues(alpha: 0.3),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () => _submitAnswer(
                                  context, provider),
                          child: _isSubmitting
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child:
                                      CircularProgressIndicator(
                                    color: theme
                                        .colorScheme
                                        .onPrimary,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,
                                  children: [
                                    Icon(
                                      hasAnswered
                                          ? Icons.update
                                          : Icons
                                              .check_circle,
                                      size: 20,
                                    ),
                                    const SizedBox(
                                        width: 8),
                                    Text(
                                      hasAnswered
                                          ? 'Update Answer'
                                          : 'Save Answer',
                                      style:
                                          const TextStyle(
                                        fontSize: 16,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _submitAnswer(
    BuildContext context,
    IcebreakerProvider provider,
  ) async {
    if (_answerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please enter an answer before submitting.'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await provider.saveAnswer(
        widget.icebreaker.id,
        _answerController.text.trim(),
        isPublic: _isPublic,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Your answer has been saved successfully!'),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
