// manual_entry.dart
import 'package:flutter/material.dart';

class ManualEntryComponent extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSubmit; // Accepting the callback function

  const ManualEntryComponent(
      {super.key,
      required this.controller,
      required this.focusNode,
      required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(children: [
          Expanded(
              child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                      labelText: 'Enter the code manually',
                      border: OutlineInputBorder()),
                  onSubmitted: (value) => onSubmit())),
          ElevatedButton(
              onPressed: onSubmit, // Using the callback function
              child: Icon(Icons.send, color: Colors.indigo, size: 25))
        ]));
  }
}
