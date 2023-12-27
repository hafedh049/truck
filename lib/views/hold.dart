import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:terrestra/helpers/utils/globals.dart';
import 'package:terrestra/views/home.dart';

class Hold extends StatefulWidget {
  const Hold({super.key});

  @override
  State<Hold> createState() => _HoldState();
}

class _HoldState extends State<Hold> {
  late final Timer _timer;
  @override
  void initState() {
    _timer = Timer.periodic(
      2.seconds,
      (Timer timer) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => const Home()));
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Spacer(),
          Text("t", style: GoogleFonts.ibmPlexSans(fontSize: 256, color: accent1)),
          Center(
            child: ShaderMask(
              shaderCallback: (Rect bounds) => LinearGradient(colors: <Color>[accent1, accent2.withOpacity(.8), foregroundColor, accent3.withOpacity(.6)]).createShader(bounds),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text("terrestra", style: GoogleFonts.ibmPlexSans(fontSize: 48, color: accent1)),
                  Flexible(child: Text("Dynamic Fleet Management", style: GoogleFonts.ibmPlexSans(fontSize: 36, color: accent1), textAlign: TextAlign.center)),
                ],
              ),
            ),
          ),
          const Spacer(),
          LottieBuilder.asset("assets/lotties/load.json", width: 100, height: 100),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
