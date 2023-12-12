import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_bubbles/bubbles/bubble_normal_image.dart';
import 'package:chat_bubbles/bubbles/bubble_special_one.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:social_media_recorder/screen/social_media_recorder.dart';
import 'package:truck/models/messages/audio_message_model.dart';
import 'package:truck/models/messages/file_message_model.dart';
import 'package:truck/models/messages/image_message_module.dart';
import 'package:truck/models/messages/text_message_model.dart';
import 'package:truck/views/helpers/utils/globals.dart';
import 'package:truck/views/helpers/utils/methods.dart';
import 'package:truck/views/helpers/wait.dart';
import 'package:truck/views/helpers/wrong.dart';
import 'package:voice_message_package/voice_message_package.dart';

class ChatRoom extends StatefulWidget {
  const ChatRoom({super.key});

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final String _uid = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController _inputController = TextEditingController();
  final GlobalKey<State> _sendButtonKey = GlobalKey<State>();

  late final List<Map<String, dynamic>> _attachments;
  late final List<Map<String, dynamic>> _deletions;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _attachments = <Map<String, dynamic>>[
      <String, dynamic>{"icon": FontAwesome.image, "title": "Pictures", "callback": _handleImageSelection},
      <String, dynamic>{"icon": FontAwesome.file, "title": "Files", "callback": _handleFileSelection},
      <String, dynamic>{"icon": FontAwesome.leaf, "title": "Cancel", "callback": () => Navigator.pop(context)},
    ];
    _deletions = <Map<String, dynamic>>[
      <String, dynamic>{
        "icon": Icons.delete_forever,
        "title": "REMOVE",
        "callback": (BuildContext context, QueryDocumentSnapshot<Map<String, dynamic>> doc) async {
          await doc.reference.delete();
          // ignore: use_build_context_synchronously
          showSnack("Message Deleted", 1);
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
        }
      },
      <String, dynamic>{"icon": FontAwesome.leaf, "title": "CANCEL", "callback": () => Navigator.pop(context)},
    ];
    super.initState();
  }

  Future<void> _handleAttachmentPressed() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: SizedBox(
          height: 145,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  for (final Map<String, dynamic> item in _attachments)
                    InkWell(
                      hoverColor: transparent,
                      splashColor: transparent,
                      highlightColor: transparent,
                      onTap: () {
                        item["callback"]();
                        Navigator.pop(context);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(item["icon"], size: 15, color: teal),
                          const SizedBox(height: 10),
                          Text(item["title"], style: const TextStyle(color: teal, fontSize: 16, fontWeight: FontWeight.w400)),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              SocialMediaRecorder(
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
                backGroundColor: transparent,
                recordIcon: const Icon(FontAwesome.microphone, color: teal, size: 20),
                maxRecordTimeInSecond: 120,
                sendRequestFunction: (File soundFile, String time) async {
                  try {
                    final String id = List<int>.generate(20, (int index) => Random().nextInt(10)).join();
                    await FirebaseStorage.instance.ref().child("/voices/$id").putFile(soundFile).then(
                      (TaskSnapshot snap) async {
                        final AudioMessageModel message = AudioMessageModel(
                          author: <String, dynamic>{"uid": _uid, "name": "Truck", "imageUrl": ""},
                          createdAt: DateTime.now().millisecondsSinceEpoch,
                          id: id,
                          name: id,
                          size: await soundFile.length(),
                          uri: await snap.ref.getDownloadURL(),
                          duration: timeStringToDuration(time),
                        );
                        await FirebaseFirestore.instance.collection("chats").doc(_uid).collection("messages").add(message.toJson());
                      },
                    );
                  } catch (e) {
                    // ignore: use_build_context_synchronously
                    showSnack(e.toString(), 3);
                  }
                },
              ),
            ],
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
          final FileMessageModel message = FileMessageModel(
            author: <String, dynamic>{"uid": _uid, "name": "Truck", "imageUrl": ""},
            createdAt: DateTime.now().millisecondsSinceEpoch,
            id: id,
            mimeType: lookupMimeType(result.files.single.path!)!,
            name: result.files.single.name,
            size: result.files.single.size,
            uri: await snap.ref.getDownloadURL(),
          );
          await FirebaseFirestore.instance.collection("chats").doc(_uid).collection("messages").add(message.toJson());
        },
      );
    }
  }

  void _handleImageSelection() async {
    final XFile? result = await ImagePicker().pickImage(imageQuality: 70, source: ImageSource.gallery);

    if (result != null) {
      final Uint8List bytes = await result.readAsBytes();
      final String id = List<int>.generate(20, (int index) => Random().nextInt(10)).join();
      await FirebaseStorage.instance.ref().child("/images/$id").putFile(File(result.path)).then(
        (TaskSnapshot snap) async {
          final ImageMessageModel message = ImageMessageModel(
            author: <String, dynamic>{"uid": _uid, "name": "Truck", "imageUrl": ""},
            createdAt: DateTime.now().millisecondsSinceEpoch,
            id: id,
            name: result.name,
            size: bytes.length,
            uri: await snap.ref.getDownloadURL(),
            mimeType: lookupMimeType(result.path)!,
          );
          await FirebaseFirestore.instance.collection("chats").doc(_uid).collection("messages").add(message.toJson());
          showSnack("Image Uploaded", 1);
        },
      );
    }
  }

  void _handleMessageTap(BuildContext context, message) async {
    if (message is FileMessageModel) {
      String localPath = message.uri;

      if (message.uri.startsWith('http')) {
        final Client client = Client();
        final Response request = await client.get(Uri.parse(message.uri));
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

  void _handleSendPressed() async {
    final textMessage = TextMessageModel(
      author: <String, dynamic>{"uid": _uid, "name": "Truck", "imageUrl": ""},
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: List<int>.generate(20, (int index) => Random().nextInt(10)).join(),
      text: _inputController.text.trim(),
    );
    _inputController.clear();
    await FirebaseFirestore.instance.collection("chats").doc(_uid).collection("messages").add(textMessage.toJson());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Column(
          children: <Widget>[
            Expanded(
              child: FirestoreListView(
                reverse: true,
                pageSize: 20,
                padding: const EdgeInsets.all(16),
                loadingBuilder: (BuildContext context) => const Wait(),
                query: FirebaseFirestore.instance.collection("chats").doc(FirebaseAuth.instance.currentUser!.uid).collection("messages").orderBy("createdAt", descending: true),
                emptyBuilder: (BuildContext context) => const Text("EMPTY"),
                errorBuilder: (BuildContext context, Object error, StackTrace stackTrace) => Wrong(errorMessage: error.toString()),
                itemBuilder: (BuildContext context, QueryDocumentSnapshot<Map<String, dynamic>> doc) {
                  final Map<String, dynamic> data = doc.data();
                  return GestureDetector(
                    onLongPress: () async {
                      await showModalBottomSheet<void>(
                        context: context,
                        builder: (BuildContext context) => SafeArea(
                          child: SizedBox(
                            height: 145,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                for (final Map<String, dynamic> item in _deletions)
                                  InkWell(
                                    hoverColor: transparent,
                                    splashColor: transparent,
                                    highlightColor: transparent,
                                    onTap: () {
                                      item["title"] == "REMOVE" ? item["callback"](context, doc) : item["callback"]();
                                    },
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(item["icon"], size: 15, color: teal),
                                        const SizedBox(height: 10),
                                        Text(item["title"], style: const TextStyle(color: teal, fontSize: 16, fontWeight: FontWeight.w400)),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    child: (data["type"] == "text")
                        ? BubbleSpecialOne(
                            text: data["text"],
                            isSender: data["author"]["uid"] == _uid,
                            color: teal,
                            textStyle: const TextStyle(fontSize: 16, color: white, fontWeight: FontWeight.w400),
                          )
                        : (data["type"] == "image")
                            ? BubbleNormalImage(
                                id: data["id"],
                                isSender: data["author"]["uid"] == _uid,
                                image: CachedNetworkImage(imageUrl: data["uri"], width: 200, height: 150),
                                color: teal,
                                tail: true,
                                delivered: true,
                              )
                            : (data["type"] == "audio")
                                ? VoiceMessageView(
                                    backgroundColor: transparent,
                                    activeSliderColor: white,
                                    circlesColor: teal,
                                    notActiveSliderColor: transparent,
                                    size: 29,
                                    controller: VoiceController(
                                      audioSrc: data["uri"],
                                      maxDuration: Duration(milliseconds: data["duration"]),
                                      isFile: false,
                                      onComplete: () {},
                                      onPause: () {},
                                      onPlaying: () {},
                                    ),
                                    innerPadding: 4,
                                  )
                                : const Text("data"),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(width: .3, color: teal),
                boxShadow: <BoxShadow>[BoxShadow(color: teal.withOpacity(.1), blurStyle: BlurStyle.outer, offset: const Offset(-3, -3))],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: _handleAttachmentPressed,
                    icon: const Icon(FontAwesome.folder_plus, size: 15, color: teal),
                  ),
                  Flexible(
                    child: TextField(
                      controller: _inputController,
                      onChanged: (String value) {
                        if (_inputController.text.trim().length <= 1) {
                          _sendButtonKey.currentState!.setState(() {});
                        }
                      },
                      decoration: const InputDecoration(border: InputBorder.none, hintText: "Type something..."),
                    ),
                  ),
                  StatefulBuilder(
                    key: _sendButtonKey,
                    builder: (BuildContext context, void Function(void Function()) _) {
                      return AnimatedOpacity(
                        opacity: _inputController.text.trim().isEmpty ? 0 : 1,
                        duration: 500.ms,
                        child: IconButton(
                          onPressed: _inputController.text.trim().isEmpty ? null : _handleSendPressed,
                          icon: const Icon(FontAwesome.paper_plane, size: 15, color: teal),
                        ),
                      );
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
