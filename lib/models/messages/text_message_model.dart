import 'package:flutter/material.dart';

@immutable
final class TextMessageModel {
  const TextMessageModel({required this.id, required this.author, required this.createdAt, required this.text}) : type = 'text';

  factory TextMessageModel.fromJson(Map<String, dynamic> json) {
    return TextMessageModel(author: json['author'], createdAt: json['createdAt'], text: json['text'], id: json['id']);
  }

  final Map<String, dynamic> author;
  final num createdAt;
  final String id;
  final String text;
  final String type;

  Map<String, dynamic> toJson() => <String, dynamic>{'author': author, 'createdAt': createdAt, 'id': id, 'text': text, 'type': type};
}
