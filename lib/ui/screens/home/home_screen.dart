import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feed/Controller/post_controller.dart';
import 'package:feed/Utils/image_from_url.dart';
import 'package:feed/ui/components/divider.dart';
import 'package:feed/ui/components/spacing.dart';
import 'package:feed/ui/screens/add_post/add_post_screen.dart';
import 'package:feed/ui/screens/comments/comments_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController commentController = TextEditingController();
  CollectionReference reference =
      FirebaseFirestore.instance.collection('posts');

  PostController controller = Get.find();

  @override
  void initState() {
    super.initState();
    setState(() {
      controller.getPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Home',
          ),
        ),
        body: GetBuilder<PostController>(
            init: Get.find<PostController>(),
            builder: (controller) {
              return FutureBuilder(
                future: reference.get(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  List<Widget> children;
                  if (snapshot.hasData) {
                    children = <Widget>[
                      ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) => Slidable(
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            children: [
                              SlidableAction(
                                icon: Icons.delete,
                                label: "delete",
                                backgroundColor: Colors.red,
                                onPressed: (context) {
                                  var docId = snapshot.data.docs[index].id;
                                  controller.deletePost(id: docId);
                                  controller.postsList.removeAt(index);
                                  controller.update();
                                },
                              )
                            ],
                          ),
                          child: Container(
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      if (controller
                                              .postsList[index].ownerName !=
                                          '')
                                        CircleAvatar(
                                          radius: 20.0,
                                          child: Center(
                                            child: Text(
                                              controller.postsList[index]
                                                  .ownerName.characters.first,
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
                                              controller
                                                  .postsList[index].ownerName,
                                              style: const TextStyle(
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            Text(
                                              controller.postsList[index].time,
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
                                        controller.postsList[index].text,
                                      ),
                                    ),
                                    if (controller
                                        .postsList[index].image.isNotEmpty)
                                      Image.network(
                                        controller.postsList[index].image,
                                        width: double.infinity,
                                        height: 220.0,
                                        fit: BoxFit.cover,
                                      ),
                                    if (controller
                                        .postsList[index].image.isEmpty)
                                      const MyDivider(),
                                    space10Vertical(context),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            '${controller.postsList[index].likes.length} likes',
                                          ),
                                          const Spacer(),
                                          InkWell(
                                            onTap: () {
                                              var docId =
                                                  snapshot.data.docs[index].id;
                                              Get.to(() => CommentsScreen(
                                                    commentList: controller
                                                        .postsList[index]
                                                        .comments,
                                                    id: docId,
                                                  ));
                                            },
                                            child: Text(
                                              '${controller.postsList[index].comments.length} comments',
                                            ),
                                          ),
                                          const Text(
                                            ' - ',
                                          ),
                                          Text(
                                            '${controller.postsList[index].shares} shares',
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
                                              controller.didILike(controller
                                                      .postsList[index].likes)
                                                  ? Icons.thumb_up
                                                  : Icons.thumb_up_outlined,
                                              size: 16.0,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: MaterialButton(
                                            onPressed: () {
                                              Get.defaultDialog(
                                                title: "add comment",
                                                textCancel: "Confirm",
                                                content: TextFormField(
                                                  controller: commentController,
                                                  keyboardType:
                                                      TextInputType.text,
                                                  decoration: InputDecoration(
                                                    isDense: false,
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                      horizontal: 20.0,
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        15.0,
                                                      ),
                                                    ),
                                                    label: const Text(
                                                      'Comment',
                                                    ),
                                                  ),
                                                ),
                                                onCancel: () {
                                                  var docId = snapshot
                                                      .data.docs[index].id;
                                                  DateTime now = DateTime.now();
                                                  String formattedDate =
                                                      DateFormat(
                                                              'kk:mm EEE d MMM')
                                                          .format(now);
                                                  controller.addComment(
                                                      id: docId,
                                                      comment: commentController
                                                          .text,
                                                      time: formattedDate);
                                                  commentController.clear();
                                                },
                                              );
                                            },
                                            child: const Icon(
                                              FontAwesomeIcons.comment,
                                              size: 16.0,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: MaterialButton(
                                            onPressed: () async {
                                              if (controller.postsList[index]
                                                  .image.isNotEmpty) {
                                                final img = await imageFromURL(
                                                  'temp',
                                                  controller
                                                      .postsList[index].image,
                                                );

                                                Share.shareFiles(
                                                  [img!.path],
                                                  text: controller
                                                      .postsList[index].text,
                                                ).whenComplete(() {
                                                  controller.updatePostShares(
                                                      controller
                                                          .postsList[index]);
                                                });
                                              } else {
                                                Share.share(
                                                  controller
                                                      .postsList[index].text,
                                                ).whenComplete(() {
                                                  controller.updatePostShares(
                                                      controller
                                                          .postsList[index]);
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
                          ),
                        ),
                        separatorBuilder: (context, index) =>
                            space10Vertical(context),
                        itemCount: controller.postsList.length,
                      ),
                    ];
                  } else if (snapshot.hasError) {
                    children = const <Widget>[
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text('There is no post'),
                      ),
                    ];
                  } else {
                    children = <Widget>[
                      const Center(
                          child: CupertinoActivityIndicator(
                        color: Colors.black,
                      )),
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text('Awaiting result...'),
                      ),
                    ];
                  }
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: children,
                      ),
                    ),
                  );
                },
              );
            }),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            Get.to(() => AddPostScreen());
          },
        ));
  }
}
