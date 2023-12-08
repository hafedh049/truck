import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:chatview/chatview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

  final AppTheme theme = DarkTheme();
  late final ChatUser _currentUser;
  late final ChatController _chatController;

  @override
  void initState() {
    _timer = Timer.periodic(1.seconds, (Timer timer) => _noMessagesYet == 60 ? Navigator.pop(context) : _noMessagesYet += 1);
    _currentUser = ChatUser(id: '1', name: 'Flutter', profilePhoto: _profileImage);
    _chatController = ChatController(initialMessageList: <Message>[], scrollController: ScrollController(), chatUsers: <ChatUser>[ChatUser(id: '0', name: 'Discord', profilePhoto: _profileImage)]);
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    //_chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        _noMessagesYet = 0;
      },
      child: Scaffold(
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance.collection("messages").doc(FirebaseAuth.instance.currentUser!.uid).snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> streamSnapshot) {
            if (streamSnapshot.hasData) {
              _chatController.initialMessageList.clear();
              for (QueryDocumentSnapshot<Map<String, dynamic>> e in streamSnapshot.data!.docs) {
                final Map<String, dynamic> data = e.data();
                data["createdAt"] = data["createdAt"].toDate();
                if (data["message_type"] == "text") {
                  data["message_type"] = MessageType.text;
                } else if (data["message_type"] == "image") {
                  data["message_type"] = MessageType.image;
                } else if (data["message_type"] == "voice") {
                  data["message_type"] = MessageType.voice;
                  final File file = File('$documentsPath/${Random().nextInt(4000)}');
                  file.writeAsBytesSync(data["message"].cast<int>());
                  data["message"] = file.path;
                }

                _chatController.addMessage(Message(message: data["message"], createdAt: data["createdAt"], sendBy: data["sendBy"], messageType: data["message_type"], id: data["id"]));
                Future.delayed(const Duration(milliseconds: 500), () => _chatController.initialMessageList.last.setStatus = MessageStatus.undelivered);
                Future.delayed(const Duration(seconds: 700), () => _chatController.initialMessageList.last.setStatus = MessageStatus.read);
              }
            }
            return ChatView(
              currentUser: _currentUser,
              chatController: _chatController,
              onSendTap: _onSendTap,
              chatViewState: streamSnapshot.hasError
                  ? ChatViewState.error
                  : streamSnapshot.connectionState == ConnectionState.waiting
                      ? ChatViewState.loading
                      : streamSnapshot.data!.docs.isEmpty
                          ? ChatViewState.noData
                          : ChatViewState.hasMessages,
              chatViewStateConfig: ChatViewStateConfiguration(loadingWidgetConfig: ChatViewStateWidgetConfiguration(loadingIndicatorColor: theme.outgoingChatBubbleColor), onReloadButtonTap: () => setState(() {})),
              typeIndicatorConfig: TypeIndicatorConfiguration(flashingCircleBrightColor: theme.flashingCircleBrightColor, flashingCircleDarkColor: theme.flashingCircleDarkColor),
              appBar: ChatViewAppBar(
                elevation: theme.elevation,
                backGroundColor: theme.appBarColor,
                profilePicture: _profileImage,
                backArrowColor: theme.backArrowColor,
                chatTitle: "Discord",
                chatTitleTextStyle: TextStyle(color: theme.appBarTitleTextStyle, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 0.25),
                userStatusTextStyle: const TextStyle(color: Colors.grey),
              ),
              chatBackgroundConfig: ChatBackgroundConfiguration(
                messageTimeIconColor: theme.messageTimeIconColor,
                messageTimeTextStyle: TextStyle(color: theme.messageTimeTextColor),
                defaultGroupSeparatorConfig: DefaultGroupSeparatorConfiguration(textStyle: TextStyle(color: theme.chatHeaderColor, fontSize: 17)),
                backgroundColor: theme.backgroundColor,
              ),
              sendMessageConfig: SendMessageConfiguration(
                imagePickerIconsConfig: ImagePickerIconsConfiguration(cameraIconColor: theme.cameraIconColor, galleryIconColor: theme.galleryIconColor),
                replyMessageColor: theme.replyMessageColor,
                defaultSendButtonColor: theme.sendButtonColor,
                replyDialogColor: theme.replyDialogColor,
                replyTitleColor: theme.replyTitleColor,
                textFieldBackgroundColor: theme.textFieldBackgroundColor,
                closeIconColor: theme.closeIconColor,
                textFieldConfig: TextFieldConfiguration(textStyle: TextStyle(color: theme.textFieldTextColor)),
                micIconColor: theme.replyMicIconColor,
                voiceRecordingConfiguration: VoiceRecordingConfiguration(backgroundColor: theme.waveformBackgroundColor, recorderIconColor: theme.recordIconColor, waveStyle: WaveStyle(showMiddleLine: false, waveColor: theme.waveColor ?? Colors.white, extendWaveform: true)),
              ),
              chatBubbleConfig: ChatBubbleConfiguration(
                outgoingChatBubbleConfig: ChatBubble(
                  linkPreviewConfig: LinkPreviewConfiguration(backgroundColor: theme.linkPreviewOutgoingChatColor, bodyStyle: theme.outgoingChatLinkBodyStyle, titleStyle: theme.outgoingChatLinkTitleStyle),
                  receiptsWidgetConfig: const ReceiptsWidgetConfig(showReceiptsIn: ShowReceiptsIn.all),
                  color: theme.outgoingChatBubbleColor,
                ),
                inComingChatBubbleConfig: ChatBubble(
                  linkPreviewConfig: LinkPreviewConfiguration(linkStyle: TextStyle(color: theme.inComingChatBubbleTextColor, decoration: TextDecoration.underline), backgroundColor: theme.linkPreviewIncomingChatColor, bodyStyle: theme.incomingChatLinkBodyStyle, titleStyle: theme.incomingChatLinkTitleStyle),
                  textStyle: TextStyle(color: theme.inComingChatBubbleTextColor),
                  senderNameTextStyle: TextStyle(color: theme.inComingChatBubbleTextColor),
                  color: theme.inComingChatBubbleColor,
                ),
              ),
              replyPopupConfig: ReplyPopupConfiguration(
                backgroundColor: theme.replyPopupColor,
                buttonTextStyle: TextStyle(color: theme.replyPopupButtonColor),
                topBorderColor: theme.replyPopupTopBorderColor,
                onUnsendTap: (Message message) {},
              ),
              reactionPopupConfig: ReactionPopupConfiguration(userReactionCallback: (Message message, String emoji) {}, shadow: const BoxShadow(color: Colors.black54, blurRadius: 20), backgroundColor: theme.reactionPopupColor),
              messageConfig: MessageConfiguration(
                messageReactionConfig: MessageReactionConfiguration(
                  backgroundColor: theme.messageReactionBackGroundColor,
                  borderColor: theme.messageReactionBackGroundColor,
                  reactedUserCountTextStyle: TextStyle(color: theme.inComingChatBubbleTextColor),
                  reactionCountTextStyle: TextStyle(color: theme.inComingChatBubbleTextColor),
                  reactionsBottomSheetConfig: ReactionsBottomSheetConfiguration(
                    backgroundColor: theme.backgroundColor,
                    reactedUserTextStyle: TextStyle(color: theme.inComingChatBubbleTextColor),
                    reactionWidgetDecoration: BoxDecoration(color: theme.inComingChatBubbleColor, boxShadow: const <BoxShadow>[BoxShadow(color: Colors.black12, offset: Offset(0, 20), blurRadius: 40)], borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                imageMessageConfig: ImageMessageConfiguration(onTap: (String path) {}, margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 15), shareIconConfig: ShareIconConfiguration(defaultIconBackgroundColor: theme.shareIconBackgroundColor, defaultIconColor: theme.shareIconColor)),
              ),
              profileCircleConfig: ProfileCircleConfiguration(profileImageUrl: _profileImage),
              repliedMessageConfig: RepliedMessageConfiguration(
                backgroundColor: theme.repliedMessageColor,
                verticalBarColor: theme.verticalBarColor,
                repliedMsgAutoScrollConfig: RepliedMsgAutoScrollConfig(enableHighlightRepliedMsg: true, highlightColor: Colors.pinkAccent.shade100, highlightScale: 1.1),
                textStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: .25),
                replyTitleTextStyle: TextStyle(color: theme.repliedTitleTextColor),
              ),
              swipeToReplyConfig: SwipeToReplyConfiguration(replyIconColor: theme.swipeToReplyIconColor),
            );
          },
        ),
      ),
    );
  }

  void _onSendTap(String message, ReplyMessage replyMessage, MessageType messageType) async {
    _chatController.setTypingIndicator = true;
    final String id = Random().nextInt(4000).toString();
    dynamic msg = message;
    if (messageType == MessageType.image) {
      await FirebaseStorage.instance.ref().child("images/$id").putFile(File(message)).then((TaskSnapshot tasksnapshot) async => msg = await tasksnapshot.ref.getDownloadURL());
    } else if (messageType == MessageType.voice) {
      msg = File(message).readAsBytesSync();
    }

    await FirebaseFirestore.instance.collection("messages").add(
      <String, dynamic>{
        'id': id,
        'message': msg,
        'createdAt': Timestamp.now(),
        'sendBy': "1",
        'message_type': messageType == MessageType.text
            ? "text"
            : messageType == MessageType.image
                ? "image"
                : "voice",
      },
    );

    _chatController.setTypingIndicator = false;
  }
}
