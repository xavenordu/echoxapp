// lib/src/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echoxapp/providers.dart';
import 'package:echoxapp/src/screens/onboarding_page.dart';
import 'package:echoxapp/src/navigation/main_navigator.dart';

class EchoXapp extends ConsumerWidget {
  const EchoXapp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final onboarding = ref.watch(onboardingStatusProvider);

    return MaterialApp(
      title: 'EchoXapp',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) =>
            onboarding.completed ? const MainNavigator() : const OnboardingPage(),
        '/home': (context) => const MainNavigator(),
      },
    );
  }
}
