import 'package:flutter/material.dart';

@immutable
final class AudioMessageModel {
  final String uid;
  final int createdAt;
  final String id;
  final Duration duration;
  final String mimeType;
  final String name;
  final num size;
  final String uri;
  final List<double>? waveForm = <double>[];
  final String type = "audio";

  AudioMessageModel({required this.mimeType, required this.id, required this.uid, required this.createdAt, required this.duration, required this.name, required this.size, required this.uri});

  factory AudioMessageModel.fromJson(Map<String, dynamic> json) {
    return AudioMessageModel(uid: json['uid'], createdAt: json['createdAt'], duration: Duration(milliseconds: json['duration']), name: json['name'], size: json['size'], uri: json['uri'], id: json['id'], mimeType: json['mimeType']);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'uid': uid, 'createdAt': createdAt, 'id': id, 'duration': duration.inMilliseconds, 'name': name, 'size': size, 'mimeType': mimeType, 'uri': uri, 'type': type};
  }
}
