import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Wait extends StatelessWidget {
  const Wait({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            LottieBuilder.asset("assets/lotties/wait.json", width: MediaQuery.sizeOf(context).width * .8),
          ],
        ),
      );
}
