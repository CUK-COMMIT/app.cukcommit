import "package:cuk_commit/core/enums/message_type.dart";

class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageType messageType;
  final DateTime timestamp;
  final bool isRead;
  final String? mediaUrl;
  final String? replyToId;
  final String? replyToContent;
  final String? replyToSenderId;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.mediaUrl,
    this.messageType = MessageType.text,
    this.replyToId,
    this.replyToContent,
    this.replyToSenderId,
  });

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    MessageType? messageType,
    DateTime? timestamp,
    bool? isRead,
    String? mediaUrl,
    String? replyToId,
    String? replyToContent,
    String? replyToSenderId,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      replyToId: replyToId ?? this.replyToId,
      replyToContent: replyToContent ?? this.replyToContent,
      replyToSenderId: replyToSenderId ?? this.replyToSenderId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'senderId' : senderId,
      'receiverId' : receiverId,
      'content' : content,
      'messageType' : MessageType.typeToString(messageType),
      'timestamp' : timestamp.millisecondsSinceEpoch,
      'isRead' : isRead,
      'mediaUrl' : mediaUrl,
      'replyToId' : replyToId,
      'replyToContent' : replyToContent,
      'replyToSenderId' : replyToSenderId,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      content: map['content'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      isRead: map['isRead'] ?? false,
      mediaUrl: map['mediaUrl'],
      messageType: map['messageType'] != null 
        ? MessageType.fromString(map['messageType'])
        : MessageType.text,
      replyToId: map['replyToId'],
      replyToContent: map['replyToContent'],
      replyToSenderId: map['replyToSenderId'],
    );
  }
}
