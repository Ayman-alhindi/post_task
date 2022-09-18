import 'dart:io';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

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
