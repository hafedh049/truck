//COLORS
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:truck/models/user_model.dart';

const Color transparent = Colors.transparent;
const Color white = Colors.white;
Color blue = Colors.blue.withOpacity(.8);
const Color gray = Color.fromARGB(255, 51, 56, 66);

String documentsPath = "";

Box? userLocalSettings;

UserModel? user;
