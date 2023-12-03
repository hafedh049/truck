import 'package:chatview/chatview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      chatUsers: <ChatUser>[],
    );
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection("messages").snapshots(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
          return ChatView(
            chatController: _chatController,
            currentUser: ChatUser(id: "1", name: "Hafedh"),
            chatViewState: ChatViewState.loading,
          );
        },
      ),
    );
  }
}
