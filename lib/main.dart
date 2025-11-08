import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:echoxapp/app.dart';
import 'package:echoxapp/src/models/question.dart';
import 'package:echoxapp/src/models/answer.dart';
import 'package:echoxapp/src/models/onboarding_status.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Load environment variables early
  await dotenv.load(fileName: ".env");

  // 🔹 Initialize Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyArA3GGIh7FYkZn6xogBVG4jOAMSCwoKGE',
      appId: '1:674682432375:web:789791384585f1cd96cf72',
      messagingSenderId: '674682432375',
      projectId: 'echoxapp',
      authDomain: 'echoxapp.firebaseapp.com',
      storageBucket: 'echoxapp.firebasestorage.app',
      measurementId: 'G-RN531B4VG9',
    ),
  );

  // 🔹 Initialize Supabase (with fallback safety)
  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? 'https://your-supabase-url.supabase.co';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? 'your-anon-key';

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // 🔹 Initialize Hive
  await Hive.initFlutter();

  // Register all adapters
  Hive
    ..registerAdapter(QuestionAdapter())
    ..registerAdapter(AnswerAdapter())
    ..registerAdapter(OnboardingStatusAdapter());

  // Open required Hive boxes
  await Future.wait([
    Hive.openBox('questions'),
    Hive.openBox('answers'),
    Hive.openBox('settings'),
    Hive.openBox('onboarding'),
  ]);

  // 🔹 Launch the app
  runApp(ProviderScope(child: const EchoXapp()));
}
