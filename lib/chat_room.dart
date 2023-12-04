import 'dart:async';

import 'package:chatview/chatview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

  final _profileImage = "https://raw.githubusercontent.com/SimformSolutionsPvtLtd/flutter_showcaseview/master/example/assets/simform.png";

  AppTheme theme = DarkTheme();
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
    // _chatController.dispose();
    super.dispose();
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
                data["reply_message"]["message_type"] = data["reply_message"]["message_type"] == "text"
                    ? MessageType.text
                    : data["reply_message"]["message_type"] == "image"
                        ? MessageType.image
                        : MessageType.voice;
                data["status"] = data["status"] == "pending" ? MessageStatus.pending : MessageStatus.undelivered;
                data["reply_message"]["voiceMessageDuration"] = Duration(milliseconds: data["reply_message"]["voiceMessageDuration"]);
                data["voice_message_duration"] = Duration(milliseconds: data["voice_message_duration"]);

                data["reaction"]['reactions'] = data["reaction"]['reactions'].cast<String>();
                data["reaction"]['reactedUserIds'] = data["reaction"]['reactedUserIds'].cast<String>();

                return Message.fromJson(data);
              },
            ).toList();
            _noMessagesYet = 0;
          }
          debugPrint("1");
          return ChatView(
            currentUser: _currentUser,
            chatController: _chatController,
            onSendTap: _onSendTap,
            chatViewState: snapshot.hasError
                ? ChatViewState.error
                : snapshot.connectionState == ConnectionState.waiting
                    ? ChatViewState.loading
                    : snapshot.data!.docs.isEmpty
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
            replyPopupConfig: ReplyPopupConfiguration(backgroundColor: theme.replyPopupColor, buttonTextStyle: TextStyle(color: theme.replyPopupButtonColor), topBorderColor: theme.replyPopupTopBorderColor),
            reactionPopupConfig: ReactionPopupConfiguration(shadow: const BoxShadow(color: Colors.black54, blurRadius: 20), backgroundColor: theme.reactionPopupColor),
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
                    boxShadow: const <BoxShadow>[BoxShadow(color: Colors.black12, offset: Offset(0, 20), blurRadius: 40)],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              imageMessageConfig: ImageMessageConfiguration(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 15), shareIconConfig: ShareIconConfiguration(defaultIconBackgroundColor: theme.shareIconBackgroundColor, defaultIconColor: theme.shareIconColor)),
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
    );
  }

  void _onSendTap(String message, ReplyMessage replyMessage, MessageType messageType) async {
    final String id = const Uuid().v8();
    await FirebaseFirestore.instance.collection("messages").add(
      <String, dynamic>{
        'id': id,
        'message': message,
        'createdAt': Timestamp.now(),
        'sendBy': "1",
        'reply_message': <String, dynamic>{"id": '', "message": '', "replyTo": '', "replyBy": '', "message_type": "text", "voiceMessageDuration": 0},
        'reaction': <String, dynamic>{'reactions': [], 'reactedUserIds': []},
        'message_type': "text",
        'voice_message_duration': 0,
        'status': "pending",
      },
    );

    /* Future.delayed(const Duration(milliseconds: 1), () => _chatController.initialMessageList.last.setStatus = MessageStatus.undelivered);
    Future.delayed(const Duration(seconds: 2), () => _chatController.initialMessageList.last.setStatus = MessageStatus.read);*/
  }
}
