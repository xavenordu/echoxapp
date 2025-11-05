import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:echoxapp/app.dart';
import 'package:echoxapp/src/models/question.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (required before using any Firebase services)
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


  // Initialize Supabase
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL', // Replace with your Supabase project URL
    anonKey: 'YOUR_SUPABASE_ANON_KEY', // Replace with your public anon key
  );

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(QuestionAdapter());

  // Open Hive boxes used by the app
  await Hive.openBox('questions');
  await Hive.openBox('answers');

  // Start the app. Use the actual class defined in lib/app.dart
  // ProviderScope is not necessarily a const constructor in all riverpod versions,
  // so avoid using const at the top-level to prevent 'invalid constant value' errors.
  runApp(ProviderScope(child: const EchoXapp()));
}
