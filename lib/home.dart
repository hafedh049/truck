import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:truck/utils/globals.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          InkWell(
            highlightColor: transparent,
            splashColor: transparent,
            hoverColor: transparent,
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.all(24),
              child: const Center(
                child: Row(
                  children: <Widget>[
                    Icon(Bootstrap.arrow_repeat),
                    SizedBox(width: 10),
                    Text("Repeat last message", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
