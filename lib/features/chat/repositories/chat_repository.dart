import '../models/chat_message.dart';
import '../models/chat_room.dart';

class ChatRepository {
  //this will be replaced with supabase later
  Future<List<ChatRoom>> getChatRooms(String userId) async {
    return [
      ChatRoom(
        id: '1',
        matchName: 'Alisha',
        userId: 'current_user',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        matchId: '1',
        matchImage:
            'https://images.unsplash.com/photo-1511485977113-f34c92461ad9?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=870&q=80',
        isMatchOnline: true,
        lastActivity: DateTime.now().subtract(const Duration(minutes: 2)),
        lastMessage: ChatMessage(
          id: 'm1',
          content: 'Hey, how are you doing?',
          timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
          senderId: '1',
          receiverId: 'current_user',
          isRead: false,
        ),
        unreadCount: 2,
      ),
      ChatRoom(
        id: '2',
        matchName: 'Ayush',
        userId: "current_user",
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        matchId: '3',
        matchImage:
            'https://images.unsplash.com/photo-1511485977113-f34c92461ad9?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=870&q=80',
        isMatchOnline: true,
        lastActivity: DateTime.now().subtract(const Duration(hours: 1)),
        lastMessage: ChatMessage(
          id: 'm2',
          content:
              'I would love spend a night with you, how about it? wanna go?',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          senderId: '3',
          receiverId: 'current_user',
          isRead: true,
        ),
        unreadCount: 0,
      ),
      ChatRoom(
        id: '3',
        matchName: 'John',
        userId: "current_user",
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        matchId: '4',
        matchImage:
            'https://images.unsplash.com/photo-1511485977113-f34c92461ad9?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=870&q=80',
        isMatchOnline: true,
        lastActivity: DateTime.now().subtract(const Duration(hours: 3)),
        lastMessage: ChatMessage(
          id: 'm3',
          content: 'So, friday night? At Wookings?',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          senderId: '4',
          receiverId: 'current_user',
          isRead: true,
        ),
        unreadCount: 0,
      ),
    ];
  }

  Future<List<ChatMessage>> getChatMessages(String chatRoomId) async {
    //simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    //mock data - will be replaced with supabase query

    if (chatRoomId == '1') {
      return [
        ChatMessage(
          id: "m1",
          senderId: "1",
          receiverId: "current_user",
          content: "Hey, how are you doing?",
          timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
          isRead: false,
        ),
        ChatMessage(
          id: "m1-1",
          senderId: "current_user",
          receiverId: "1",
          content: "I saw your profile and thought you were a great match",
          timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
          isRead: true,
        ),
      ];
    } else if (chatRoomId == '2') {
      return [
        ChatMessage(
          id: "m2",
          senderId: "2",
          receiverId: "current_user",
          content: "Hey, how are you doing?",
          timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
          isRead: false,
        ),
        ChatMessage(
          id: "m2-1",
          senderId: "current_user",
          receiverId: "2",
          content: "I saw your profile and thought you were a great match",
          timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
          isRead: true,
        ),
        ChatMessage(
          id: "m2-2",
          senderId: "2",
          receiverId: "current_user",
          content:
              "I would love spend a night with you, how about it? wanna go?",
          timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
          isRead: true,
        ),
      ];
    } else {
      return [
        ChatMessage(
          id: "m3",
          senderId: "3",
          receiverId: "current_user",
          content: "Hey, how are you doing?",
          timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
          isRead: false,
        ),
        ChatMessage(
          id: "m3-1",
          senderId: "current_user",
          receiverId: "3",
          content: "I saw your profile and thought you were a great match",
          timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
          isRead: true,
        ),
        ChatMessage(
          id: "m3-2",
          senderId: "3",
          receiverId: "current_user",
          content:
              "I would love spend a night with you, how about it? wanna go?",
          timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
          isRead: true,
        ),
      ];
    }
  }

  Future<void> sendMessage(ChatMessage message) async {
    //simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    //this is where you'll send the message to supabase
  }

  Future<void> markMessagesAsRead(String chatRoomId) async {
    //simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    //this is where you'll mark the message as read in supabase
  }

  Future<ChatRoom?> getChatRoomByMatchId(String userId, String matchId) async {
    //simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    //this is where you'll get the chat room from supabase
    //mock implementation
    final rooms = await getChatRooms(userId);
    return rooms.firstWhere(
      (room) => room.matchId == matchId,
      orElse: () => throw Exception('Chat room not found'),
    );
  }

  Future<ChatRoom> createChatRoom(ChatRoom chatRoom) async {
    //simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    //this is where you'll create the chat room in supabase
    return chatRoom;
  }

  Future<void> deleteChatRoom(String chatRoomId) async {
    //simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    //this is where you'll delete the chat room in supabase
    print("Chat room $chatRoomId deleted");

    //in real implementation
    //1. delete the chat room from the database
    //2. update chat settings or hide the chat
    //3. Potentially notify the other user or update thier chat view
  }

  Future<void> blockUser(String userId, String blockedUserId) async {
    //simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    //this is where you'll block the user in supabase
    print("User $userId blocked user $blockedUserId");

    //in real implementation
    //1. add the blocked user to the user's block list
    //2. update chat settings or hide the chat
    //3. Potentially notify the other user or update thier chat view
  }

  Future<void> reportUser(String userId, String reportedUserId, String reason) async {
    //simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    //this is where you'll report the user in supabase
    print("User $userId reported user $reportedUserId for $reason");

    //in real implementation
    //1. create a report record in the database
    //2. update chat settings or hide the chat
    //3. Potentially notify the other user and admins
  }

  Future<void> unblockUser(String userId, String blockedUserId) async {
    //simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    //this is where you'll unblock the user in supabase
    print("User $userId unblocked user $blockedUserId");

    //in real implementation
    //1. remove the blocked user from the user's block list
    //2. update chat settings or hide the chat
    //3. Potentially notify the other user or update thier chat view
  }

}
