import 'package:feed/Controller/postController.dart';
import 'package:feed/View/Home/users.dart';
import 'package:feed/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'add_post.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  PostController controller = Get.find();

  @override
  void initState() {
    super.initState();
    controller.getUserData(userConst!.uid);
    controller.getPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Home',
          ),
        ),
        body: controller.postsList.isEmpty
            ? const Center(
                child: CupertinoActivityIndicator(
                color: Colors.black,
              ))
            : ListView.separated(
                itemBuilder: (context, index) => GetBuilder<PostController>(
                    init: PostController(),
                    builder: (controller) {
                      return Container(
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  if (controller.postsList[index].values.single
                                      .ownerImage.isNotEmpty)
                                    CircleAvatar(
                                      radius: 20.0,
                                      backgroundImage: NetworkImage(
                                        controller.postsList[index].values
                                            .single.ownerImage,
                                      ),
                                    ),
                                  if (controller.postsList[index].values.single
                                      .ownerImage.isEmpty)
                                    CircleAvatar(
                                      radius: 20.0,
                                      child: Center(
                                        child: Text(
                                          controller
                                              .postsList[index]
                                              .values
                                              .single
                                              .ownerName
                                              .characters
                                              .first,
                                          style: const TextStyle(
                                            fontSize: 26.0,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ),
                                  space10Horizontal(context),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          controller.postsList[index].values
                                              .single.ownerName,
                                          style: const TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        Text(
                                          controller.postsList[index].values
                                              .single.time,
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const MyDivider(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    controller
                                        .postsList[index].values.single.text,
                                  ),
                                ),
                                if (controller.postsList[index].values.single
                                    .image.isNotEmpty)
                                  Image.network(
                                    controller
                                        .postsList[index].values.single.image,
                                    width: double.infinity,
                                    height: 220.0,
                                    fit: BoxFit.cover,
                                  ),
                                if (controller.postsList[index].values.single
                                    .image.isEmpty)
                                  const MyDivider(),
                                space10Vertical(context),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        '${controller.postsList[index].values.single.likes.length} likes',
                                      ),
                                      Spacer(),
                                      Text(
                                        '${controller.postsList[index].values.single.comments.length} comments',
                                      ),
                                      const Text(
                                        ' - ',
                                      ),
                                      Text(
                                        '${controller.postsList[index].values.single.shares} shares',
                                      ),
                                    ],
                                  ),
                                ),
                                space10Vertical(context),
                                const MyDivider(),
                                Row(
                                  children: [
                                    Expanded(
                                      child: MaterialButton(
                                        onPressed: () {
                                          controller.updatePostLikes(
                                              controller.postsList[index]);
                                        },
                                        child: Icon(
                                          controller.postsList[index].values
                                                  .single.likes
                                                  .any((element) =>
                                                      element ==
                                                      controller.user!.uId)
                                              ? Icons.thumb_up
                                              : Icons.thumb_up_outlined,
                                          size: 16.0,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: MaterialButton(
                                        onPressed: () {},
                                        child: const Icon(
                                          FontAwesomeIcons.comment,
                                          size: 16.0,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: MaterialButton(
                                        onPressed: () async {
                                          if (controller.postsList[index].values
                                              .single.image.isNotEmpty) {
                                            final img = await imageFromURL(
                                              'temp',
                                              controller.postsList[index].values
                                                  .single.image,
                                            );

                                            Share.shareFiles(
                                              [img!.path],
                                              text: controller.postsList[index]
                                                  .values.single.text,
                                            ).whenComplete(() {
                                              controller.updatePostShares(
                                                  controller.postsList[index]);
                                            });
                                          } else {
                                            Share.share(
                                              controller.postsList[index].values
                                                  .single.text,
                                            ).whenComplete(() {
                                              controller.updatePostShares(
                                                  controller.postsList[index]);
                                            });
                                          }
                                        },
                                        child: const Icon(
                                          FontAwesomeIcons.share,
                                          size: 16.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                separatorBuilder: (context, index) => space10Vertical(context),
                itemCount: controller.postsList.length,
              ),
        floatingActionButton: _getFAB());
  }

  SpeedDial _getFAB() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: const IconThemeData(size: 25),
      visible: true,
      curve: Curves.bounceIn,
      spacing: 20,
      spaceBetweenChildren: 20,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.chat),
          onTap: () {
            Get.to(() => UserScreen());
          },
          label: 'Chat',
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w500, color: Colors.black, fontSize: 16.0),
        ),
        SpeedDialChild(
          child: const Icon(Icons.add),
          onTap: () {
            Get.to(() => AddPostScreen());
          },
          label: 'add post',
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w500, color: Colors.black, fontSize: 16.0),
        ),
      ],
    );
  }
}
