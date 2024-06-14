import 'package:pocketbase/pocketbase.dart';
import 'package:flutter/material.dart';

final pb = PocketBase("https://pb.shccricket.com/");


class ErrorDialog extends StatelessWidget {
  const ErrorDialog({super.key, required this.error});
  final error;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Something went wrong"),
      content: Text(error.toString()),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
    );
  }
}