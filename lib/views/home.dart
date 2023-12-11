import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:truck/views/auth/sign_in.dart';
import 'package:truck/views/chat_space.dart';
import 'package:truck/utils/globals.dart';
import 'package:truck/utils/methods.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:voice_message_package/voice_message_package.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FlutterTts _tts = FlutterTts();

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  bool _isAudio = false;
  String _audioUrl = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            StatefulBuilder(builder: (BuildContext context, void Function(void Function()) setS) {
              return GestureDetector(
                onTap: () async {
                  final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection("chats").doc(FirebaseAuth.instance.currentUser!.uid).collection("messages").orderBy("createdAt", descending: true).limit(1).get();
                  if (snapshot.docs.isNotEmpty) {
                    final List<QueryDocumentSnapshot<Map<String, dynamic>>> messages = snapshot.docs;
                    if (messages.isNotEmpty) {
                      if (messages.first.get("type") == "text") {
                        await _tts.speak(messages.first.get("text"));
                      } else if (messages.first.get("type") == "audio") {
                        setS(
                          () {
                            _isAudio = true;
                            _audioUrl = messages.first.get("uri");
                          },
                        );
                      } else {
                        await _tts.speak("LAST MESSAGE IS NOT A TEXT OR AN AUDIO");
                      }
                    } else {
                      // ignore: use_build_context_synchronously
                      showSnack("No messages yet.", 1, context);
                    }
                  }
                },
                child: _isAudio
                    ? VoiceMessageView(
                        backgroundColor: transparent,
                        activeSliderColor: white,
                        circlesColor: teal,
                        notActiveSliderColor: transparent,
                        size: 29,
                        controller: VoiceController(
                          audioSrc: _audioUrl,
                          maxDuration: const Duration(milliseconds: 120),
                          isFile: false,
                          onComplete: () {
                            setS(
                              () {
                                _isAudio = false;
                                _audioUrl = "";
                              },
                            );
                          },
                          onPause: () {},
                          onPlaying: () {},
                        ),
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
            }),
            GestureDetector(
              onTap: () async {
                await FirebaseFirestore.instance.collection("chats").doc(FirebaseAuth.instance.currentUser!.uid).collection("messages").add(types.TextMessage(author: types.User(id: FirebaseAuth.instance.currentUser!.uid), createdAt: DateTime.now().millisecondsSinceEpoch, id: List<int>.generate(20, (int index) => Random().nextInt(10)).join(), text: "UNDERSTOOD").toJson());
                // ignore: use_build_context_synchronously
                showSnack("Sent", 1, context);
              },
              child: Container(
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
                      Icon(Bootstrap.check2_circle),
                      SizedBox(width: 10),
                      Text("Message Understood", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () async => await Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const ChatSpace())),
              child: Container(
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
                      Icon(FontAwesome.circle_exclamation),
                      SizedBox(width: 10),
                      Text("I Have A Problem", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                // ignore: use_build_context_synchronously
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => const SignIn()));
              },
              child: Container(
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
                      Icon(Icons.logout),
                      SizedBox(width: 10),
                      Text("Sign Out", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
