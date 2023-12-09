import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:truck/chat_room.dart';
import 'package:truck/utils/globals.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FlutterTts _tts = FlutterTts();
  final List<Map<String, dynamic>> _items = <Map<String, dynamic>>[
    <String, dynamic>{"title": "Repeat Last Message", "icon": Bootstrap.arrow_repeat, "callback": () {}},
    <String, dynamic>{"title": "Message Understood", "icon": Bootstrap.check2_circle, "callback": () {}},
    <String, dynamic>{"title": "I Have A Problem", "icon": FontAwesome.circle_exclamation, "callback": () {}},
    <String, dynamic>{"title": "I Have A Problem", "icon": Icons.logout, "callback": () {}},
  ];

  @override
  void initState() {
    _items[0]["callback"] = () async {
      await _tts.speak("Hi my name is Hafedh!");
    };
    _items[1]["callback"] = () async {};
    _items[2]["callback"] = () async {
      await Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const ChatRoom()));
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            for (final Map<String, dynamic> item in _items)
              GestureDetector(
                onTap: item["callback"],
                child: Container(
                  decoration: BoxDecoration(
                    color: blue.withOpacity(.5),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const <BoxShadow>[BoxShadow(blurStyle: BlurStyle.outer, color: gray, offset: Offset(4, 6))],
                  ),
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.all(24),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
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
      ),
    );
  }
}
