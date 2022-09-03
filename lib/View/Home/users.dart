import 'package:feed/Controller/chatController.dart';
import 'package:feed/View/Home/chat.dart';
import 'package:feed/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  ChatController controller = Get.find();

  @override
  void initState() {
    super.initState();
    controller.getUserData(userConst!.uid);
    controller.getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User',
        ),
      ),
      body: controller.usersList.isNotEmpty
          ? ListView.separated(
              itemBuilder: (context, index) => GetBuilder<ChatController>(
                init: ChatController(),
                builder: (controller) {
                  return InkWell(
                    onTap: () {
                      Get.to(
                        MessagesScreen(
                          userDataModel: controller.usersList[index],
                        ),
                      );
                    },
                    child: Container(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            if (controller.usersList[index].image.isNotEmpty)
                              CircleAvatar(
                                radius: 20.0,
                                backgroundImage: NetworkImage(
                                  controller.usersList[index].image,
                                ),
                              ),
                            if (controller.usersList[index].image.isEmpty)
                              CircleAvatar(
                                radius: 20.0,
                                child: Center(
                                  child: Text(
                                    controller.usersList[index].username
                                        .characters.first,
                                    style: const TextStyle(
                                      fontSize: 26.0,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            space10Horizontal(context),
                            Expanded(
                              child: Text(
                                controller.usersList[index].username,
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              separatorBuilder: (context, index) => space10Vertical(context),
              itemCount: controller.usersList.length,
            )
          : const Center(
              child: CupertinoActivityIndicator(
                color: Colors.black,
              ),
            ),
    );
  }
}
