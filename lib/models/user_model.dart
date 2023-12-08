import 'package:flutter/material.dart';

@immutable
class UserModel {
  final String uid;
  final String password;
  final String email;
  final String username;
  final String type;

  const UserModel({required this.type, required this.uid, required this.password, required this.email, required this.username});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(type: json["type"] as String, uid: json['uid'] as String, password: json['password'] as String, email: json['email'] as String, username: json['username'] as String);
  }

  Map<String, dynamic> toJson() {
    return <String, String>{'uid': uid, 'password': password, 'email': email, 'username': username, "type": type};
  }
}
