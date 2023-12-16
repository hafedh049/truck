import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:truck/views/helpers/utils/globals.dart';

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
        apiKey: "AIzaSyDjuWTbysu3xYLXmRwYlVU47b4wgW2vkDA",
        storageBucket: "truck-97497.appspot.com",
        appId: "1:705178287722:android:a39bd5970c6af438c89413",
        messagingSenderId: "705178287722",
        projectId: "truck-97497",
      ),
    );
    await loadUserLocalSettings();
    if (userLocalSettings!.get("phone") == null) {
      await userLocalSettings!.put("phone", "");
    }
    final DocumentSnapshot<Map<String, dynamic>> query = await FirebaseFirestore.instance.collection("users").doc(userLocalSettings!.get("phone")).get();
    if (!query.exists) {
      await userLocalSettings!.put("phone", "");
    }

    return true;
  } catch (e) {
    return false;
  }
}

void showSnack(String message) => Fluttertoast.showToast(msg: message, backgroundColor: gray, fontSize: 14, gravity: ToastGravity.BOTTOM_LEFT, textColor: white, toastLength: Toast.LENGTH_LONG);

Duration timeStringToDuration(String timeStr) {
  try {
    final List<String> timeParts = timeStr.split(':');
    final int minutes = int.parse(timeParts[0]);
    final int seconds = int.parse(timeParts[1]);

    return Duration(minutes: minutes, seconds: seconds);
  } catch (e) {
    return const Duration();
  }
}
