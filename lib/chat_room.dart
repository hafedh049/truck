import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';

class ChatRoom extends StatefulWidget {
  const ChatRoom({super.key});

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  late final ChatController _chatController;

  @override
  void initState() {
    _chatController = ChatController(initialMessageList: initialMessageList, scrollController: scrollController, chatUsers: chatUsers);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChatView(
        chatController: chatController,
        currentUser: currentUser,
        chatViewState: chatViewState,
      ),
    );
  }
}
