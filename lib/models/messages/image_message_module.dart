import 'package:flutter/material.dart';

@immutable
final class ImageMessageModel {
  const ImageMessageModel({required this.id, required this.createdAt, required this.mimeType, required this.author, required this.name, required this.size, required this.uri});

  factory ImageMessageModel.fromJson(Map<String, dynamic> json) {
    return ImageMessageModel(mimeType: json['mimeType'], author: json['author'], name: json['name'], size: json['size'], uri: json['uri'], createdAt: json['createdAt'], id: json['id']);
  }

  final num createdAt;
  final String name;
  final String id;
  final Map<String, dynamic> author;
  final String mimeType;
  final num size;
  final String uri;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'mimeType': mimeType, 'author': author, 'name': name, 'size': size, 'uri': uri, 'id': id};
  }
}
