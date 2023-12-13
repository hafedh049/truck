import 'package:flutter/material.dart';

@immutable
final class ImageMessageModel {
  const ImageMessageModel({required this.id, required this.createdAt, required this.mimeType, required this.uid, required this.name, required this.size, required this.uri});

  factory ImageMessageModel.fromJson(Map<String, dynamic> json) {
    return ImageMessageModel(mimeType: json['mimeType'], uid: json['uid'], name: json['name'], size: json['size'], uri: json['uri'], createdAt: json['createdAt'], id: json['id']);
  }

  final num createdAt;
  final String name;
  final String id;
  final String uid;
  final String mimeType;
  final num size;
  final String uri;
  final String type = "image";

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'mimeType': mimeType, 'uid': uid, 'name': name, 'size': size, 'uri': uri, 'type': type, 'id': id, 'createdAt': createdAt};
  }
}
