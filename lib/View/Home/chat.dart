import 'package:feed/Controller/chatController.dart';
import 'package:feed/Model/chat_model.dart';
import 'package:feed/Model/user_model.dart';
import 'package:feed/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessagesScreen extends StatefulWidget {
  final UserDataModel userDataModel;

  const MessagesScreen({
    Key? key,
    required this.userDataModel,
  }) : super(key: key);

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  ChatController controller = Get.find();

  @override
  void initState() {
    super.initState();
    controller.getMessages(widget.userDataModel);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(
        init: ChatController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                widget.userDataModel.username,
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  if (controller.messagesList.isNotEmpty)
                    Expanded(
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          if (controller.messagesList[index].senderId ==
                              controller.user!.uId) {
                            return MyItem(
                              model: controller.messagesList[index],
                            );
                          }

                          return UserItem(
                            model: controller.messagesList[index],
                          );
                        },
                        separatorBuilder: (context, index) =>
                            space10Vertical(context),
                        itemCount: controller.messagesList.length,
                      ),
                    ),
                  if (controller.messagesList.isEmpty)
                    const Expanded(
                      child: Center(
                        child: CupertinoActivityIndicator(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  space20Vertical(context),
                  TextFormField(
                    controller: controller.messageController,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'type message',
                      border: const OutlineInputBorder(),
                      suffixIcon: MaterialButton(
                        minWidth: 1,
                        onPressed: () {
                          controller.sendMessage(widget.userDataModel);
                        },
                        child: const Icon(
                          Icons.send,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}

class MyItem extends StatelessWidget {
  final MessageDataModel model;

  const MyItem({
    Key? key,
    required this.model,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 10.0,
            ),
            decoration: const BoxDecoration(
              borderRadius: BorderRadiusDirectional.only(
                topStart: Radius.circular(
                  15.0,
                ),
                topEnd: Radius.circular(
                  15.0,
                ),
                bottomStart: Radius.circular(
                  15.0,
                ),
              ),
              color: Colors.blue,
            ),
            child: Text(
              model.message,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class UserItem extends StatelessWidget {
  final MessageDataModel model;

  const UserItem({
    Key? key,
    required this.model,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 10.0,
            ),
            decoration: BoxDecoration(
              borderRadius: const BorderRadiusDirectional.only(
                topStart: Radius.circular(
                  15.0,
                ),
                topEnd: Radius.circular(
                  15.0,
                ),
                bottomEnd: Radius.circular(
                  15.0,
                ),
              ),
              color: Colors.grey[200],
            ),
            child: Text(
              model.message,
              style: const TextStyle(),
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
