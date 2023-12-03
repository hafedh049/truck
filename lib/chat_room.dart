import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';

class ChatRoom extends StatefulWidget {
  const ChatRoom({super.key});

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final ChatController _chatController = ChatController(initialMessageList: initialMessageList, scrollController: scrollController, chatUsers: chatUsers);
  @override
  void initState() {
    // TODO: implement initState
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
