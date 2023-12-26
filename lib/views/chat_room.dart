import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_bubbles/bubbles/bubble_normal_image.dart';
import 'package:chat_bubbles/bubbles/bubble_special_one.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:social_media_recorder/screen/social_media_recorder.dart';
import 'package:terrestra/models/messages/audio_message_model.dart';
import 'package:terrestra/models/messages/file_message_model.dart';
import 'package:terrestra/models/messages/image_message_module.dart';
import 'package:terrestra/models/messages/text_message_model.dart';
import 'package:terrestra/views/helpers/utils/globals.dart';
import 'package:terrestra/views/helpers/utils/methods.dart';
import 'package:terrestra/views/helpers/wait.dart';
import 'package:terrestra/views/helpers/wrong.dart';
import 'package:voice_message_package/voice_message_package.dart';

class ChatRoom extends StatefulWidget {
  const ChatRoom({super.key});

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> with WidgetsBindingObserver {
  final String _uid = userLocalSettings!.get("RUT");
  final TextEditingController _inputController = TextEditingController();
  final GlobalKey<State> _sendButtonKey = GlobalKey<State>();

  late final List<Map<String, dynamic>> _attachments;
  late final List<Map<String, dynamic>> _deletions;
  final List<VoiceController> _audios = <VoiceController>[];

  int _counter = 0;

  late final Timer _timer;

  AppLifecycleState _state = AppLifecycleState.resumed;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached || state == AppLifecycleState.hidden || state == AppLifecycleState.inactive || state == AppLifecycleState.paused || state == AppLifecycleState.resumed) {
      _state = state;
      _counter = 0;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final VoiceController voiceController in _audios) {
      if (voiceController.isPlaying) {
        voiceController.stopPlaying();
      }
      voiceController.dispose();
    }
    _audios.clear();
    _timer.cancel();
    _inputController.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    _counter = 0;
    super.deactivate();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(
      1.seconds,
      (Timer _) {
        if (_state == AppLifecycleState.resumed && context.mounted) {
          _counter += 1;
        }
        if (_counter >= 60) {
          Navigator.pop(context);
        }
        if (_counter >= 57) {
          showSnack(_counter.toString());
        }
      },
    );
    _attachments = <Map<String, dynamic>>[
      <String, dynamic>{"icon": FontAwesome.image, "title": "Pictures", "callback": _handleImageSelection},
      <String, dynamic>{"icon": FontAwesome.file, "title": "Files", "callback": _handleFileSelection},
      <String, dynamic>{"icon": FontAwesome.leaf, "title": "Cancel", "callback": () => Navigator.pop(context)},
    ];
    _deletions = <Map<String, dynamic>>[
      <String, dynamic>{
        "icon": Icons.delete_forever,
        "title": "REMOVE",
        "callback": (BuildContext context, QueryDocumentSnapshot<Map<String, dynamic>> doc, Map<String, dynamic> data) async {
          _counter = 0;
          if (data["type"] == "audio") {
            final int index = _audios.indexWhere((VoiceController element) => element.audioSrc == data['content']);
            if (_audios[index].isPlaying) {
              _audios[index].stopPlaying();
            }
            _audios[index].dispose();
            _audios.removeAt(index);
          }
          if (data["type"] == "audio" || data["type"] == "image" || data["type"] == "file") {
            await FirebaseStorage.instance.refFromURL(data["content"]).delete();
          }

          await doc.reference.delete();
          // ignore: use_build_context_synchronously
          showSnack("Message Deleted");
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
          _counter = 0;
        }
      },
      <String, dynamic>{"icon": FontAwesome.leaf, "title": "CANCEL", "callback": () => Navigator.pop(context)},
    ];
    super.initState();
  }

  Future<void> _handleAttachmentPressed() async {
    _counter = 0;
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
                        _counter = 0;
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(item["icon"], size: 15, color: accent1),
                          const SizedBox(height: 10),
                          Text(item["title"], style: const TextStyle(color: accent1, fontSize: 16, fontWeight: FontWeight.w400)),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              SocialMediaRecorder(
                slideToCancelText: '',
                slideToCancelTextStyle: const TextStyle(color: accent1, fontSize: 16, fontWeight: FontWeight.w400),
                cancelTextStyle: const TextStyle(color: accent1, fontSize: 16, fontWeight: FontWeight.w400),
                counterTextStyle: const TextStyle(color: accent1, fontSize: 16, fontWeight: FontWeight.w400),
                recordIconBackGroundColor: transparent,
                recordIconWhenLockBackGroundColor: transparent,
                recordIconWhenLockedRecord: const Icon(FontAwesome.stop, color: accent1, size: 20),
                counterBackGroundColor: transparent,
                lockButton: const Icon(FontAwesome.microphone, color: accent1, size: 20),
                sendButtonIcon: const Icon(FontAwesome.microphone, color: accent1, size: 20),
                cancelTextBackGroundColor: transparent,
                backGroundColor: transparent,
                recordIcon: const Icon(FontAwesome.microphone, color: accent1, size: 20),
                maxRecordTimeInSecond: 120,
                sendRequestFunction: (File soundFile, String time) async {
                  try {
                    _counter = 0;
                    final String id = List<int>.generate(20, (int index) => Random().nextInt(10)).join();
                    await FirebaseStorage.instance.ref().child("/audios/$id.aac").putFile(soundFile, SettableMetadata(contentType: lookupMimeType(soundFile.path)!)).then(
                      (TaskSnapshot snap) async {
                        final AudioMessageModel message = AudioMessageModel(
                          uid: _uid,
                          createdAt: DateTime.now().millisecondsSinceEpoch,
                          name: "$id.aac",
                          size: await soundFile.length(),
                          content: await snap.ref.getDownloadURL(),
                          duration: timeStringToDuration(time),
                          mimeType: lookupMimeType(soundFile.path)!,
                        );
                        _counter = 0;
                        await FirebaseFirestore.instance.collection("chats").doc(_uid).collection("messages").add(message.toJson());
                        _counter = 0;
                      },
                    );
                  } catch (e) {
                    _counter = 0;
                    // ignore: use_build_context_synchronously
                    showSnack(e.toString());
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
    _counter = 0;
  }

  void _handleFileSelection() async {
    _counter = 0;
    final FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.single.path != null) {
      final String id = List<int>.generate(20, (int index) => Random().nextInt(10)).join();
      await FirebaseStorage.instance.ref().child("/files/${id}__${result.files.single.name}").putFile(File(result.files.single.path!), SettableMetadata(contentType: lookupMimeType(result.files.single.path!)!)).then(
        (TaskSnapshot snap) async {
          _counter = 0;
          final FileMessageModel message = FileMessageModel(
            uid: _uid,
            createdAt: DateTime.now().millisecondsSinceEpoch,
            mimeType: lookupMimeType(result.files.single.path!)!,
            name: "${id}__${result.files.single.name}",
            size: result.files.single.size,
            content: await snap.ref.getDownloadURL(),
          );
          await FirebaseFirestore.instance.collection("chats").doc(_uid).collection("messages").add(message.toJson());
        },
      );
    }
    _counter = 0;
  }

  void _handleImageSelection() async {
    _counter = 0;
    final XFile? result = await ImagePicker().pickImage(imageQuality: 70, source: ImageSource.gallery);
    if (result != null) {
      final Uint8List bytes = await result.readAsBytes();
      final String id = List<int>.generate(20, (int index) => Random().nextInt(10)).join();
      await FirebaseStorage.instance.ref().child("/images/${id}__${result.name}").putFile(File(result.path), SettableMetadata(contentType: lookupMimeType(result.path)!)).then(
        (TaskSnapshot snap) async {
          _counter = 0;
          final ImageMessageModel message = ImageMessageModel(
            uid: _uid,
            createdAt: DateTime.now().millisecondsSinceEpoch,
            name: "${id}__${result.name}",
            size: bytes.length,
            content: await snap.ref.getDownloadURL(),
            mimeType: lookupMimeType(result.path)!,
          );
          await FirebaseFirestore.instance.collection("chats").doc(_uid).collection("messages").add(message.toJson());
          showSnack("Image Uploaded");
          _counter = 0;
        },
      );
    }
    _counter = 0;
  }

  void _handleMessageTap(Map<String, dynamic> message) async {
    _counter = 0;
    if (message['type'] == "file") {
      String localPath = message['content'];
      if (message['content'].startsWith('http')) {
        final Client client = Client();
        final Response request = await client.get(Uri.parse(message['content']));
        final Uint8List bytes = request.bodyBytes;
        final String documentsDir = (await getApplicationDocumentsDirectory()).path;
        localPath = '$documentsDir/${message['name']}';

        if (!File(localPath).existsSync()) {
          final File file = File(localPath);
          await file.writeAsBytes(bytes);
        }
      }
      await Clipboard.setData(ClipboardData(text: message['content']));
      showSnack("File URL Copied To Clipboard");
      await OpenFilex.open(localPath);
    } else if (message['type'] == "text") {
      await Clipboard.setData(ClipboardData(text: message['content']));
      showSnack("Text Copied To Clipboard");
    } else if (message['type'] == "image") {}
    _counter = 0;
  }

  void _handleSendPressed() async {
    _counter = 0;
    final textMessage = TextMessageModel(uid: _uid, createdAt: DateTime.now().millisecondsSinceEpoch, content: _inputController.text.trim());
    _inputController.clear();
    _sendButtonKey.currentState!.setState(() {});
    _counter = 0;
    await FirebaseFirestore.instance.collection("chats").doc(_uid).collection("messages").add(textMessage.toJson());
    _counter = 0;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        _counter = 0;
      },
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Expanded(
                  child: FirestoreListView(
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    loadingBuilder: (BuildContext context) => const Wait(),
                    query: FirebaseFirestore.instance.collection("chats").doc(_uid).collection("messages").orderBy("createdAt", descending: true),
                    emptyBuilder: (BuildContext context) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          LottieBuilder.asset("assets/lotties/empty.json", width: 200, height: 200),
                          const SizedBox(height: 10),
                          const Text("NO CHAT YET", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: accent1)),
                        ],
                      ),
                    ),
                    errorBuilder: (BuildContext context, Object error, StackTrace stackTrace) => Wrong(errorMessage: error.toString()),
                    itemBuilder: (BuildContext context, QueryDocumentSnapshot<Map<String, dynamic>> doc) {
                      final Map<String, dynamic> data = doc.data();
                      _counter = 0;
                      if (data["type"] == "audio") {
                        _audios.add(
                          VoiceController(
                            audioSrc: data["content"],
                            maxDuration: Duration(milliseconds: data["duration"]),
                            isFile: false,
                            onComplete: () => _counter = 0,
                            onPause: () => _counter = 0,
                            onPlaying: () => _counter = 0,
                          ),
                        );
                      }
                      return GestureDetector(
                        onTap: () {
                          _handleMessageTap(data);
                          _counter = 0;
                        },
                        onLongPress: data['uid'] != _uid
                            ? null
                            : () async {
                                _counter = 0;
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
                                                item["title"] == "REMOVE" ? item["callback"](context, doc, data) : item["callback"]();
                                                _counter = 0;
                                              },
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Icon(item["icon"], size: 15, color: accent1),
                                                  const SizedBox(height: 10),
                                                  Text(item["title"], style: const TextStyle(color: accent1, fontSize: 16, fontWeight: FontWeight.w400)),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                                _counter = 0;
                              },
                        child: (data["type"] == "text")
                            ? BubbleSpecialOne(
                                text: data["content"],
                                isSender: data["uid"] == _uid,
                                color: accent1,
                                textStyle: const TextStyle(fontSize: 16, color: accent1, fontWeight: FontWeight.w400),
                              )
                            : (data["type"] == "image")
                                ? BubbleNormalImage(
                                    id: doc.id,
                                    isSender: data["uid"] == _uid,
                                    image: CachedNetworkImage(imageUrl: data["content"], width: 200, height: 350, fit: BoxFit.cover),
                                    color: accent1,
                                    onTap: () async {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (BuildContext context) => Scaffold(
                                            body: Stack(
                                              children: <Widget>[
                                                InteractiveViewer(
                                                  alignment: Alignment.center,
                                                  minScale: 1,
                                                  child: Image.network(
                                                    data['content'],
                                                    fit: BoxFit.cover,
                                                    width: MediaQuery.sizeOf(context).width,
                                                    height: MediaQuery.sizeOf(context).height,
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 36,
                                                  child: IconButton(
                                                    onPressed: () => Navigator.pop(context),
                                                    icon: const Icon(FontAwesome.chevron_left, size: 20, color: accent1),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                      await Clipboard.setData(ClipboardData(text: data['content']));
                                      showSnack("Image URL Copied To Clipboard");
                                    },
                                  )
                                : (data["type"] == "audio")
                                    ? Align(
                                        alignment: data["uid"] == _uid ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
                                        child: VoiceMessageView(
                                          isSender: data["uid"] == _uid,
                                          backgroundColor: transparent,
                                          activeSliderColor: accent1,
                                          circlesColor: accent1,
                                          notActiveSliderColor: transparent,
                                          size: 29,
                                          controller: _audios.last,
                                          innerPadding: 4,
                                        ),
                                      )
                                    : Align(
                                        alignment: data["uid"] == _uid ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
                                        child: Container(
                                          width: MediaQuery.sizeOf(context).width * .7,
                                          padding: const EdgeInsets.all(16),
                                          margin: const EdgeInsets.symmetric(vertical: 8),
                                          decoration: BoxDecoration(
                                            color: accent1,
                                            borderRadius: BorderRadius.only(
                                              topLeft: const Radius.circular(15),
                                              bottomRight: Radius.circular(data["uid"] == _uid ? 0 : 15),
                                              bottomLeft: Radius.circular(data["uid"] == _uid ? 15 : 0),
                                              topRight: const Radius.circular(15),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              const Icon(FontAwesome.file, size: 15, color: accent1),
                                              const SizedBox(width: 10),
                                              Flexible(child: Text(data["name"])),
                                            ],
                                          ),
                                        ),
                                      ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(width: .3, color: accent1),
                    boxShadow: <BoxShadow>[BoxShadow(color: accent1.withOpacity(.1), blurStyle: BlurStyle.outer, offset: const Offset(-3, -3))],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5),
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      IconButton(onPressed: _handleAttachmentPressed, icon: const Icon(FontAwesome.folder_plus, size: 15, color: accent1)),
                      Flexible(
                        child: TextField(
                          controller: _inputController,
                          onChanged: (String value) {
                            _counter = 0;
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
                          _counter = 0;
                          return AnimatedOpacity(
                            opacity: _inputController.text.trim().isEmpty ? 0 : 1,
                            duration: 500.ms,
                            child: IconButton(
                              onPressed: _inputController.text.trim().isEmpty ? null : _handleSendPressed,
                              icon: const Icon(FontAwesome.paper_plane, size: 15, color: accent1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 36,
              child: IconButton(
                onPressed: () {
                  if (_counter < 60) {
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(FontAwesome.chevron_left, size: 20, color: accent1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
