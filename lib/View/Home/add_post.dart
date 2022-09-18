import 'package:feed/Controller/postController.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddPostScreen extends StatelessWidget {
  final postTextController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  AddPostScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Add new post',
          ),
        ),
        body: GetBuilder<PostController>(
            init: PostController(),
            builder: (controller) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: postTextController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'post body must not be empty';
                            }

                            return null;
                          },
                          keyboardType: TextInputType.text,
                          maxLines: null,
                          autofocus: true,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'What\'s in your mind?',
                          ),
                        ),
                      ),
                      if (controller.postImage != null)
                        Expanded(
                          child: Container(
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                15.0,
                              ),
                            ),
                            child: Image.file(
                              controller.postImage!,
                              width: double.infinity,
                              height: 230.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                controller.pickPostImage();
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.add,
                                  ),
                                  Text(
                                    'Add photo',
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (controller.postImage != null)
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  controller.deletePostImage();
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    Text(
                                      'delete photo',
                                      style: TextStyle(
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      Container(
                        height: 42.0,
                        width: double.infinity,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(
                            15.0,
                          ),
                        ),
                        child: MaterialButton(
                          height: 42.0,
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              controller.createPost(
                                  postText: postTextController.text);
                            }
                          },
                          child: controller.pick
                              ? const CupertinoActivityIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Post',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }));
  }
}
