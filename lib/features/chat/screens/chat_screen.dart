// features/chat/screens
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dating_application/core/constants/color_constants.dart';
import 'package:flutter_dating_application/features/chat/models/chat_message.dart';
import 'package:flutter_dating_application/features/chat/models/chat_room.dart';
import 'package:flutter_dating_application/features/chat/providers/chat_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:intl/intl.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

class ChatScreen extends StatefulWidget {
  final ChatRoom chatRoom;
  //chat_list_screen.dart
  
  // child :InKWell(
  // //navigate to chat screen with the chatroom object
    //   onTap: () {
    //     Navigator.push(
    //       context,
    //       RouteNames.chat,
    //       arguments: chatRoom,
    //     );

  const ChatScreen({super.key, required this.chatRoom});

  @override
 State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  bool _isComposing = false;
  bool _showIcebreakerSuggestion = false;
  bool _isReplying = false;
  bool _showEmojiPicker = false;
  FocusNode _messageFocusNode = FocusNode();
  Map<String, VideoPlayerController> _videoControllers = {};
  ChatMessage? _replyToMessage;

  @override
  void initState() {
    super.initState();
    // Initialize the media handler

    // Load messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).loadMessages(widget.chatRoom.id);
    });
    // add listener to focus node to hide emoji picker when keyboard is shown
    _messageFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_messageFocusNode.hasFocus) {
      setState(() {
        _showEmojiPicker = false;
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final chatProvider = Provider.of<ChatProvider>(context);
    final messages = chatProvider.getMessagesForChatRoom(widget.chatRoom.id);

    //scroll to bottom when messages change
    WidgetsBinding.instance.addPostFrameCallback((_){
      _scrollToBottom();
    });
    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios, 
            color: isDarkMode ? Colors.white : Colors.greyshade800,
            size:20,
          ),// icon 
        ),//iconButton
        title: Row(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: Image.asset(
                      widget.chatRoom.matchImage,
                      fit: BoxFit.cover,
                    ), //Image.asset
                  ), //SizedBox
                ), //ClipRRect
                if (widget.chatRoom.isMatchOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                          width: 2,
                        ), //Border.all
                      ), //BoxDecoration
                    ), //Container
                  ), //Positioned
              ],
            ), //Stack

            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chatRoom.matchName,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.textPrimaryLight,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ), //TextStyle
                ), //Text
                Text(
                  widget.chatRoom.isMatchOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: widget.chatRoom.isMatchOnline ? Colors.green : (isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
                    fontSize: 12,
                  ), //TextStyle
                ), //Text
              ],
            ), //Column
          ],
        ), //Row
        actions: [
          IconButton(
            onPressed: () {
              // show options menu
            }, icon: Icon(
              Icons.more_vert,
              color: isDarkMode ? Colors.white : Colors.grey.shade800,
            ), //Icon
          ), //IconButton
        ],
      ),//AppBar
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: chatProvider.isLoading 
              ? Center(child: CircularProgressIndicator())
              : messages.isEmpty 
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 60,
                      color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400,
                    ), //Icon
                    const SizedBox(height: 16),
                    Text(
                      'No messages yet',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                      ), //TextStyle
                    ), //Text
                    const SizedBox(height: 8),
                    Text(
                      'Say hi to ${widget.chatRoom.matchName}!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
                      ), //TextStyle
                    ), //Text
                  ],
                ), //column
              ), //Center
              : ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                    vertical: 20, 
                    horizontal: 16
                    ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == chatProvider.currentUser.id;
                    final showDate = index == 0 || 
                    !_isSameDay(
                      messages[index - 1].timestamp,
                      message.timestamp
                      );
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (showDate)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                ), //BoxDecoration
                                child: Text(
                                  _formatMessageDate(message.timestamp),
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                                    fontSize: 12,
                                  ), //TextStyle
                                ), //Text
                              ), //Container
                            ), //Center
                          ), //Padding
                          _buildMessgeItem(message, isMe, isDarkMode),
                        ChatMessageBubble(
                          message: message,
                          isMe: isMe,
                          isDarkMode: isDarkMode,
                          videoController: message.type == MessageType.video
                              ? _videoControllers[message.id]
                              : null,
                          onInitVideoController: (controller) {
                            setState(() {
                              _videoControllers[message.id] = controller;
                            });
                          },
                        ), //ChatMessageBubble
                      ],
                    ); //Column
                  },
                ), //ListView.builder
        ),// Expanded

        //Icebreaker Suggestion
        if (_showIcebreakerSuggestion)
        Padding(padding: EdgeInsets.symmetric(horizontal:16, vertical:8),
        child: IcebreakerSuggetionWidget(
          matchId: widget.chatRoom.id.matchId,
          onSendIcebreaker: (question) {
            _handleSubmitted(question);
            setState(() {
              _showIcebreakerSuggestion = false;
            });
          },
        ), //IcebreakerSuggetionWidget
        ),// padding

        // reply preview
        _buildReplyPreview(),
        // message input
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey.shade900 : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 5,
                offset: Offset(0, -1),
              ), //BoxShadow
            ], //BoxShadow
          ), //BoxDecoration
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children:[
              //Emoji button
              IconButton(
                onPressed: (){
                  //toggle emoji picker
                },
                icon: Icon(_showEmojiPicker? Icons.keyboard: Icons.emoji_emotions_outlined,
                color: AppColors.primary),
              ),//IconButton

              //icebreaker suggestion button
              IconButton(
                onPressed: (){
                  //toggle icebreaker suggestion
                },
                tooltip: 'Get Icebreaker Suggestions',
                icon: Icon(
                  Icons.lightbulb_outline,
                color: _showIcebreakerSuggestion ? AppColors.primary : Colors.grey),
              ),//IconButton

              // attachment button
              IconButton(
                onPressed: (){
                  //show attachment Options
                },
                icon: Icon(Icons.attach_file),
                color: AppColors.primary
              ),//IconButton

              //Text input field
              Expanded (
                child: TextField(
                  controller: _messageController,
                  focusNode: _messageFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide.none,
                    ), //OutlineInputBorder
                    filled: true,
                    fillColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ), //InputDecoration
                  onChanged: (text){
                    setState(() {
                      _isComposing = text.isNotEmpty;
                    });
                  },
                ), //TextField
              ), //Expanded

              //Send button
              IconButton(
                onPressed: _isComposing ? _sendMessage : null,
                color: _isComposing ? AppColors.primary : Colors.grey,
                icon: Icon(Icons.send),
              ), //IconButton
            ],
          ), //Row
        ), //Container

        // emoji picker
        if(_showEmojiPicker) _buildEmojiPicker(),

        ],
      ),//Column
    ); //Scaffold
  }

  void _sendMessage(){
    final text = _messageController.text.trim();
    if(text.isEmpty) return;

    final content = _messageController.text.train();
    _messageController.clear();
   
    setState(() {
      _isComposing = false;
    });

    if(_isReplying && _replyToMessage != null){
     //send as reply 
     Provider.of<ChatProvider>(context, listen: false).sendReplyMessage(
      widget.chatRoom.id,
      _replyToMessage!,
      content,
     );

     //reset reply state
     setState(() {
      _isReplying = false;
      _replyToMessage = null;
     });
    }
    else{
      //send as normal message
      Provider.of<ChatProvider>(context, listen: false).sendMessage(
        content,
        listen: false,
      ).sendMessage(widget.chatRoom.id, content);
    }

    //scroll to bottom after sending 
    WidgetBinding.insance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _onEmojiSelected(Emoji emoji){
    final text = _messageController.text;
    final textSelection = _messageController.selection;
    final newText = text.replaceRange(textSelection.start, textSelection.end, emoji.emoji);
    
    final newSelection = TextSelection.collapsed(offset: textSelection.start + emoji.emoji.length);

    setState(() {
      _messageController.text = newText;
      _messageController.selection = newSelection;
      _isComposing = _messageController.text.isNotEmpty;
    });
  }

  Widget _buildEmojiPicker(){
    return SizedBox(
      height: 300,
      child: EmojiPicker(
        onBackspacePressed: _closeEmojiPicker,
        onEmojiSelected: (category,emoji){
          _onEmojiSelected(emoji);
        },
        config: Config(
          emojiViewConfig: EmojiViewConfig(
            columns: 7,
            emojiSizeMax: 32,
            verticalSpacing: 0,
            horizontalSpacing: 0,
            gridPadding: EdgeInsets.zero,
          ), //EmojiViewConfig
          categoryViewConfig: CategoryViewConfig(
            indicatorColor: AppColors.primary,
            initCategory: Category.RECENT,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            iconColor: Colors.grey,
            iconColorSelected: AppColors.primary,
            tabIndicatorAnimaDuration: kTabScrollDuration,
            categoryIcons: CategoryIcons(),
            
          ), //CategoryViewConfig
          bottomActionBarConfig: BottomActionBarConfig(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            buttonColor: AppColors.primary,
          ), //BottomActionBarConfig
          skinToneViewConfig: SkinToneViewConfig(
            dialogBackgroundColor: Colors.white,
            indicatorColor: Colors.grey,
          ), //SkinToneViewConfig
          
        )
      ),
    );
  }
  void _closeEmojiPicker(){
    setState(() {
      _showEmojiPicker = false;
    });
  }

  Widget _buildReplyPreview() {
    if(!_isReplying || _replyToMessage == null){
      return SizedBox.shrink();
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isMyMessage = _replyToMessage!.senderId == Provider.of<ChatProvider>(context, listen: false).currentUserId;
    
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
        border: Border(
          left: BorderSide(
            color: AppColors.primary,
            width: 4,
          ), //BorderSide
        ), //Border
      ), //BoxDecoration
      child: Row(
        children: [
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isMyMessage ? 'You' : widget.chatRoom.matchName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isMyMessage ? AppColors.primary : Colors.grey.shade700,
                  fontSize: 12,
                ), //TextStyle
              ), //Text
              const SizedBox(height: 4),
              if(_replyToMessage!.type == MessageType.text)
              Text(
                _replyToMessage!.text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                  fontSize: 14,
                ), //TextStyle
              ), //Text
              else if(_replyToMessage!.type == MessageType.image)
              Row(
                children: [
                  Icon(
                    Icons.image,
                    size: 16,
                    color: Colors.grey.shade600,
                  ), //Icon
                  const SizedBox(width: 4),
                  Text(
                    'Photo',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                    ), //TextStyle
                  ), //Text
                ], //children
              ), //Row
              else if(_replyToMessage!.type == MessageType.video)
              Row(
                children: [
                  Icon(
                    Icons.videocam,
                    size: 16,
                    color: Colors.grey.shade600,
                  ), //Icon
                  const SizedBox(width: 4),
                  Text(
                    'Video',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                ), //TextStyle
              ), //Text
            ],
          ), // row
      ],
    ), // column
    ),  //Expanded
          IconButton(
            onPressed: () {
             // cancel reply
            }, icon:Icon(Icons.close),
            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
            iconSize: 20,
            ), //IconButton
        ],
      ), //Row
    );
  }
  
  void _handleSubmitted(String text) {
    if(text.trim().isEmpty){
      return;
    }
    
    _messageController.add();
    setState(() {
      _isComposing = false;
    });
    //send message
    Provider.of<ChatProvider>(context, listen: false).addMessage(widget.chatRoom.id, text);

    //scroll to bottom after sending
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  Widget _buildMessgeItem( ChatMessage message, bool isMe, bool isDarkMode) {
    return Padding(
      padding: EdgeInserts.symmetric(vertical: 4, horizontal:16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) _buildAvatar(isDarkMode),
          const SizedBox(width: 8),
          Flexible(
            child: GestureDetector(
              onLongPress: () {
                // show reply UI
              },
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAligment.end : CrossAxisAlignment.start,
                children: [
                  //show reply content if this is a reply message
                  if (message.replyTold != null)
                  _buildReplyContent(message, isMe, isDarkMode),

                  //show the actual message content based on type
                  if(message.messageType == MessageType.text)
                    _buildTextMessage(message, isMe, isDarkMode)
                  else if (message.messageType == MessageType.image)
                    _buildImageMessage(message, isMe, isDarkMode)

                  else if(message.messageType == MessageType.vedio)
                    _buildVideoMessaage(message, isMe, isDarkMode),


                  //show timestamp
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: isMe ? _buildMessageStatus(message, isDarkMode) : Text(
                      DateFormat('h:mm a').format(message.timestamp),
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
                        fontSize: 10,
                        ),//TextStyle
                    ), //Text
                  ), //Padding
                ],
              ), //Column
            ), //GestureDetector
          ), //Flexible
        ],
      )
     );
  }

  Widget _buildMessageStatus(ChatMessage message, bool isDarkMode){
    final statusColor = isDarkMode ? Colors.blue.shade400 : Colors.grey.shade600;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children:[
        Icon(
          message.isReal ? Icons.done_all : Icons.done,
          size: 16,
          color: statusColor, 
        ), //Icon
        const SizedBox(width: 4),
        Text(
          DateFormat('h:mm a').format(message.timestamp),
          style: TextStyle(
            color: statusColor,
            fontSize: 10,
          ), //TextStyle
        ), //Text
      ],
    );//Row
  }

  Widget _buildVideoMessage(ChatMessage message, bool isMe, bool isDarkMode){
    // initialize video controller if not already initialized
    if (!_videoControllers.containsKey(message.id)) {
      final controller = VideoPlayerController.file(File(message.mediaUrl!))
        controller.initialize().then((_) {
          setState((){});
        });
      _videoControllers[message.id] = controller;
    }

    final controller = _videoControllers[message.id]!;

    return GestureDetector(
      onTap: (){
        //navigate to full screen video player
      },
      child: Stack(
        alignent: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: isMe ? AppColors.primary : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
            ), //BoxDecoration
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12)
                  ), //BorderRadius.vertical
                  child: 
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: 300,
                    color: Colors.black,
                    child: controller.value.isInitialized
                      ? AspectRatio(
                          aspectRatio: controller.value.aspectRatio,
                          child: VideoPlayer(controller),
                        ) //AspectRatio
                      : Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ), //CircularProgressIndicator
                      ), //Center
                  ), //Container
                ), //ClipRRect
                if(message.content.isNotEmpty) //only show if caption exists
                Container(
                  width: MediaQuery.of(context).size.width * 0.6 - 20,
                  padding: EdgeInsets.all(10),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ), //TextStyle
                  ), //Text
                ), //Container
              ],
            ), //Column
          ), //Container
          if(controller.value.isInitialized)
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blackwithValues(alpha: 0.5),
              shape: BoxShape.circle,
            ), //BoxDecoration
            child: Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 30,
            ), //Icon
          ), //Container
        ],
      ),//Stack
    ); //GestureDetector
  }

  Widget _buildImageMessage(ChatMessage message, bool isMe, bool isDarkMode){
    return GestureDetector(
      onTap: (){
        // show full screen image viewer
      },
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12)
        ), //BoxDecoration
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(12)
                ), //BorderRadius.vertical
              child: 
              Image.file(
                File(message.mediaUrl!),
                width: MediaQuery.of(context).size.width * 0.6,
                height: 200,
                fit: BoxFit.cover,
              ), //Image.file
            ), //ClipRRect
            if(message.content.isNotEmpty) //only show if captaion exists
            Container(
              width: MediaQuery.of(context).size.width * 0.6 - 20,
              padding: EdgeInsets.all(10),
              child: Text(
                message.content,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontSize: 14,
                ), //TextStyle
              ), //Text
            ), //Container
          ],
        ), 
      ),
      
    ); //Container
  }

  Widget _buildTextMessage(ChatMessage message, bool isMe, bool isDarkMode){ 
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal:16),
      decoration: BoxDecoration(
        color: isMe ? AppColors.primary : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
        borderRadius: BorderRadius.circular(18).copyWith(
          bottomLeft: isMe ? null : Radius.circular(0),
          bottomRight: isMe ? Radius.circular(0) : null,
        ), 
      ), //BoxDecoration
      child: Text(
        message.content,
        style: TextStyle(
          color: isMe ? Colors.white : (isDarkMode ? Colors.white : Colors.black),
          fontSize: 14,
        ), //TextStyle
      ), //Text
    ); //Container
  }
  
  Widget _buildReplyContent(ChatMessage message, bool isMe, bool isDarkMode){
    if (message.replyTold == null) return SizedBox.shrink();

    final isReplyToMe = 
      message.replyToSenderId ==
      Provider.of<ChatProvider>(context, listen: false).currentUserId;

    return GestureDetector(
      onTap: (){
        // scroll to the original message
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 4),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade800.withValues(alpha: 0.5) : Colors.grey.shade200.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(
              color:  AppColors.primary, width: 2
            ),
          ), //Border
        ), //BoxDecoration
        child: Column(
          crossAxisAlignment: CrossAxisAligment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.replay,
                  size: 14,
                  color: isReplyToMe ? AppColors.primary : (isDarkMode ? Colors.grey.shade400 :Colors.grey.shade600)
                ), //Icon
                const SizedBox(width: 4),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(bool isDarkMode) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 32,
        height: 32,
        child: Image.asset(
        widget.chatRoom.matchImage,
        fit: BoxFit.cover,
      ), //image.asset
      ), //SizedBox
    ); //ClipRRect
  }

  String _formatMessageDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(date.year, date.month, date.day);
    final difference = now.difference(date);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}