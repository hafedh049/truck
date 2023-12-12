import 'package:flutter/material.dart';

@immutable
final class FileMessageModel {
  const FileMessageModel({required this.id, required this.author, required this.mimeType, required this.name, required this.size, required this.uri, required this.createdAt}) : type = 'file';

  factory FileMessageModel.fromJson(Map<String, dynamic> json) {
    return FileMessageModel(
      mimeType: json['mimeType'],
      name: json['name'],
      size: json['size'],
      uri: json['uri'],
      author: json['author'],
      createdAt: json['createdAt'],
      id: json['id'],
    );
  }

  final num createdAt;
  final String mimeType;
  final Map<String, dynamic> author;
  final String name;
  final num size;
  final String uri;
  final String id;
  final String type;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'mimeType': mimeType, 'name': name, 'size': size, 'uri': uri, 'id': id, 'type': type};
  }
}
