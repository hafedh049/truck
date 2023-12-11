import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:truck/auth/sign_in.dart';
import 'package:truck/chat_space.dart';
import 'package:truck/utils/globals.dart';
import 'package:truck/utils/methods.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection("chats").doc(FirebaseAuth.instance.currentUser!.uid).collection("messages").orderBy("createdAt", descending: true).limit(1).snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                return GestureDetector(
                  onTap: () async {
                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      final List<QueryDocumentSnapshot<Map<String, dynamic>>> messages = snapshot.data!.docs;
                      if (messages.isNotEmpty) {
                        if (messages.first.get("type") == "text") {
                          await _tts.speak(messages.first.get("message"));
                        } else {
                          showSnack("Last message is not a text.", 1, context);
                          await _tts.speak("LAST MESSAGE IS NOT A TEXT");
                        }
                      } else {
                        showSnack("No messages yet.", 1, context);
                      }
                    }
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
                final String id = List<int>.generate(19, (_) => Random().nextInt(10)).join();
                await FirebaseFirestore.instance.collection("trucks").doc(FirebaseAuth.instance.currentUser!.uid).get().then(
                  (DocumentSnapshot<Map<String, dynamic>> value) {
                    if (value.exists) {
                      final Map<String, dynamic> data = value.data()!["messages"];
                      data.addAll(
                        <String, dynamic>{
                          id: <String, dynamic>{'message': "MESSAGE UNDERSTOOD", 'createdAt': Timestamp.now(), 'sendBy': "me", 'message_type': "text"},
                        },
                      );
                      value.reference.update(<String, dynamic>{"messages": data});
                    } else {
                      final String channelID = List<int>.generate(19, (_) => Random().nextInt(10)).join();
                      value.reference.set(
                        <String, dynamic>{
                          "channelID": channelID,
                          "channelName": "truck-***",
                          "messages": <String, dynamic>{
                            id: <String, dynamic>{'message': "MESSAGE UNDERSTOOD", 'createdAt': Timestamp.now(), 'sendBy': "me", 'message_type': "text"},
                          },
                        },
                      );
                    }
                  },
                );
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
              onTap: () async => await Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const /*ChatRoom*/ ChatSpace())),
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
