import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_model.g.dart';
part 'post_model.freezed.dart';

@freezed
class PostDataModel with _$PostDataModel {
  factory PostDataModel({
    required String id,
    required String text,
    required String time,
    required String image,
    required String ownerName,
    required List<String> likes,
    required int shares,
    required List<CommentDataModel> comments,
  }) = _PostDataModel;

  factory PostDataModel.fromJson(Map<String, dynamic> json) =>
      _$PostDataModelFromJson(json);
}

@freezed
class CommentDataModel with _$CommentDataModel {
  factory CommentDataModel({
    required String id,
    required String text,
    required String time,
    required String ownerName,
  }) = _CommentDataModel;

  factory CommentDataModel.fromJson(Map<String, dynamic> json) =>
      _$CommentDataModelFromJson(json);
}
