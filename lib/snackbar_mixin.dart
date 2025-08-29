
import 'package:flutter/material.dart';

mixin SnackbarMixin<T extends StatefulWidget> on State<T> {
  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
