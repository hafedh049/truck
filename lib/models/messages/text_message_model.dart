import 'package:flutter/material.dart';

@immutable
final class TextMessageModel {
  const TextMessageModel({required this.uid, required this.createdAt, required this.content}) : type = 'text';

  factory TextMessageModel.fromJson(Map<String, dynamic> json) {
    return TextMessageModel(uid: json['uid'], createdAt: json['createdAt'], content: json['content']);
  }

  final String uid;
  final num createdAt;
  final String content;
  final String type;

  Map<String, dynamic> toJson() => <String, dynamic>{'uid': uid, 'createdAt': createdAt, 'content': content, 'type': type};
}
