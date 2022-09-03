import 'dart:io';
import 'package:hexcolor/hexcolor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

User? userConst;

const String regularGrey = 'E9E8E7';

double responsiveValue(BuildContext context, double value) =>
    MediaQuery.of(context).size.width * (value / 375.0);

space10Vertical(BuildContext context) => SizedBox(
      height: responsiveValue(context, 10.0),
    );

space10Horizontal(BuildContext context) => SizedBox(
      width: responsiveValue(context, 10.0),
    );

space20Vertical(BuildContext context) => SizedBox(
      height: responsiveValue(context, 20.0),
    );

class MyDivider extends StatelessWidget {
  const MyDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 1.0,
      color: HexColor(regularGrey),
    );
  }
}

Future<File?> imageFromURL(String name, String imageUrl) async {
  if (imageUrl.isEmpty) return null;

  Directory? tempDir = await () async {
    if (Platform.isIOS) {
      return await getApplicationDocumentsDirectory();
    }
    return await getExternalStorageDirectory();
  }();
  String tempPath = tempDir!.path;
  File file = File('$tempPath/' + name + '.png');
  Response response = await get(Uri.parse(imageUrl));
  if (response.statusCode != 200) return null;
  await file.writeAsBytes(response.bodyBytes);

  return file;
}
