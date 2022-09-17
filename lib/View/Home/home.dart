import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feed/Controller/postController.dart';
import 'package:feed/View/Home/comments.dart';
import 'package:feed/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'add_post.dart';
import 'package:intl/intl.dart';


class Home extends StatefulWidget {
  final String uId;

 const Home({
    Key? key,
    this.uId = '',
  }) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController commentController = TextEditingController();
  CollectionReference reference = FirebaseFirestore.instance.collection('posts');

  PostController controller = Get.find();

  @override
  void initState() {
    super.initState();
   if(widget.uId != ''){
     controller.getUserData(widget.uId);
   }
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
        body:
        GetBuilder<PostController>(
            init: PostController(),
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
                                      if( controller
                                          .postsList[index]
                                          .values
                                          .single
                                          .ownerName != '')
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
                                          const Spacer(),
                                          InkWell(
                                            onTap: () {
                                              var docId = snapshot.data.docs[index].id;
                                              Get.to(() =>  Comments(commentList: controller.postsList[index].values.single.comments,id: docId,));
                                            },
                                            child: Text(
                                              '${controller.postsList[index].values.single.comments.length} comments',
                                            ),
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
                                                  controller.uId)
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
                                                  keyboardType: TextInputType.text,
                                                  decoration: InputDecoration(
                                                    isDense: false,
                                                    contentPadding: const EdgeInsets.symmetric(
                                                      horizontal: 20.0,
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(
                                                        15.0,
                                                      ),
                                                    ),
                                                    label: const Text(
                                                      'Comment',
                                                    ),
                                                  ),
                                                ),
                                                onCancel: (){
                                                  var docId = snapshot.data.docs[index].id;
                                                  DateTime now = DateTime.now();
                                                  String formattedDate = DateFormat('kk:mm EEE d MMM').format(now);
                                                  controller.addComment(
                                                      id: docId,
                                                      comment: commentController.text,
                                                      time: formattedDate
                                                  );
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
                          ),
                        ),
                        separatorBuilder: (context, index) => space10Vertical(context),
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
          onPressed: (){
            Get.to(() => AddPostScreen());
          },
        )
    );
  }
}
