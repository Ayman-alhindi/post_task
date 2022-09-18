import 'package:feed/Utils/injection.dart';
import 'package:feed/View/Home/home.dart';
import 'package:feed/View/Login/login.dart';
import 'package:feed/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  userConst = FirebaseAuth.instance.currentUser;

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  runApp(MyApp(user: userConst));
}

class MyApp extends StatelessWidget {
  final User? user;

  const MyApp({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: HomeBinding(),
      title: 'Feed',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: user != null ? const Home() : LoginScreen(),
    );
  }
}
