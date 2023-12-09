import 'package:flutter/material.dart';

@immutable
class UserModel {
  final String uid;
  final String phone;

  const UserModel({required this.uid, required this.phone});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(uid: json['uid'] as String, phone: json['email'] as String);
  }

  Map<String, dynamic> toJson() => <String, String>{'uid': uid, 'phone': phone};
}
