import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../..core/constants/color_constants.dart';
import '../models/icebreaker.dart';
import '../providers/icebreaker_provider.dart';

class IcebreakerSuggestionWidget extends StatefulWidget {
    final String matchId;
    final Function(String question) onSendIcebreaker;

    const IcebreakerSuggestionWidget({
        Key? key,
        required this.matchId,
        required this.onSendIcebreaker,
    }) : super(key: key);

    @override
    State<IcebreakerSuggestionWidget> createState() => _IcebreakerSuggestionWidgetState();
}

class _IcebreakerSuggestionWidgetState extends State<IcebreakerSuggestionWidget> {
    Icebreaker? _suggestedIcebreaker;
    bool _isLoading = true;

    @override
    void initState() {
        super.initState();
        _loadSuggestion ();
    }

    Future<void> _loadSuggestion() async{
        setState(() {
            _isLoading = true;
        });

        try{
            final provider = Provider.of<IcebreakerProvider>(context, listen:false);
            final suggestion = await provider.getSuggestedIcebreaker(widget.matchId);
            setState(() {
                _suggestedIcebreaker = suggestion;
                _isLoading = false;
            });
        } catch(e) {
            setState(() {
                _isLoading = false;
            });
        }
    }

    @override
    Widget build(BuildContext context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        if (_isLoading){
            return Container(
                padding: const EdgeInserts.all(16),
                decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                ), //BoxDecoration
                child: const Center(
                    child: SizedBox(
                        width:20,
                        height:20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                    ), // SizedBox
                ), //Center
            ); //Container
        }


        if (_suggestedIcebreaker == null){
            return Container(); //Container
        }

        return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1,
                ), //Border.all
            ), //BoxDecoration
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Row(
                        children:[
                            Icon(Icons.lightbulb_outline,
                            color: AppColors.primary,
                            size: 20,
                            ), //Icon
                            const SizedBox(width: 8),
                            Text(
                            'Icebreaker Suggestions',
                            style: TextStyle(
                                color: AppColors.primary,   
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                            ), //TextStyle
                        ), //Text
                        const Spacer(),
                        IconButton(
                            icon: const Icon(Icons.refresh, size: 18),
                            onPressed: _loadSuggestion,
                            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                            tooltip: 'Get another Suggestion',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                        ), //IconButton
                        ],
                    ), //Row
                    const SizedBox(height: 8),
                    Text(
                        _suggestedIcebreaker!.question,
                        style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontSize: 15,
                        ), //TextStyle
                    ), //Text
                    const SizedBox(height: 12),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            TextButton(
                                onPressed: () {
                                    widget.onSendIcebreaker(_suggestedIcebreaker!.question);
                                    _loadSuggestion();
                                },
                                child: const Text('Send'),
                            ), //TextButton
                        ],
                    ), //Row
                ],
            ),
        ); //Container
    }

}