import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feed/Model/user_model.dart';
import 'package:feed/Utils/shared_preference.dart';
import 'package:feed/View/Home/home.dart';
import 'package:feed/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  bool isVisible = true;
  bool registerLoader = false;
  bool loginLoader = false;

  void register({userName, userEmail, userPassword}) {
    registerLoader = true;
    update();
    FirebaseAuth.instance
        .createUserWithEmailAndPassword(
            email: userEmail, password: userPassword)
        .then((userData) {
      FirebaseMessaging.instance.getToken().then((value) {
        UserDataModel model = UserDataModel(
          uId: userData.user!.uid,
          email: userEmail,
          username: userName,
          token: value!,
        );
        UserPreferences().saveUser(model);
        FirebaseFirestore.instance
            .collection('users')
            .doc(userData.user!.uid)
            .set(model.toJson())
            .then((value) {
          registerLoader = false;
          update();
          userConst = userData.user;
          Get.offAll(() => Home());
        }).catchError((error) {
          Fluttertoast.showToast(
            msg: error.toString(),
          );
        });
      });
    }).catchError((error) {
      registerLoader = false;
      update();
      Fluttertoast.showToast(
        msg: error.toString().split(']').last,
      );
    });
  }

  void login({userEmail, userPassword}) {
    loginLoader = true;
    update();
    FirebaseAuth.instance
        .signInWithEmailAndPassword(email: userEmail, password: userPassword)
        .then((value) {
      userConst = value.user;
      loginLoader = false;
      update();
      Get.offAll(() => Home(uId: value.user!.uid));
    }).catchError((error) {
      loginLoader = false;
      update();
      Fluttertoast.showToast(
        msg: error.toString().split(']').last,
      );
    });
  }

  void visibility() {
    isVisible = !isVisible;
    update();
  }
}
