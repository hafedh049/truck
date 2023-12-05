import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:chatview/chatview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:truck/utils/themes.dart';
import 'package:truck/wait.dart';
import 'package:truck/wrong.dart';

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



 _chatController.initialMessageList.clear();
                    for (QueryDocumentSnapshot<Map<String, dynamic>> e in streamSnapshot.data!.docs) {
                      final Map<String, dynamic> data = e.data();
                      data["createdAt"] = data["createdAt"].toDate();
                      if (data["message_type"] == "text") {
                        data["message_type"] = MessageType.text;
                      } else if (data["message_type"] == "image") {
                        data["message_type"] = MessageType.image;
                      } else {
                        data["message_type"] = MessageType.voice;
                        final String dir = (await getApplicationDocumentsDirectory()).path;
                        final File file = File('$dir/${Random().nextInt(4000)}');
                        final Response request = await get(Uri.parse(data["message"]));
                        final Uint8List bytes = request.bodyBytes;
                        await file.writeAsBytes(bytes);
                        data["message"] = file.path;
                      }
                      if (data['reply_message'] == null) {
                        data['reply_message'] = const ReplyMessage();
                      }
                      _chatController.addMessage(Message.fromJson(data));
                      Future.delayed(const Duration(milliseconds: 500), () => _chatController.initialMessageList.last.setStatus = MessageStatus.undelivered);
                      Future.delayed(const Duration(seconds: 1), () => _chatController.initialMessageList.last.setStatus = MessageStatus.read);
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
          stream: FirebaseFirestore.instance.collection("messages").orderBy("createdAt").snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> streamSnapshot) {
            if (streamSnapshot.hasData) {
              return FutureBuilder(
                future: (() async {
                  try {

                  } catch (e) {
                    debugPrint(e.toString());
                  }
                })(),
                builder: (BuildContext context, AsyncSnapshot futureSnapshot) {
                  return ChatView(
                    currentUser: _currentUser,
                    chatController: _chatController,
                    onSendTap: _onSendTap,
                    chatViewState: futureSnapshot.hasError
                        ? ChatViewState.error
                        : futureSnapshot.connectionState == ConnectionState.waiting
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
                          reactionWidgetDecoration: BoxDecoration(color: theme.inComingChatBubbleColor, boxShadow: const <BoxShadow>[BoxShadow(color: Colors.black12, offset: Offset(0, 20), blurRadius: 40)], borderRadius: BorderRadius.circular(10)),
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
              );
            } else if (streamSnapshot.connectionState == ConnectionState.waiting) {
              return const Wait();
            } else {
              return Wrong(errorMessage: streamSnapshot.error.toString());
            }
          },
        ),
      ),
    );
  }

  void _onSendTap(String message, ReplyMessage replyMessage, MessageType messageType) async {
    _chatController.setTypingIndicator = true;
    final String id = Random().nextInt(4000).toString();

    if (messageType == MessageType.image) {
      await FirebaseStorage.instance.ref().child("images/$id").putFile(File(message)).then((TaskSnapshot tasksnapshot) async => message = await tasksnapshot.ref.getDownloadURL());
    } else if (messageType == MessageType.voice) {
      await FirebaseStorage.instance.ref().child("voices/$id").putFile(File(message)).then((TaskSnapshot tasksnapshot) async => message = await tasksnapshot.ref.getDownloadURL());
    }

    await FirebaseFirestore.instance.collection("messages").add(
      <String, dynamic>{
        'id': id,
        'message': message,
        'createdAt': Timestamp.now(),
        'sendBy': "1",
        'message_type': messageType == MessageType.text
            ? "text"
            : messageType == MessageType.image
                ? "image"
                : "voice",
        'status': "pending",
      },
    );

    _chatController.setTypingIndicator = false;
  }
}
