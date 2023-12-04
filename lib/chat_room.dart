import 'dart:async';

import 'package:chatview/chatview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:truck/utils/data.dart';
import 'package:truck/utils/themes.dart';
import 'package:uuid/uuid.dart';

class ChatRoom extends StatefulWidget {
  const ChatRoom({super.key});
  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  late final Timer _timer;

  int _noMessagesYet = 0;

  @override
  void initState() {
    _timer = Timer.periodic(1.seconds, (Timer timer) => _noMessagesYet == 60 ? Navigator.pop(context) : _noMessagesYet += 1);
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    _chatController.dispose();
    super.dispose();
  }

  AppTheme theme = DarkTheme();
  bool isDarkTheme = true;
  final currentUser = ChatUser(id: '1', name: 'Flutter', profilePhoto: Data.profileImage);
  final _chatController = ChatController(
    initialMessageList: Data.messageList,
    scrollController: ScrollController(),
    chatUsers: <ChatUser>[ChatUser(id: '0', name: 'Discord', profilePhoto: Data.profileImage)],
  );

  void _showHideTypingIndicator() {
    _chatController.setTypingIndicator = !_chatController.showTypingIndicator;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection("messages").snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasData) {
            _chatController.initialMessageList = snapshot.data!.docs.map(
              (QueryDocumentSnapshot<Map<String, dynamic>> e) {
                final Map<String, dynamic> data = e.data();
                data["createdAt"] = data["createdAt"].toDate();
                data["message_type"] = data["message_type"] == "text"
                    ? MessageType.text
                    : data["message_type"] == "image"
                        ? MessageType.image
                        : MessageType.voice;
                data["message_type"]["messageType"] = data["message_type"]["messageType"] == "text"
                    ? MessageType.text
                    : data["message_type"] == "image"
                        ? MessageType.image
                        : MessageType.voice;
                return Message.fromJson(data);
              },
            ).toList();
            _noMessagesYet = 0;
          }
          return ChatView(
            currentUser: currentUser,
            chatController: _chatController,
            onSendTap: _onSendTap,
            chatViewState: snapshot.hasError
                ? ChatViewState.error
                : snapshot.connectionState == ConnectionState.waiting
                    ? ChatViewState.loading
                    : _chatController.initialMessageList.isEmpty
                        ? ChatViewState.noData
                        : ChatViewState.hasMessages,
            chatViewStateConfig: ChatViewStateConfiguration(
              loadingWidgetConfig: ChatViewStateWidgetConfiguration(loadingIndicatorColor: theme.outgoingChatBubbleColor),
              onReloadButtonTap: () => setState(() {}),
            ),
            typeIndicatorConfig: TypeIndicatorConfiguration(flashingCircleBrightColor: theme.flashingCircleBrightColor, flashingCircleDarkColor: theme.flashingCircleDarkColor),
            appBar: ChatViewAppBar(
              elevation: theme.elevation,
              backGroundColor: theme.appBarColor,
              profilePicture: Data.profileImage,
              backArrowColor: theme.backArrowColor,
              chatTitle: "Discord",
              chatTitleTextStyle: TextStyle(color: theme.appBarTitleTextStyle, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 0.25),
              userStatus: "Online",
              userStatusTextStyle: const TextStyle(color: Colors.grey),
              actions: <IconButton>[
                IconButton(onPressed: _onThemeIconTap, icon: Icon(isDarkTheme ? Icons.brightness_4_outlined : Icons.dark_mode_outlined, color: theme.themeIconColor)),
                IconButton(tooltip: 'Toggle Typing Indicator', onPressed: _showHideTypingIndicator, icon: Icon(Icons.keyboard, color: theme.themeIconColor)),
              ],
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
              textFieldConfig: TextFieldConfiguration(
                onMessageTyping: (TypeWriterStatus status) {
                  debugPrint(status.toString());
                },
                compositionThresholdTime: 1.seconds,
                textStyle: TextStyle(color: theme.textFieldTextColor),
              ),
              micIconColor: theme.replyMicIconColor,
              voiceRecordingConfiguration: VoiceRecordingConfiguration(
                backgroundColor: theme.waveformBackgroundColor,
                recorderIconColor: theme.recordIconColor,
                waveStyle: WaveStyle(
                  showMiddleLine: false,
                  waveColor: theme.waveColor ?? Colors.white,
                  extendWaveform: true,
                ),
              ),
            ),
            chatBubbleConfig: ChatBubbleConfiguration(
              outgoingChatBubbleConfig: ChatBubble(
                linkPreviewConfig: LinkPreviewConfiguration(
                  backgroundColor: theme.linkPreviewOutgoingChatColor,
                  bodyStyle: theme.outgoingChatLinkBodyStyle,
                  titleStyle: theme.outgoingChatLinkTitleStyle,
                ),
                receiptsWidgetConfig: const ReceiptsWidgetConfig(showReceiptsIn: ShowReceiptsIn.all),
                color: theme.outgoingChatBubbleColor,
              ),
              inComingChatBubbleConfig: ChatBubble(
                linkPreviewConfig: LinkPreviewConfiguration(
                  linkStyle: TextStyle(color: theme.inComingChatBubbleTextColor, decoration: TextDecoration.underline),
                  backgroundColor: theme.linkPreviewIncomingChatColor,
                  bodyStyle: theme.incomingChatLinkBodyStyle,
                  titleStyle: theme.incomingChatLinkTitleStyle,
                ),
                textStyle: TextStyle(color: theme.inComingChatBubbleTextColor),
                onMessageRead: (Message message) {
                  /// send your message reciepts to the other client
                  debugPrint('Message Read');
                },
                senderNameTextStyle: TextStyle(color: theme.inComingChatBubbleTextColor),
                color: theme.inComingChatBubbleColor,
              ),
            ),
            replyPopupConfig: ReplyPopupConfiguration(backgroundColor: theme.replyPopupColor, buttonTextStyle: TextStyle(color: theme.replyPopupButtonColor), topBorderColor: theme.replyPopupTopBorderColor),
            reactionPopupConfig: ReactionPopupConfiguration(shadow: BoxShadow(color: isDarkTheme ? Colors.black54 : Colors.grey.shade400, blurRadius: 20), backgroundColor: theme.reactionPopupColor),
            messageConfig: MessageConfiguration(
              messageReactionConfig: MessageReactionConfiguration(
                backgroundColor: theme.messageReactionBackGroundColor,
                borderColor: theme.messageReactionBackGroundColor,
                reactedUserCountTextStyle: TextStyle(color: theme.inComingChatBubbleTextColor),
                reactionCountTextStyle: TextStyle(color: theme.inComingChatBubbleTextColor),
                reactionsBottomSheetConfig: ReactionsBottomSheetConfiguration(
                  backgroundColor: theme.backgroundColor,
                  reactedUserTextStyle: TextStyle(color: theme.inComingChatBubbleTextColor),
                  reactionWidgetDecoration: BoxDecoration(
                    color: theme.inComingChatBubbleColor,
                    boxShadow: <BoxShadow>[BoxShadow(color: isDarkTheme ? Colors.black12 : Colors.grey.shade200, offset: const Offset(0, 20), blurRadius: 40)],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              imageMessageConfig: ImageMessageConfiguration(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 15), shareIconConfig: ShareIconConfiguration(defaultIconBackgroundColor: theme.shareIconBackgroundColor, defaultIconColor: theme.shareIconColor)),
            ),
            profileCircleConfig: const ProfileCircleConfiguration(profileImageUrl: Data.profileImage),
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
    );
  }

  void _onSendTap(String message, ReplyMessage replyMessage, MessageType messageType) async {
    final String id = const Uuid().v8();
    await FirebaseFirestore.instance.collection("messages").add(
      <String, dynamic>{
        'id': id,
        'message': message,
        'createdAt': Timestamp.now(),
        'sendBy': "Flutter",
        'reply_message': <String, dynamic>{
          "messageId": '',
          "message": '',
          "replyTo": '',
          "replyBy": '',
          "messageType": "text",
          "voiceMessageDuration": 0,
        },
        'reaction': <String, dynamic>{
          'reactions': <String>[],
          'reactedUserIds': <String>[],
        },
        'message_type': "text",
        'voice_message_duration': 0,
        'status': "pending",
      },
    );

    Future.delayed(const Duration(milliseconds: 300), () => _chatController.initialMessageList.last.setStatus = MessageStatus.undelivered);
    Future.delayed(const Duration(seconds: 1), () => _chatController.initialMessageList.last.setStatus = MessageStatus.read);
  }

  void _onThemeIconTap() {
    setState(() {
      if (isDarkTheme) {
        theme = LightTheme();
        isDarkTheme = false;
      } else {
        theme = DarkTheme();
        isDarkTheme = true;
      }
    });
  }
}
