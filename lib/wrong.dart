import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:truck/utils/globals.dart';

class Wrong extends StatelessWidget {
  const Wrong({super.key, required this.errorMessage});
  final String errorMessage;
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            LottieBuilder.asset("assets/lotties/wait.json", width: MediaQuery.sizeOf(context).width * .8),
            Text(errorMessage, style: TextStyle(color: blue, fontSize: 16, fontWeight: FontWeight.w400)),
          ],
        ),
      );
}
