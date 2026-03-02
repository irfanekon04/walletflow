import 'package:flutter/material.dart';

class NoteField extends StatelessWidget {
  const NoteField({
    super.key,
    required TextEditingController noteController,
  }) : _noteController = noteController;

  final TextEditingController _noteController;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _noteController,
      decoration: const InputDecoration(labelText: 'Note (optional)'),
    );
  }
}
