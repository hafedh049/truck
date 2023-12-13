import 'package:flutter/material.dart';

@immutable
final class FileMessageModel {
  const FileMessageModel({required this.uid, required this.mimeType, required this.name, required this.size, required this.content, required this.createdAt});

  factory FileMessageModel.fromJson(Map<String, dynamic> json) {
    return FileMessageModel(mimeType: json['mimeType'], name: json['name'], size: json['size'], content: json['content'], uid: json['uid'], createdAt: json['createdAt']);
  }

  final num createdAt;
  final String mimeType;
  final String uid;
  final String name;
  final num size;
  final String content;
  final String type = "file";

  Map<String, dynamic> toJson() => <String, dynamic>{'uid': uid, 'mimeType': mimeType, 'name': name, 'size': size, 'content': content, 'type': type, 'createdAt': createdAt};
}
