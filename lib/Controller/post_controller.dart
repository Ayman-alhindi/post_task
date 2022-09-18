import 'dart:io';
import 'package:feed/Utils/shared_preference.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:feed/Model/user_model.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:feed/Model/post_model.dart';
import 'package:feed/View/Home/home.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostController extends GetxController {
  String? userName;
  String? uId;

  bool pick = false;

  File? postImage;

  var picker = ImagePicker();

  void pickPostImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      postImage = File(pickedFile.path);
      update();
    }
  }

  void deletePostImage() async {
    postImage = null;
    update();
  }

  UserDataModel? user;

  void createPost({postText}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userName = prefs.getString("username");
    update();
    pick = true;
    update();
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('kk:mm EEE d MMM').format(now);

    if (postImage != null) {
      firebase_storage.FirebaseStorage.instance
          .ref('uploads/${postImage!.path.split('/').last}')
          .putFile(postImage!)
          .then((p0) {
        p0.ref.getDownloadURL().then((value) {
          final doc = FirebaseFirestore.instance.collection('posts').doc();

          PostDataModel model = PostDataModel(
            id: doc.id,
            image: value,
            likes: [],
            ownerName: userName!,
            shares: 0,
            text: postText,
            time: formattedDate,
            comments: [],
          );

          doc.set(model.toJson()).then((value) {
            pick = false;
            update();
            deletePostImage();
            update();
            Get.offAll(const Home());
          }).catchError((error) {
            Fluttertoast.showToast(
              msg: error.toString(),
            );
          });
        }).catchError((error) {
          Fluttertoast.showToast(
            msg: error.toString(),
          );
        });
      }).catchError((error) {
        Fluttertoast.showToast(
          msg: error.toString(),
        );
      });
    } else {
      final doc = FirebaseFirestore.instance.collection('posts').doc();

      PostDataModel model = PostDataModel(
        id: doc.id,
        comments: [],
        image: '',
        likes: [],
        ownerName: userName!,
        shares: 0,
        text: postText,
        time: formattedDate,
      );

      doc.set(model.toJson()).then((value) {
        pick = false;
        update();
        Get.offAll(const Home());
      }).catchError((error) {
        Fluttertoast.showToast(
          msg: error.toString(),
        );
      });
    }
  }

  void getUserData(String id) {
    FirebaseFirestore.instance.collection('users').doc(id).get().then((value) {
      user = UserDataModel.fromJson(value.data()!);
      UserPreferences().saveUser(user!);
      update();
    }).catchError((error) {
      update();
    });
  }

  List<PostDataModel> postsList = [];

  void getPosts() {
    FirebaseFirestore.instance.collection('posts').snapshots().listen((value) {
      postsList = [];
      for (var element in value.docs) {
        postsList.add(
          PostDataModel.fromJson(element.data()),
        );
      }
    });
  }

  void updatePostLikes(PostDataModel post) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    uId = prefs.getString("uId");
    update();
    if (post.likes.any((element) => element == uId)) {
      post.likes.removeWhere((element) => element == uId);
      update();
    } else {
      post.likes.add(uId!);
      update();
    }

    FirebaseFirestore.instance
        .collection('posts')
        .doc(post.id)
        .update(post.toJson())
        .then((value) {
      update();
    }).catchError((error) {
      update();
    });
  }

  void updatePostShares(PostDataModel post) {
    post = post.copyWith(
      shares: post.shares + 1,
    );

    FirebaseFirestore.instance
        .collection('posts')
        .doc(post.id)
        .update(post.toJson())
        .then((value) {
      update();
    }).catchError((error) {
      update();
    });
  }

  void addComment({id, comment, time}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userName = prefs.getString("username");
    update();
    FirebaseFirestore.instance.collection('posts').doc(id).update({
      'comments': FieldValue.arrayUnion([
        {"text": comment, "ownerName": userName, "time": time}
      ])
    }).then((value) {
      update();
    }).catchError((error) {
      update();
    });
  }

  void deleteComment({id, comment, time}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userName = prefs.getString("username");
    update();
    FirebaseFirestore.instance.collection('posts').doc(id).update({
      'comments': FieldValue.arrayRemove([
        {"text": comment, "ownerName": userName, "time": time}
      ])
    }).then((value) {
      update();
    }).catchError((error) {
      update();
    });
  }

  void deletePost({id}) {
    FirebaseFirestore.instance
        .collection('posts')
        .doc(id)
        .delete()
        .then((value) {
      update();
    }).catchError((error) {
      update();
    });
  }
}
