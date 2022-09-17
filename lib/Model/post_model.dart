class PostDataModel {

  PostDataModel({
    required this.text,
    required this.time,
    required this.image,
    required this.ownerName,
    required this.likes,
    required this.shares,
    required this.comments,
  });

  late final String text;
  late final String time;
  late final String image;
  late final String ownerName;
  late final List<String> likes;
  late int shares;
  late final List<CommentDataModel> comments;

  PostDataModel.fromJson(Map<String, dynamic> json) {
    text = json['text'] ?? '';
    time = json['time'] ?? '';
    image = json['image'] ?? '';
    ownerName = json['ownerName'] ?? '';
    if(json['likes'] != null){
      likes = List.from(json['likes']).map((e) => e.toString()).toList();
    }else{
      likes = [];
    }
    shares = json['shares'] ?? 0;
    comments = List.from(json['comments'])
        .map((e) => CommentDataModel.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'time': time,
      'image': image,
      'ownerName': ownerName,
      'likes': likes.map((element) => element).toList(),
      'shares': shares,
      'comments': comments.map((element) => element.toJson()).toList(),
    };
  }
}

class CommentDataModel {
  CommentDataModel({
    required this.text,
    required this.time,
    required this.ownerName,
  });

  late final String text;
  late final String time;
  late final String ownerName;

  CommentDataModel.fromJson(Map<String, dynamic> json) {
    text = json['text'] ?? '';
    time = json['time'] ?? '';
    ownerName = json['ownerName'] ?? '';
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'time': time,
      'ownerName': ownerName,
    };
  }
}
