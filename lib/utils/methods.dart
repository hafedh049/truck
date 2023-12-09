import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:truck/utils/globals.dart';

Future<bool> loadUserLocalSettings() async {
  try {
    Hive.init((await getApplicationDocumentsDirectory()).path);
    userLocalSettings = await Hive.openBox('userLocalSettings');
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> load() async {
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAgDmdEd7v4iG7TFVraJ6q7lyXYIU1LW10",
        storageBucket: "wassalny-ffdf7.appspot.com",
        appId: "1:248521282422:android:fc183b969a35a0329aa057",
        messagingSenderId: "248521282422",
        projectId: "wassalny-ffdf7",
      ),
    );
    documentsPath = (await getTemporaryDirectory()).path;
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
