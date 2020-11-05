import 'package:flutter/material.dart';

void showAlert(BuildContext context, String text) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text("Error"),
      content: Text(text),
    ),
  );
}
