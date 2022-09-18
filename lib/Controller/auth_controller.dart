import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feed/Model/user_model.dart';
import 'package:feed/Utils/shared_preference.dart';
import 'package:feed/ui/screens/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  bool isVisible = true;
  bool registerLoader = false;
  bool loginLoader = false;

  final auth = FirebaseAuth.instance;
  // Instead of calling reference every time, we can't call it once here
  final _ref = FirebaseFirestore.instance.collection('users');

  UserDataModel? get user {
    return _toUser(auth.currentUser);
  }

  UserDataModel? _toUser(User? fireUser) {
    return fireUser == null
        ? null
        : UserDataModel(
            uId: fireUser.uid,
            username: fireUser.displayName ?? '',
            email: fireUser.email ?? '',
          );
  }

  void register({userName, userEmail, userPassword}) {
    registerLoader = true;
    update();
    auth
        .createUserWithEmailAndPassword(
            email: userEmail, password: userPassword)
        .then((userData) async {
      // You have to add username to firebase as a display name
      await auth.currentUser!.updateDisplayName(userName);
      FirebaseMessaging.instance.getToken().then((value) {
        UserDataModel model = UserDataModel(
          uId: userData.user!.uid,
          email: userEmail,
          username: userName,
        );
        if (value != null) {
          saveUserToken(value);
        }

        UserPreferences().saveUser(model);
        _ref.doc(userData.user!.uid).set(model.toJson()).then((value) {
          registerLoader = false;
          update();
          Get.offAll(() => const HomeScreen());
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
    auth
        .signInWithEmailAndPassword(email: userEmail, password: userPassword)
        .then((value) {
      loginLoader = false;
      update();
      Get.offAll(() => const HomeScreen());
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

  void saveUserToken(String token) async {
    // Instead of saving the token in the user model and in preferences
    // it better be saved in Firestore only, since it won't be used here
    await _ref
        .doc(auth.currentUser!.uid)
        // the token is saved in subcollection inside the user collection
        .collection('private')
        .doc('notifications')
        .set(
      {
        // Instead of only one token, we only keep multi tokens
        'tokens': FieldValue.arrayUnion(
          [token],
        ),
      },
      SetOptions(merge: true),
    );
  }
}
