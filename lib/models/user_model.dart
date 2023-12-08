import 'package:flutter/material.dart';

@immutable
class UserModel {
  final String uid;
  final String email;
  final String username;

  const UserModel({required this.uid, required this.email, required this.username});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(uid: json['uid'] as String, email: json['email'] as String, username: json['username'] as String);
  }

  Map<String, dynamic> toJson() {
    return <String, String>{'uid': uid, 'email': email, 'username': username};
  }
}
