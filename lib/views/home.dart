import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:terrestra/models/messages/text_message_model.dart';
import 'package:terrestra/views/auth/sign_in.dart';
import 'package:terrestra/views/chat_room.dart';
import 'package:terrestra/helpers/utils/globals.dart';
import 'package:terrestra/helpers/utils/methods.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FlutterTts _tts = FlutterTts()..setLanguage("es-ES");
  late final StreamSubscription<QuerySnapshot<Map<String, dynamic>>> _notificationStream;
  final AssetsAudioPlayer _assetsAudioPlayer = AssetsAudioPlayer();

  @override
  void initState() {
    _notificationStream = FirebaseFirestore.instance.collection("chats").doc(userLocalSettings!.get("RUT")).collection("messages").orderBy("createdAt", descending: true).limit(1).snapshots().listen(
      (QuerySnapshot<Map<String, dynamic>> event) async {
        if (event.docs.isNotEmpty && event.docs.first.get("uid") != userLocalSettings!.get("RUT")) {
          InAppNotification.show(
            child: Container(
              width: MediaQuery.sizeOf(context).width * .98,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(5)),
              child: const Center(child: Text("Nuevo mensaje", style: TextStyle(color: accent1))),
            ),
            context: context,
            onTap: () {},
          );
          _assetsAudioPlayer.open(Audio("assets/notification.wav"));
        }
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    _notificationStream.cancel();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: () async {
                  final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection("chats").doc(userLocalSettings!.get("RUT")).collection("messages").orderBy("createdAt", descending: true).limit(1).get();
                  if (snapshot.docs.isNotEmpty) {
                    final List<QueryDocumentSnapshot<Map<String, dynamic>>> messages = snapshot.docs;
                    if (messages.isNotEmpty) {
                      if (messages.first.get("type") == "text") {
                        await _tts.speak(messages.first.get("content"));
                      } else if (messages.first.get("type") == "audio") {
                        _assetsAudioPlayer.open(Audio.network(messages.first.get("content")));
                      } else if (messages.first.get("type") == "image") {
                        await _tts.speak("EL ÚLTIMO MENSAJE ES UNA IMAGEN");
                      } else {
                        await _tts.speak("EL ÚLTIMO MENSAJE ES UN ADJUNTO");
                      }
                    } else {
                      showSnack("Aún no hay mensajes.");
                    }
                  }
                },
                child: Container(
                  decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(15)),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(width: 10),
                      Text("Repetir último\nmensaje", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                      Spacer(),
                      Icon(Bootstrap.repeat, size: 35),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: () async {
                  await FirebaseFirestore.instance.collection("chats").doc(userLocalSettings!.get("RUT")).collection("messages").add(TextMessageModel(uid: userLocalSettings!.get("RUT"), createdAt: DateTime.now().millisecondsSinceEpoch, content: "COMPRENDIDO").toJson());
                  showSnack("Enviado");
                },
                child: Container(
                  decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(15)),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text("Mensaje\nEntendido", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                      Spacer(),
                      Icon(Bootstrap.check, size: 55),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => showSnack("Mantenga presionado para continuar"),
                onLongPress: () {
                  _notificationStream.cancel();
                  _tts.stop();
                  _assetsAudioPlayer.stop();
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const ChatRoom()));
                },
                child: Container(
                  decoration: BoxDecoration(color: accent1, borderRadius: BorderRadius.circular(15)),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text("Tengo Un\nProblema", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                      Spacer(),
                      Icon(FontAwesome.triangle_exclamation, size: 35),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  userLocalSettings!.put("RUT", "");
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => const SignIn()));
                },
                child: Container(
                  decoration: BoxDecoration(color: foregroundColor, borderRadius: BorderRadius.circular(15)),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text("Desconectar", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                      Spacer(),
                      Icon(Icons.exit_to_app, size: 35),
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
