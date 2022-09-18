import 'dart:async';
import 'package:feed/Model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  Future<bool> saveUser(UserDataModel user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("uId", user.uId);
    prefs.setString("username", user.username);
    prefs.setString("email", user.email);
    return true;
  }
}
