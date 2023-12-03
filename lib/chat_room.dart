import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';

class ChatRoom extends StatefulWidget {
  const ChatRoom({super.key});

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  late final ChatController _chatController;
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    _chatController = ChatController(
      initialMessageList: <Message>[],
      scrollController: _scrollController,
      chatUsers: <ChatUser>[
        ChatUser(id: id, name: name),
      ],
    );
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
