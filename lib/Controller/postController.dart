import 'dart:io';
import 'package:feed/constants.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:feed/Model/user_model.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:feed/Model/post_model.dart';
import 'package:feed/View/Home/home.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PostController extends GetxController {
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
    } else {
      print("error");
    }
  }

  void deletePostImage() async {
    postImage = null;
    update();
  }

  UserDataModel? user;

  void createPost({postText}) {
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
          PostDataModel model = PostDataModel(
            image: value,
            likes: [],
            ownerImage: user!.image,
            ownerName: user!.username,
            shares: 0,
            text: postText,
            time: formattedDate,
            comments: [],
          );

          FirebaseFirestore.instance
              .collection('posts')
              .add(model.toJson())
              .then((value) {
            pick = false;
            update();
            Get.offAll(Home());
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
      PostDataModel model = PostDataModel(
        comments: [],
        image: '',
        likes: [],
        ownerImage: user!.image,
        ownerName: user!.username,
        shares: 0,
        text: postText,
        time: formattedDate,
      );

      FirebaseFirestore.instance
          .collection('posts')
          .add(model.toJson())
          .then((value) {
        pick = false;
        update();
        Get.offAll(Home());
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
    }).catchError((error) {
      print(error);
    });
  }

  List<Map<String, PostDataModel>> postsList = [];

  void getPosts() {
    FirebaseFirestore.instance.collection('posts').snapshots().listen((value) {
      postsList = [];
      for (var element in value.docs) {
        postsList.add(
            {element.reference.id: PostDataModel.fromJson(element.data())});
      }
    });
  }

  void updatePostLikes(Map<String, PostDataModel> post) {
    if (post.values.single.likes.any((element) => element == user!.uId)) {
      post.values.single.likes.removeWhere((element) => element == user!.uId);
      update();
    } else {
      post.values.single.likes.add(user!.uId);
      update();
    }

    FirebaseFirestore.instance
        .collection('posts')
        .doc(post.keys.single)
        .update(post.values.single.toJson())
        .then((value) {
      update();
    }).catchError((error) {
      update();
    });
  }

  void updatePostShares(Map<String, PostDataModel> post) {
    post.values.single.shares++;

    FirebaseFirestore.instance
        .collection('posts')
        .doc(post.keys.single)
        .update(post.values.single.toJson())
        .then((value) {
      update();
    }).catchError((error) {
      update();
    });
  }
}
