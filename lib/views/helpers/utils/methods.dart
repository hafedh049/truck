import 'package:firebase_core/firebase_core.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:truck/views/helpers/utils/globals.dart';

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

    return true;
  } catch (e) {
    return false;
  }
}

void showSnack(String message) {
  Fluttertoast.showToast(msg: message, backgroundColor: teal.withOpacity(.3), fontSize: 14, gravity: ToastGravity.TOP_RIGHT, textColor: white, toastLength: Toast.LENGTH_LONG);
}

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
