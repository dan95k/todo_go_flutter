import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';

enum ListAction { add, remove, check, uncheck }

Urgency stringToUrgency(String str) {
  if (str == "Low") {
    return Urgency.low;
  } else if (str == "Medium") {
    return Urgency.medium;
  } else if (str == "High") {
    return Urgency.high;
  }
  return Urgency.low;
}

int urgencyToInt(Urgency urgency) {
  switch (urgency) {
    case Urgency.low:
      return 1;
    case Urgency.medium:
      return 2;
    case Urgency.high:
      return 3;
    default:
      return 1;
  }
}

Future<void> logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString("email", "");
}

Future<String> getEmailFromPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  final String? email = prefs.getString('email');
  return email ?? "";
}

Future<bool> saveEmailToPreferences(String email) async {
  final prefs = await SharedPreferences.getInstance();
  bool isSet = await prefs.setString('email', email);
  return isSet;
}
