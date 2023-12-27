import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Wait extends StatelessWidget {
  const Wait({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: LottieBuilder.asset("assets/lotties/wait.json", width: 200, height: 200)));
}
