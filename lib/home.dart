import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:text_to_speech/text_to_speech.dart';
import 'package:truck/chat_room.dart';
import 'package:truck/utils/globals.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextToSpeech _tts = TextToSpeech();
  final List<Map<String, dynamic>> _items = <Map<String, dynamic>>[
    <String, dynamic>{"title": "Repeat Last Message", "icon": Bootstrap.arrow_repeat, "callback": () {}},
    <String, dynamic>{"title": "Message Understood", "icon": Bootstrap.check2_circle, "callback": () {}},
    <String, dynamic>{"title": "I Have A Problem", "icon": FontAwesome.circle_exclamation, "callback": () {}},
  ];

  @override
  void initState() {
    _items[0]["callback"] = () async {
      await _tts.speak("Hi my name is Hafedh!");
    };
    _items[1]["callback"] = () async {};
    _items[2]["callback"] = () async {await Navigator.push(context,MaterialPageRoute(builder: (context) => const ChatRoom());};
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          for (final Map<String, dynamic> item in _items)
            InkWell(
              highlightColor: transparent,
              splashColor: transparent,
              hoverColor: transparent,
              onTap: item["callback"],
              child: Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.all(24),
                child: Center(
                  child: Row(
                    children: <Widget>[
                      Icon(item["icon"]),
                      const SizedBox(width: 10),
                      Text(item["title"], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
