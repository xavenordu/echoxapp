import 'package:flutter/material.dart';

class SilhouetteChatScreen extends StatefulWidget {
  const SilhouetteChatScreen({super.key});

  @override
  _SilhouetteChatScreenState createState() => _SilhouetteChatScreenState();
}

class _SilhouetteChatScreenState extends State<SilhouetteChatScreen> {
  final List<Map<String, dynamic>> _messages = [
    // sample messages
    {'from': 'you', 'text': 'I dreamt of falling.'},
    {'from': 'them', 'text': 'Falling is warm. Did you feel calm?'},
  ];
  final TextEditingController _controller = TextEditingController();

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({'from': 'you', 'text': text, 'ts': DateTime.now()});
      _controller.clear();
    });

    // TODO: push message to backend queue for delayed reply
    // for now we simulate by adding a delayed reply locally
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        _messages.add({'from': 'them', 'text': 'You said: "$text" — but different.', 'ts': DateTime.now()});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Silhouette — Message your alternate self', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final m = _messages[i];
                final isYou = m['from'] == 'you';
                return Align(
                  alignment: isYou ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isYou ? Colors.blueAccent.shade200 : Colors.deepPurple.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(m['text'] ?? ''),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'Send something to your other self...'),
                  )),
                  IconButton(onPressed: _send, icon: const Icon(Icons.send)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

