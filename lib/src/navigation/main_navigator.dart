import 'package:flutter/material.dart';
import 'package:echoxapp/src/screens/dream_journal_screen.dart';
import 'package:echoxapp/src/screens/silhouette_chat_screen.dart';
import 'package:echoxapp/src/screens/paradox_reflection_screen.dart';
import 'package:echoxapp/src/screens/timeline_page.dart';

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DreamJournalScreen(),
    SilhouetteChatScreen(),
    ParadoxReflectionScreen(),
    TimelinePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int idx) {
          setState(() => _selectedIndex = idx);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.bedtime), label: 'Unreality'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Silhouette'),
          NavigationDestination(icon: Icon(Icons.messenger), label: 'Paradox'),
          NavigationDestination(icon: Icon(Icons.timeline), label: 'Timeline'),
        ],
      ),
    );
  }
}