import 'package:chatview/chatview.dart';
import 'package:flutter_animate/flutter_animate.dart';

class Data {
  static const profileImage = "https://raw.githubusercontent.com/SimformSolutionsPvtLtd/flutter_showcaseview/master/example/assets/simform.png";
  static final messageList = [
    Message(
      messageType: MessageType.text, reaction: Reaction(reactions: [], reactedUserIds: []), replyMessage: ReplyMessage(), voiceMessageDuration: 1.seconds,
      id: '1',
      message: "Hi!",
      createdAt: DateTime.now(),
      sendBy: '1', // userId of who sends the message
      status: MessageStatus.read,
    ),
    Message(
      id: '2',
      message: "Hi!",
      createdAt: DateTime.now(),
      sendBy: '0',
      status: MessageStatus.read,
    ),
  ];
}
