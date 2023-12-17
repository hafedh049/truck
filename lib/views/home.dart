import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:truck/models/messages/text_message_model.dart';
import 'package:truck/views/auth/sign_in.dart';
import 'package:truck/views/chat_room.dart';
import 'package:truck/views/helpers/utils/globals.dart';
import 'package:truck/views/helpers/utils/methods.dart';
import 'package:voice_message_package/voice_message_package.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FlutterTts _tts = FlutterTts();
  VoiceController? _voiceController;
  final GlobalKey<State> _voiceKey = GlobalKey<State>();
  late final StreamSubscription<QuerySnapshot<Map<String, dynamic>>> _notificationStream;
  final AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();

  @override
  void initState() {
    _notificationStream = FirebaseFirestore.instance.collection("chats").doc(userLocalSettings!.get("phone")).collection("messages").orderBy("createdAt", descending: true).limit(1).snapshots().listen(
      (QuerySnapshot<Map<String, dynamic>> event) async {
        if (event.docs.isNotEmpty && event.docs.first.get("uid") != userLocalSettings!.get("phone")) {
          InAppNotification.show(
            child: Container(
              width: MediaQuery.sizeOf(context).width * .98,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(color: gray, borderRadius: BorderRadius.circular(5)),
              child: const Center(child: Text("New Message")),
            ),
            context: context,
            onTap: () {},
          );
          assetsAudioPlayer.open(Audio("assets/notification.wav"));
        }
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    _notificationStream.cancel();
    _tts.stop();
    if (_voiceController != null) {
      if (_voiceController!.isPlaying) {
        _voiceController!.stopPlaying();
      }
      _voiceController!.dispose();
    }
    super.dispose();
  }

  bool _isAudio = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            StatefulBuilder(
              key: _voiceKey,
              builder: (BuildContext context, void Function(void Function()) setS) {
                return GestureDetector(
                  onTap: () async {
                    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection("chats").doc(userLocalSettings!.get("phone")).collection("messages").orderBy("createdAt", descending: true).limit(1).get();
                    if (snapshot.docs.isNotEmpty) {
                      final List<QueryDocumentSnapshot<Map<String, dynamic>>> messages = snapshot.docs;
                      if (messages.isNotEmpty) {
                        if (messages.first.get("type") == "text") {
                          await _tts.speak(messages.first.get("content"));
                        } else if (messages.first.get("type") == "audio") {
                          _isAudio = true;
                          _voiceController = VoiceController(
                            audioSrc: messages.first.get("content"),
                            maxDuration: Duration(milliseconds: messages.first.get("duration")),
                            isFile: false,
                            onComplete: () => setS(() => _isAudio = false),
                            onPause: () {},
                            onPlaying: () {},
                          )..play();

                          setS(() {});
                        } else if (messages.first.get("type") == "image") {
                          await _tts.speak("LAST MESSAGE IS AN IMAGE");
                        } else {
                          await _tts.speak("LAST MESSAGE IS AN ATTACHMENT");
                        }
                      } else {
                        showSnack("No messages yet.");
                      }
                    }
                  },
                  child: _isAudio
                      ? VoiceMessageView(
                          isSender: true,
                          backgroundColor: transparent,
                          activeSliderColor: white,
                          circlesColor: teal,
                          notActiveSliderColor: transparent,
                          size: 29,
                          controller: _voiceController!,
                          innerPadding: 4,
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: teal.withOpacity(.5),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: const <BoxShadow>[BoxShadow(blurStyle: BlurStyle.outer, color: gray, offset: Offset(4, 6))],
                          ),
                          padding: const EdgeInsets.all(24),
                          margin: const EdgeInsets.all(24),
                          child: const Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(Bootstrap.arrow_repeat),
                                SizedBox(width: 10),
                                Text("Repeat Last Message", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                );
              },
            ),
            GestureDetector(
              onTap: () async {
                await FirebaseFirestore.instance.collection("chats").doc(userLocalSettings!.get("phone")).collection("messages").add(
                      TextMessageModel(uid: userLocalSettings!.get("phone"), createdAt: DateTime.now().millisecondsSinceEpoch, content: "UNDERSTOOD").toJson(),
                    );
                // ignore: use_build_context_synchronously
                showSnack("Sent");
              },
              child: Container(
                decoration: BoxDecoration(color: teal.withOpacity(.5), borderRadius: BorderRadius.circular(15), boxShadow: const <BoxShadow>[BoxShadow(blurStyle: BlurStyle.outer, color: gray, offset: Offset(4, 6))]),
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.all(24),
                child: const Center(child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[Icon(Bootstrap.check2_circle), SizedBox(width: 10), Text("Message Understood", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))])),
              ),
            ),
            GestureDetector(
              onLongPress: () async {
                if (_voiceController != null) {
                  if (_voiceController!.isPlaying) {
                    _voiceController!.stopPlaying();
                  }
                  _voiceKey.currentState!.setState(() => _isAudio = false);
                }
                await Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const ChatRoom()));
              },
              child: Container(
                decoration: BoxDecoration(color: teal.withOpacity(.5), borderRadius: BorderRadius.circular(15), boxShadow: const <BoxShadow>[BoxShadow(blurStyle: BlurStyle.outer, color: gray, offset: Offset(4, 6))]),
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.all(24),
                child: const Center(child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[Icon(FontAwesome.circle_exclamation), SizedBox(width: 10), Text("I Have A Problem", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))])),
              ),
            ),
            GestureDetector(
              onTap: () async {
                await userLocalSettings!.put("phone", "");
                // ignore: use_build_context_synchronously
                await Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => const SignIn()));
              },
              child: Container(
                decoration: BoxDecoration(color: teal.withOpacity(.5), borderRadius: BorderRadius.circular(15), boxShadow: const <BoxShadow>[BoxShadow(blurStyle: BlurStyle.outer, color: gray, offset: Offset(4, 6))]),
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.all(24),
                child: const Center(child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[Icon(Icons.logout), SizedBox(width: 10), Text("Sign Out", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))])),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
