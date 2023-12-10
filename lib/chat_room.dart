import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:chatview/chatview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:truck/home.dart';
import 'package:truck/utils/globals.dart';
import 'package:truck/utils/themes.dart';

class ChatRoom extends StatefulWidget {
  const ChatRoom({super.key});
  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  late final Timer _timer;

  int _noMessagesYet = 0;

  final _profileImage = "https://raw.githubusercontent.com/SimformSolutionsPvtLtd/flutter_showcaseview/master/example/assets/simform.png";

  final AppTheme _theme = DarkTheme();
  late final ChatUser _currentUser;
  late final ChatController _chatController;

  @override
  void initState() {
    _timer = Timer.periodic(1.seconds, (Timer timer) => _noMessagesYet == 60 ? Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => const Home())) : _noMessagesYet += 1);
    _currentUser = ChatUser(id: 'me', name: 'Truck-***', profilePhoto: _profileImage);
    _chatController = ChatController(initialMessageList: <Message>[], scrollController: ScrollController(), chatUsers: <ChatUser>[ChatUser(id: 'discord', name: 'Discord', profilePhoto: _profileImage)]);
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _noMessagesYet = 0;
      },
      child: Scaffold(
        body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection("trucks").doc(FirebaseAuth.instance.currentUser!.uid).snapshots(),
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> streamSnapshot) {
            if (streamSnapshot.hasData) {
              _chatController.initialMessageList.clear();
              if (streamSnapshot.data!.exists) {
                Map<String, dynamic> messages = streamSnapshot.data!.get("messages");
                for (final String key in messages.keys) {
                  _noMessagesYet = 0;
                  messages[key]["createdAt"] = messages[key]["createdAt"].toDate();
                  if (messages[key]["message_type"] == "text") {
                    messages[key]["message_type"] = MessageType.text;
                  } else if (messages[key]["message_type"] == "image") {
                    messages[key]["message_type"] = MessageType.image;
                  } else if (messages[key]["message_type"] == "voice") {
                    messages[key]["message_type"] = MessageType.voice;
                    final File file = File('$documentsPath/${List<int>.generate(19, (int _) => Random().nextInt(10)).join()}');
                    file.writeAsBytesSync(messages[key]["message"].cast<int>());
                    messages[key]["message"] = file.path;
                  } else {
                    messages[key]["message_type"] = MessageType.custom;
                    final File file = File('$documentsPath/${List<int>.generate(19, (int _) => Random().nextInt(10)).join()}');
                    file.writeAsBytesSync(messages[key]["message"].cast<int>());
                    messages[key]["message"] = file.path;
                  }
                  _chatController.initialMessageList.add(Message(status: MessageStatus.read, message: messages[key]["message"], createdAt: messages[key]["createdAt"], sendBy: messages[key]["sendBy"], messageType: messages[key]["message_type"], id: key));
                }
                _chatController.initialMessageList.sort((Message a, Message b) => a.createdAt.compareTo(b.createdAt));
                _chatController.messageStreamController.sink.add(_chatController.initialMessageList);
              }
            }
            return ChatView(
              onChatListTap: () => _noMessagesYet = 0,
              currentUser: _currentUser,
              chatController: _chatController,
              onSendTap: _onSendTap,
              chatViewState: streamSnapshot.hasError
                  ? ChatViewState.error
                  : streamSnapshot.connectionState == ConnectionState.waiting
                      ? ChatViewState.loading
                      : _chatController.initialMessageList.isEmpty
                          ? ChatViewState.noData
                          : ChatViewState.hasMessages,
              chatViewStateConfig: ChatViewStateConfiguration(loadingWidgetConfig: ChatViewStateWidgetConfiguration(loadingIndicatorColor: _theme.outgoingChatBubbleColor), onReloadButtonTap: () => setState(() {})),
              typeIndicatorConfig: TypeIndicatorConfiguration(flashingCircleBrightColor: _theme.flashingCircleBrightColor, flashingCircleDarkColor: _theme.flashingCircleDarkColor),
              appBar: ChatViewAppBar(
                elevation: _theme.elevation,
                backGroundColor: _theme.appBarColor,
                profilePicture: _profileImage,
                backArrowColor: _theme.backArrowColor,
                chatTitle: "Discord",
                chatTitleTextStyle: TextStyle(color: _theme.appBarTitleTextStyle, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 0.25),
                userStatusTextStyle: const TextStyle(color: Colors.grey),
              ),
              chatBackgroundConfig: ChatBackgroundConfiguration(
                messageTimeIconColor: _theme.messageTimeIconColor,
                messageTimeTextStyle: TextStyle(color: _theme.messageTimeTextColor),
                defaultGroupSeparatorConfig: DefaultGroupSeparatorConfiguration(textStyle: TextStyle(color: _theme.chatHeaderColor, fontSize: 17)),
                backgroundColor: _theme.backgroundColor,
              ),
              sendMessageConfig: SendMessageConfiguration(
                imagePickerIconsConfig: ImagePickerIconsConfiguration(cameraIconColor: _theme.cameraIconColor, galleryIconColor: _theme.galleryIconColor),
                replyMessageColor: _theme.replyMessageColor,
                defaultSendButtonColor: _theme.sendButtonColor,
                replyDialogColor: _theme.replyDialogColor,
                replyTitleColor: _theme.replyTitleColor,
                textFieldBackgroundColor: _theme.textFieldBackgroundColor,
                closeIconColor: _theme.closeIconColor,
                textFieldConfig: TextFieldConfiguration(
                  textStyle: TextStyle(color: _theme.textFieldTextColor),
                  onMessageTyping: (TypeWriterStatus status) {
                    _noMessagesYet = 0;
                  },
                ),
                micIconColor: _theme.replyMicIconColor,
                voiceRecordingConfiguration: VoiceRecordingConfiguration(backgroundColor: _theme.waveformBackgroundColor, recorderIconColor: _theme.recordIconColor, waveStyle: WaveStyle(showMiddleLine: false, waveColor: _theme.waveColor ?? Colors.white, extendWaveform: true)),
              ),
              chatBubbleConfig: ChatBubbleConfiguration(
                outgoingChatBubbleConfig: ChatBubble(
                  linkPreviewConfig: LinkPreviewConfiguration(backgroundColor: _theme.linkPreviewOutgoingChatColor, bodyStyle: _theme.outgoingChatLinkBodyStyle, titleStyle: _theme.outgoingChatLinkTitleStyle),
                  receiptsWidgetConfig: const ReceiptsWidgetConfig(showReceiptsIn: ShowReceiptsIn.all),
                  color: _theme.outgoingChatBubbleColor,
                ),
                inComingChatBubbleConfig: ChatBubble(
                  linkPreviewConfig: LinkPreviewConfiguration(linkStyle: TextStyle(color: _theme.inComingChatBubbleTextColor, decoration: TextDecoration.underline), backgroundColor: _theme.linkPreviewIncomingChatColor, bodyStyle: _theme.incomingChatLinkBodyStyle, titleStyle: _theme.incomingChatLinkTitleStyle),
                  textStyle: TextStyle(color: _theme.inComingChatBubbleTextColor),
                  senderNameTextStyle: TextStyle(color: _theme.inComingChatBubbleTextColor),
                  color: _theme.inComingChatBubbleColor,
                ),
              ),
              replyPopupConfig: ReplyPopupConfiguration(
                backgroundColor: _theme.replyPopupColor,
                buttonTextStyle: TextStyle(color: _theme.replyPopupButtonColor),
                topBorderColor: _theme.replyPopupTopBorderColor,
                onUnsendTap: (Message message) async {
                  _noMessagesYet = 0;
                  _chatController.setTypingIndicator = true;
                  await FirebaseFirestore.instance.collection("trucks").doc(FirebaseAuth.instance.currentUser!.uid).get().then(
                    (DocumentSnapshot<Map<String, dynamic>> value) {
                      final Map<String, dynamic> data = value.data()!["messages"];
                      data.remove(message);
                      value.reference.update(<String, dynamic>{"messages": data});
                    },
                  );
                  _chatController.setTypingIndicator = false;
                  _noMessagesYet = 0;
                },
              ),
              reactionPopupConfig: ReactionPopupConfiguration(userReactionCallback: (Message message, String emoji) {}, shadow: const BoxShadow(color: Colors.black54, blurRadius: 20), backgroundColor: _theme.reactionPopupColor),
              messageConfig: MessageConfiguration(
                messageReactionConfig: MessageReactionConfiguration(
                  backgroundColor: _theme.messageReactionBackGroundColor,
                  borderColor: _theme.messageReactionBackGroundColor,
                  reactedUserCountTextStyle: TextStyle(color: _theme.inComingChatBubbleTextColor),
                  reactionCountTextStyle: TextStyle(color: _theme.inComingChatBubbleTextColor),
                  reactionsBottomSheetConfig: ReactionsBottomSheetConfiguration(
                    backgroundColor: _theme.backgroundColor,
                    reactedUserTextStyle: TextStyle(color: _theme.inComingChatBubbleTextColor),
                    reactionWidgetDecoration: BoxDecoration(color: _theme.inComingChatBubbleColor, boxShadow: const <BoxShadow>[BoxShadow(color: Colors.black12, offset: Offset(0, 20), blurRadius: 40)], borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                imageMessageConfig: ImageMessageConfiguration(onTap: (String path) {}, margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 15), shareIconConfig: ShareIconConfiguration(defaultIconBackgroundColor: _theme.shareIconBackgroundColor, defaultIconColor: _theme.shareIconColor)),
              ),
              profileCircleConfig: ProfileCircleConfiguration(profileImageUrl: _profileImage),
              repliedMessageConfig: RepliedMessageConfiguration(
                backgroundColor: _theme.repliedMessageColor,
                verticalBarColor: _theme.verticalBarColor,
                repliedMsgAutoScrollConfig: RepliedMsgAutoScrollConfig(enableHighlightRepliedMsg: true, highlightColor: Colors.pinkAccent.shade100, highlightScale: 1.1),
                textStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: .25),
                replyTitleTextStyle: TextStyle(color: _theme.repliedTitleTextColor),
              ),
              swipeToReplyConfig: SwipeToReplyConfiguration(replyIconColor: _theme.swipeToReplyIconColor),
            );
          },
        ),
      ),
    );
  }

  void _onSendTap(String message, ReplyMessage replyMessage, MessageType messageType) async {
    _chatController.setTypingIndicator = true;
    _noMessagesYet = 0;
    final String id = List<int>.generate(19, (_) => Random().nextInt(10)).join();
    dynamic msg = message;
    if (messageType == MessageType.image) {
      await FirebaseStorage.instance.ref().child("images/$id").putFile(File(message)).then((TaskSnapshot tasksnapshot) async => msg = await tasksnapshot.ref.getDownloadURL());
    } else if (messageType == MessageType.voice) {
      msg = File(message).readAsBytesSync();
    } else if (messageType == MessageType.custom) {
      msg = File(message).readAsBytesSync();
    }

    _noMessagesYet = 0;
    await FirebaseFirestore.instance.collection("trucks").doc(FirebaseAuth.instance.currentUser!.uid).get().then(
      (DocumentSnapshot<Map<String, dynamic>> value) {
        if (value.exists) {
          final Map<String, dynamic> data = value.data()!["messages"];
          data.addAll(
            <String, dynamic>{
              id: <String, dynamic>{
                'message': msg,
                'createdAt': Timestamp.now(),
                'sendBy': "me",
                'message_type': messageType == MessageType.text
                    ? "text"
                    : messageType == MessageType.image
                        ? "image"
                        : "voice",
              },
            },
          );
          value.reference.update(<String, dynamic>{"messages": data});
          _noMessagesYet = 0;
        } else {
          final String channelID = List<int>.generate(19, (_) => Random().nextInt(10)).join();
          value.reference.set(
            <String, dynamic>{
              "channelID": channelID,
              "channelName": "truck-***",
              "messages": <String, dynamic>{
                id: <String, dynamic>{
                  'message': msg,
                  'createdAt': Timestamp.now(),
                  'sendBy': "me",
                  'message_type': messageType == MessageType.text
                      ? "text"
                      : messageType == MessageType.image
                          ? "image"
                          : "voice",
                },
              },
            },
          );
          _noMessagesYet = 0;
        }
      },
    );

    _chatController.setTypingIndicator = false;
  }
}
