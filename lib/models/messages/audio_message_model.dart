import 'package:flutter/material.dart';

@immutable
final class AudioMessageModel {
  final String uid;
  final int createdAt;
  final Duration duration;
  final String mimeType;
  final String name;
  final num size;
  final String content;
  final List<double>? waveForm = <double>[];
  final String type = "audio";

  AudioMessageModel({required this.mimeType, required this.uid, required this.createdAt, required this.duration, required this.name, required this.size, required this.content});

  factory AudioMessageModel.fromJson(Map<String, dynamic> json) {
    return AudioMessageModel(uid: json['uid'], createdAt: json['createdAt'], duration: Duration(milliseconds: json['duration']), name: json['name'], size: json['size'], content: json['content'], mimeType: json['mimeType']);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'uid': uid, 'createdAt': createdAt, 'duration': duration.inMilliseconds, 'name': name, 'size': size, 'mimeType': mimeType, 'content': content, 'type': type};
  }
}
