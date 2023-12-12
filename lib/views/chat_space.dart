/*import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:http/http.dart' as http;
import 'package:icons_plus/icons_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:social_media_recorder/audio_encoder_type.dart';
import 'package:social_media_recorder/screen/social_media_recorder.dart';
import 'package:truck/views/helpers/utils/globals.dart';
import 'package:truck/views/helpers/utils/methods.dart';
import 'package:truck/views/helpers/wait.dart';
import 'package:truck/views/helpers/wrong.dart';
import 'package:voice_message_package/voice_message_package.dart';

class ChatSpace extends StatefulWidget {
  const ChatSpace({super.key});

  @override
  State<ChatSpace> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatSpace> with WidgetsBindingObserver {
  List<types.Message> _messages = <types.Message>[];

  final DocumentReference<Map<String, dynamic>> _userDocRef = FirebaseFirestore.instance.collection("chats").doc(FirebaseAuth.instance.currentUser!.uid);
  final types.User _user = types.User(id: FirebaseAuth.instance.currentUser!.uid, firstName: "User", lastName: "Guenichi", imageUrl: "https://raw.githubusercontent.com/SimformSolutionsPvtLtd/flutter_showcaseview/master/example/assets/simform.png");

  late final List<Map<String, dynamic>> _attachments;

  late final Timer _timer;

  int _counter = 0;

  AppLifecycleState _state = AppLifecycleState.resumed;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(
      1.seconds,
      (Timer _) {
        if (_state == AppLifecycleState.resumed) {
          _counter += 1;
        }
        if (_counter >= 60) {
          Navigator.pop(context);
        }
      },
    );
    _attachments = <Map<String, dynamic>>[
      <String, dynamic>{"icon": FontAwesome.image, "title": "Pictures", "callback": _handleImageSelection},
      <String, dynamic>{"icon": FontAwesome.file, "title": "Files", "callback": _handleFileSelection},
      <String, dynamic>{"icon": FontAwesome.leaf, "title": "Cancel", "callback": () => Navigator.pop(context)},
    ];
    super.initState();
  }

  @override
  dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached || state == AppLifecycleState.hidden || state == AppLifecycleState.inactive || state == AppLifecycleState.paused || state == AppLifecycleState.resumed) {
      _state = state;
      _counter = 0;
    }
  }

  Future<void> _handleAttachmentPressed() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: SizedBox(
          height: 145,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                for (final Map<String, dynamic> item in _attachments)
                  InkWell(
                    hoverColor: transparent,
                    splashColor: transparent,
                    highlightColor: transparent,
                    onTap: item["callback"],
                    child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[Icon(item["icon"], size: 15, color: teal), const SizedBox(height: 10), Text(item["title"], style: const TextStyle(color: teal, fontSize: 16, fontWeight: FontWeight.w400))]),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleFileSelection() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);

    if (result != null && result.files.single.path != null) {
      final String id = List<int>.generate(20, (int index) => Random().nextInt(10)).join();

      await FirebaseStorage.instance.ref().child("/files/$id").putFile(File(result.files.single.path!)).then(
        (TaskSnapshot snap) async {
          final types.FileMessage message = types.FileMessage(author: _user, createdAt: DateTime.now().millisecondsSinceEpoch, id: id, mimeType: lookupMimeType(result.files.single.path!), name: result.files.single.name, size: result.files.single.size, uri: await snap.ref.getDownloadURL());
          await _userDocRef.collection("messages").add(message.toJson());
        },
      );
    }
  }

  void _handleImageSelection() async {
    final XFile? result = await ImagePicker().pickImage(imageQuality: 70, maxWidth: 1440, source: ImageSource.gallery);

    if (result != null) {
      final Uint8List bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);
      final String id = List<int>.generate(20, (int index) => Random().nextInt(10)).join();
      await FirebaseStorage.instance.ref().child("/images/$id").putFile(File(result.path)).then(
        (TaskSnapshot snap) async {
          final types.ImageMessage message = types.ImageMessage(author: _user, createdAt: DateTime.now().millisecondsSinceEpoch, height: image.height.toDouble(), id: id, name: result.name, size: bytes.length, uri: await snap.ref.getDownloadURL(), width: image.width.toDouble());
          await _userDocRef.collection("messages").add(message.toJson());
        },
      );
    }
  }

  void _handleMessageTap(BuildContext context, types.Message message) async {
    if (message is types.FileMessage) {
      String localPath = message.uri;

      if (message.uri.startsWith('http')) {
        final http.Client client = http.Client();
        final http.Response request = await client.get(Uri.parse(message.uri));
        final Uint8List bytes = request.bodyBytes;
        final String documentsDir = (await getApplicationDocumentsDirectory()).path;
        localPath = '$documentsDir/${message.name}';

        if (!File(localPath).existsSync()) {
          final File file = File(localPath);
          await file.writeAsBytes(bytes);
        }
      }
      await OpenFilex.open(localPath);
    }
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(author: _user, createdAt: DateTime.now().millisecondsSinceEpoch, id: List<int>.generate(20, (int index) => Random().nextInt(10)).join(), text: message.text);
    _userDocRef.collection("messages").add(textMessage.toJson());
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => _counter = 0,
        child: Scaffold(
          body: Column(
            children: <Widget>[
              const SizedBox(height: 30),
              Align(
                alignment: Alignment.centerLeft,
                child: SocialMediaRecorder(
                  slideToCancelText: '',
                  slideToCancelTextStyle: const TextStyle(color: white, fontSize: 16, fontWeight: FontWeight.w400),
                  cancelTextStyle: const TextStyle(color: white, fontSize: 16, fontWeight: FontWeight.w400),
                  counterTextStyle: const TextStyle(color: white, fontSize: 16, fontWeight: FontWeight.w400),
                  recordIconBackGroundColor: transparent,
                  recordIconWhenLockBackGroundColor: transparent,
                  recordIconWhenLockedRecord: const Icon(FontAwesome.stop, color: teal, size: 20),
                  counterBackGroundColor: transparent,
                  lockButton: const Icon(FontAwesome.microphone, color: teal, size: 20),
                  sendButtonIcon: const Icon(FontAwesome.microphone, color: teal, size: 20),
                  cancelTextBackGroundColor: transparent,
                  encode: AudioEncoderType.AAC,
                  backGroundColor: transparent,
                  recordIcon: const Icon(FontAwesome.microphone, color: teal, size: 20),
                  maxRecordTimeInSecond: 120,
                  sendRequestFunction: (File soundFile, String time) async {
                    try {
                      _counter = 0;
                      final String id = List<int>.generate(20, (int index) => Random().nextInt(10)).join();
                      await FirebaseStorage.instance.ref().child("/voices/$id").putFile(soundFile).then(
                        (TaskSnapshot snap) async {
                          final types.AudioMessage message = types.AudioMessage(author: _user, createdAt: DateTime.now().millisecondsSinceEpoch, id: id, name: id, size: await soundFile.length(), uri: await snap.ref.getDownloadURL(), duration: timeStringToDuration(time));
                          await _userDocRef.collection("messages").add(message.toJson());
                        },
                      );
                      _counter = 0;
                    } catch (e) {
                      _counter = 0;
                      // ignore: use_build_context_synchronously
                      showSnack(e.toString(), 3, context);
                    }
                  },
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _userDocRef.collection("messages").orderBy("createdAt", descending: true).limit(20).snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                    if (snapshot.hasData) {
                      _messages = snapshot.data!.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> e) => types.Message.fromJson(e.data())).toList();

                      return Chat(
                        userAgent: "ME",
                        typingIndicatorOptions: TypingIndicatorOptions(typingUsers: <types.User>[_user]),
                        textMessageOptions: TextMessageOptions(
                          onLinkPressed: (String link) {
                            _counter = 0;
                          },
                        ),
                        inputOptions: InputOptions(onTextChanged: (String text) => _counter = 0, onTextFieldTap: () => _counter = 0),
                        onEndReached: () async {},
                        scrollPhysics: const ClampingScrollPhysics(),
                        onAvatarTap: (types.User user) => _counter = 0,
                        onBackgroundTap: () => _counter = 0,
                        messages: _messages,
                        onAttachmentPressed: _handleAttachmentPressed,
                        onMessageTap: _handleMessageTap,
                        onSendPressed: _handleSendPressed,
                        showUserAvatars: true,
                        showUserNames: true,
                        isLastPage: false,
                        user: _user,
                        audioMessageBuilder: (types.AudioMessage audioMessage, {int? messageWidth}) {
                          return VoiceMessageView(
                            backgroundColor: transparent,
                            activeSliderColor: white,
                            circlesColor: teal,
                            notActiveSliderColor: transparent,
                            size: 29,
                            controller: VoiceController(audioSrc: audioMessage.uri, maxDuration: audioMessage.duration, isFile: false, onComplete: () => _counter = 0, onPause: () => _counter = 0, onPlaying: () => _counter = 0),
                            innerPadding: 4,
                          );
                        },
                        theme: const DarkChatTheme(seenIcon: Icon(FontAwesome.check_double, size: 15, color: teal)),
                      );
                    } else if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Wait();
                    } else {
                      return Wrong(errorMessage: snapshot.error.toString());
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      );
}
*/