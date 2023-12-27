import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Wrong extends StatelessWidget {
  const Wrong({super.key, required this.errorMessage});
  final String errorMessage;
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                LottieBuilder.asset("assets/lotties/wrong.json", width: MediaQuery.sizeOf(context).width * .8),
                Flexible(child: Text(errorMessage, style: const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w400))),
              ],
            ),
          ),
        ),
      );
}
