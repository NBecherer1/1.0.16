import 'package:flutter/material.dart';
import 'dart:async';


class FlashHelper {

  static void errorBar({Key? key, required BuildContext context, required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        key: key,
        backgroundColor: Colors.red[500],
        content: Text(message,
          style: const TextStyle(
              color: Colors.white
          ),
        ),
      ),
    );
  }

  static void successBar({Key? key, required BuildContext context, required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        key: key,
        backgroundColor: Colors.green[300],
        content: Text(message),
      ),
    );
  }

  static void infoBar({Key? key, required BuildContext context, required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        key: key,
        backgroundColor: Colors.orange[600],
        content: Text(message,
          style: const TextStyle(
            color: Colors.white
          ),
        ),
      ),
    );
  }
}

