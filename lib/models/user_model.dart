import 'package:flutter/material.dart';

@immutable
class UserModel {
  final String uid;
  final String phone;

  const UserModel({required this.uid});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(uid: json['uid'] as String, email: json['email'] as String, username: json['username'] as String);
  }

  Map<String, dynamic> toJson() {
    return <String, String>{'uid': uid, 'email': email, 'username': username};
  }
}
