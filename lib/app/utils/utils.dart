import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class Utils {
  int millisecond = 300;

  void failureToast(String message, BuildContext context) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.red.shade600,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void successToast(String message, BuildContext context) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.green.shade600,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  static Future<bool> checkInternetConnection() async {
    bool value = false;
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        value = true;
      }
    } on SocketException catch (_) {
      print('not connected');
      value = false;
    }
    return value;
  }

  static Future<bool?> confirmDialog({
    required String title,
    required String message,
    String cancelText = "CANCEL",
    String confirmText = "CONFIRM",
  }) {
    return showDialog<bool>(
      context: Get.context!,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(Get.context!).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(Get.context!).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}
