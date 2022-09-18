import 'package:feed/Controller/post_controller.dart';
import 'package:feed/Model/post_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

class CommentsScreen extends StatelessWidget {
  final List<CommentDataModel> commentList;
  final String id;
  const CommentsScreen({required this.commentList, Key? key, required this.id})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Comments',
        ),
      ),
      body: GetBuilder<PostController>(
          init: Get.find<PostController>(),
          builder: (controller) {
            return ListView.builder(
                itemCount: commentList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Slidable(
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          icon: Icons.delete,
                          label: "delete",
                          backgroundColor: Colors.red,
                          onPressed: (context) {
                            controller.deleteComment(
                              id: id,
                              comment: commentList[index].text,
                              time: commentList[index].time,
                            );
                            commentList.removeAt(index);
                            controller.update();
                          },
                        )
                      ],
                    ),
                    child: Card(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20.0,
                                      child: Center(
                                        child: Text(
                                          commentList[index]
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
                                    const SizedBox(width: 10),
                                    Text(
                                      commentList[index].ownerName,
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 15),
                                    ),
                                  ],
                                ),
                                Text(
                                  commentList[index].time,
                                  style: const TextStyle(color: Colors.grey),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    commentList[index].text,
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                });
          }),
    );
  }
}
