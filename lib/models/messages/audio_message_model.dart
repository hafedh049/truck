import 'package:flutter/material.dart';

@immutable
final class AudioMessageModel {
  final Map<String, dynamic> author;
  final int createdAt;
  final String id;
  final Duration duration;
  final String mimeType = "aac";
  final String name;
  final num size;
  final String uri;
  final List<double>? waveForm = <double>[];
  final String type = "audio";

  AudioMessageModel({required this.id, required this.author, required this.createdAt, required this.duration, required this.name, required this.size, required this.uri});

  factory AudioMessageModel.fromJson(Map<String, dynamic> json) {
    return AudioMessageModel(author: json['author'], createdAt: json['createdAt'], duration: Duration(milliseconds: json['duration']), name: json['name'], size: json['size'], uri: json['uri'], id: json['id']);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'author': author, 'createdAt': createdAt, 'id': id, 'duration': duration.inMilliseconds, 'name': name, 'size': size, 'mimeType': mimeType, 'uri': uri, 'type': type};
  }
}
