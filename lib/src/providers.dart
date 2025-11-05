import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Use relative imports within `lib/src` to avoid package name mismatches.
import 'services/firebase_service.dart';
import 'repositories/dream_repository.dart';
import 'models/dream_entry.dart';

final firebaseServiceProvider = Provider<FirebaseService>((ref) => FirebaseService.instance);

final dreamRepositoryProvider = Provider<DreamRepository>((ref) {
  final firebase = ref.read(firebaseServiceProvider);
  return DreamRepository(firebaseService: firebase);
});

final dreamsProvider = FutureProvider<List<DreamEntry>>((ref) async {
  final repo = ref.read(dreamRepositoryProvider);
  return repo.fetchDreams();
});

/// Theme mode provider (returns a ThemeMode). Using a plain Provider here avoids
/// referencing `StateProvider` in case the package import can't be resolved.
final themeProvider = Provider<ThemeMode>((ref) => ThemeMode.system);
