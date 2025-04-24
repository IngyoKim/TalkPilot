  import 'package:flutter/material.dart';
  import 'package:fluttertoast/fluttertoast.dart';

  class ToastMessage {
    /// Show a custom toast message
    static void show(
    String message, {
    ToastGravity gravity = ToastGravity.BOTTOM,
    Color backgroundColor = Colors.black,
    Color textColor = Colors.white,
    double fontSize = 14.0,
    Toast toastLength = Toast.LENGTH_SHORT,
  }) {
    Fluttertoast.showToast(
      msg: message,
      gravity: gravity,
      toastLength: toastLength,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: fontSize,
      );
    }
  }
