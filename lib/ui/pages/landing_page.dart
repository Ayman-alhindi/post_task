import 'package:feed/View/Home/home.dart';
import 'package:feed/View/Login/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// you can check if the user is signed in by FirebaseAuth
// this page check for user state and choose
// which page to go to depends on user state
class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    super.initState();

    // resolve next page only when this widget is built
    // else it will cause errors
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resolveNextPage();
    });
  }

  void _resolveNextPage() {
    var user = FirebaseAuth.instance.currentUser;

    // if user is null
    // it means he is not signed in => go to login/sign up page
    // else => go to home page
    if (user == null) {
      _navigateIfNotLoggedIn();
    } else {
      _navigateIfLoggedIn();
    }
  }

  void _navigateIfLoggedIn() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const Home(),
      ),
    );
  }

  void _navigateIfNotLoggedIn() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Instead of text, it can be some loading indicator
    return const Scaffold(
      body: Center(
        child: Text("Loading"),
      ),
    );
  }
}
