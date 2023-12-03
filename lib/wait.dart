import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Wait extends StatelessWidget {
  const Wait({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: LottieBuilder.asset(name)),
    );
  }
}
