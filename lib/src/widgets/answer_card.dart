import 'package:flutter/material.dart';

class AnswerCard extends StatefulWidget {
  final String questionId;
  final Function(String answer) onSubmit;
  final String? initialAnswer;

  const AnswerCard({
    super.key,
    required this.questionId,
    required this.onSubmit,
    this.initialAnswer,
  });

  @override
  State<AnswerCard> createState() => _AnswerCardState();
}

class _AnswerCardState extends State<AnswerCard> {
  late final TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialAnswer);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitAnswer() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    widget.onSubmit(text);
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isEditing && widget.initialAnswer != null) {
      // Show readonly view with edit button
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.initialAnswer!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => setState(() => _isEditing = true),
                icon: const Icon(Icons.edit),
                label: const Text('Edit Response'),
              ),
            ],
          ),
        ),
      );
    }

    // Show edit view with text field
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Write your response...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (widget.initialAnswer != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                        _controller.text = widget.initialAnswer!;
                      });
                    },
                    child: const Text('Cancel'),
                  ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _submitAnswer,
                  child: const Text('Save Response'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}