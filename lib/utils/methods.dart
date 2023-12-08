import 'dart:math';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:harmonix/utils/globals.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

Future<bool> loadUserLocalSettings() async {
  try {
    Hive.init((await getApplicationDocumentsDirectory()).path);
    userLocalSettings = await Hive.openBox('userLocalSettings');
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> load(BuildContext context) async {
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDNc3098SZ8DlGfNtquNsjUhTwB8akZtpY",
        storageBucket: "harmonix-ede29.appspot.com",
        appId: "1:958782362415:android:6cedaafe969f954e9c47da",
        messagingSenderId: "958782362415",
        projectId: "harmonix-ede29",
      ),
    );
    await loadUserLocalSettings();
    if (userLocalSettings!.get("first_time") == null) {
      await userLocalSettings!.put("first_time", true);
    }
    if (userLocalSettings!.get("theme") == null) {
      await userLocalSettings!.put("theme", "dark");
    }
    if (userLocalSettings!.get("language") == null) {
      await userLocalSettings!.put("language", "en");
    }

    // ignore: use_build_context_synchronously
    sendQuote(context);

    return true;
  } catch (e) {
    return false;
  }
}

void showSnack(String message, int type, BuildContext context) {
  final snackBar = SnackBar(
    behavior: SnackBarBehavior.floating,
    backgroundColor: transparent,
    content: AwesomeSnackbarContent(
      title: type == 1
          ? "Hey!"
          : type == 2
              ? "Warning"
              : "Error",
      message: message,
      contentType: type == 1
          ? ContentType.success
          : type == 2
              ? ContentType.warning
              : ContentType.failure,
    ),
  );

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}

void sendQuote(BuildContext context) async {
  if (userLocalSettings!.get("quote") == null || DateTime.now().difference(userLocalSettings!.get("quote")).inDays == 1) {
    showSnack(climateChangeQuotes[Random().nextInt(climateChangeQuotes.length)], 1, context);
    await userLocalSettings!.put("quote", DateTime.now());
  }
}
