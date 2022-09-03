import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feed/Model/chat_model.dart';
import 'package:feed/Model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  UserDataModel? user;

  List<UserDataModel> usersList = [];

  void getUsers() {
    FirebaseFirestore.instance.collection('users').snapshots().listen((value) {
      usersList = [];
      for (var element in value.docs) {
        if (UserDataModel.fromJson(element.data()).uId != user?.uId) {
          usersList.add(UserDataModel.fromJson(element.data()));
        }
      }
    });
  }

  void getUserData(String id) {
    FirebaseFirestore.instance.collection('users').doc(id).get().then((value) {
      user = UserDataModel.fromJson(value.data()!);
    }).catchError((error) {
      print(error);
    });
  }

  TextEditingController messageController = TextEditingController();

  void sendMessage(UserDataModel userDataModel) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uId)
        .collection('chats')
        .get()
        .then((value) {
      MessageDataModel model = MessageDataModel(
        time: DateTime.now().toString(),
        message: messageController.text,
        receiverId: userDataModel.uId,
        senderId: user!.uId,
      );

      if (value.docs
          .any((element) => element.reference.id != userDataModel.uId)) {
        ChatDataModel chatDataModel = ChatDataModel(
          username: userDataModel.username,
          userId: userDataModel.uId,
          userImage: userDataModel.image,
        );

        FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uId)
            .collection('chats')
            .doc(userDataModel.uId)
            .set(chatDataModel.toJson())
            .then((value) {})
            .catchError((error) {
          update();
        });

        FirebaseFirestore.instance
            .collection('users')
            .doc(userDataModel.uId)
            .collection('chats')
            .doc(user!.uId)
            .set(chatDataModel.toJson())
            .then((value) {})
            .catchError((error) {
          update();
        });
      } else {
        FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uId)
            .collection('chats')
            .doc(userDataModel.uId)
            .collection('messages')
            .add(model.toJson())
            .then((value) {
          messageController.clear();
        }).catchError((error) {
          update();
        });

        FirebaseFirestore.instance
            .collection('users')
            .doc(userDataModel.uId)
            .collection('chats')
            .doc(user!.uId)
            .collection('messages')
            .add(model.toJson())
            .then((value) {
          messageController.clear();
        }).catchError((error) {
          update();
        });
      }
    }).catchError((error) {
      update();
    });
  }

  List<MessageDataModel> messagesList = [];

  void getMessages(UserDataModel userDataModel) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uId)
        .collection('chats')
        .doc(userDataModel.uId)
        .collection('messages')
        .orderBy(
          'time',
          descending: true,
        )
        .snapshots()
        .listen((value) {
      messagesList = [];

      for (var element in value.docs) {
        messagesList.add(MessageDataModel.fromJson(element.data()));
      }

      update();
    });
  }
}
