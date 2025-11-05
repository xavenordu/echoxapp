import 'package:flutter/material.dart';

class ParadoxReflectionScreen extends StatefulWidget {
  const ParadoxReflectionScreen({super.key});

  @override
  _ParadoxReflectionScreenState createState() => _ParadoxReflectionScreenState();
}

class _ParadoxReflectionScreenState extends State<ParadoxReflectionScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _qa = [
    {'q': 'What would you erase if no one remembered?', 'a': null},
    {'q': 'When do you feel most yourself?', 'a': null},
  ];

  void _answer(int index) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _qa[index]['a'] = text;
      _controller.clear();
    });

    // TODO: persist and let "reflection engine" use previous answers to reply later
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Paradox — Daily Reflection', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _qa.length,
                itemBuilder: (context, idx) {
                  final item = _qa[idx];
                  return Card(
                    child: ListTile(
                      title: Text(item['q']),
                      subtitle: item['a'] != null ? Text('Your answer: ${item['a']}') : null,
                      trailing: item['a'] == null
                          ? IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                // open a modal to answer
                                showModalBottomSheet(
                                  context: context,
                                  builder: (ctx) => Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(item['q'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                        TextField(controller: _controller),
                                        const SizedBox(height: 8),
                                        ElevatedButton(
                                          onPressed: () {
                                            _answer(idx);
                                            Navigator.of(ctx).pop();
                                          },
                                          child: const Text('Save'),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )
                          : IconButton(
                              icon: const Icon(Icons.visibility),
                              onPressed: () {
                                // View or discuss later when 'AI-you' starts replying
                              },
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
