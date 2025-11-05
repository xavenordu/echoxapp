import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:echoxapp/src/widgets/animated_glitch.dart';

class DreamJournalScreen extends StatefulWidget {
  const DreamJournalScreen({super.key});

  @override
  _DreamJournalScreenState createState() => _DreamJournalScreenState();
}

class _DreamJournalScreenState extends State<DreamJournalScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _dreams = []; // replace with repo streaming

  void _saveDream() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final id = const Uuid().v4();
    final entry = {
      'id': id,
      'text': text,
      'createdAt': DateTime.now().toIso8601String(),
      'edited': false,
    };
    setState(() {
      _dreams.insert(0, entry);
      _controller.clear();
    });

    // TODO: save to repository/firestore and schedule possible perturbation
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Unreality — Dream Journal', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            AnimatedGlitch(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _controller,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Write your dream... fragments, images, feelings.',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _saveDream,
              icon: const Icon(Icons.save),
              label: const Text('Save Dream'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _dreams.length,
                itemBuilder: (context, idx) {
                  final d = _dreams[idx];
                  // A placeholder 'edited' flag will trigger a subtle visual cue
                  final edited = d['edited'] as bool? ?? false;
                  return Card(
                    color: edited ? Colors.deepPurple.shade900 : Colors.white12,
                    child: ListTile(
                      title: Text(d['text'] ?? ''),
                      subtitle: Text(d['createdAt'] ?? ''),
                      trailing: edited ? const Icon(Icons.flash_on) : null,
                      onTap: () {
                        // open detail / truth check
                      },
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
