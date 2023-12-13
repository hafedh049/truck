import 'package:flutter/material.dart';

@immutable
final class ImageMessageModel {
  const ImageMessageModel({required this.createdAt, required this.mimeType, required this.uid, required this.name, required this.size, required this.content});

  factory ImageMessageModel.fromJson(Map<String, dynamic> json) {
    return ImageMessageModel(mimeType: json['mimeType'], uid: json['uid'], name: json['name'], size: json['size'], content: json['content'], createdAt: json['createdAt']);
  }

  final num createdAt;
  final String name;
  final String uid;
  final String mimeType;
  final num size;
  final String content;
  final String type = "image";

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'mimeType': mimeType, 'uid': uid, 'name': name, 'size': size, 'content': content, 'type': type, 'createdAt': createdAt};
  }
}
