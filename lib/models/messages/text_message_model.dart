import 'package:flutter/material.dart';

@immutable
final class TextMessageModel {
  const TextMessageModel({required this.id, required this.uid, required this.createdAt, required this.text}) : type = 'text';

  factory TextMessageModel.fromJson(Map<String, dynamic> json) {
    return TextMessageModel(uid: json['uid'], createdAt: json['createdAt'], text: json['text'], id: json['id']);
  }

  final String uid;
  final num createdAt;
  final String id;
  final String text;
  final String type;

  Map<String, dynamic> toJson() => <String, dynamic>{'uid': uid, 'createdAt': createdAt, 'id': id, 'text': text, 'type': type};
}
