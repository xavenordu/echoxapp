import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:echoxapp/src/services/firebase_service.dart';
import 'package:echoxapp/src/services/ai_mirror_service.dart';
import 'package:echoxapp/src/repositories/dream_repository.dart';
import 'package:echoxapp/src/repositories/dream_sql_repository.dart';
import 'package:echoxapp/src/repositories/dream_firestore_repository.dart';
import 'package:echoxapp/src/repositories/question_repository.dart';
import 'package:echoxapp/src/repositories/reflection_repository.dart';
import 'package:echoxapp/src/models/answer.dart';
import 'package:echoxapp/src/models/onboarding_status.dart';

/// ─────────────────────────────────────────────────────────────
/// THEME PROVIDER
/// ─────────────────────────────────────────────────────────────
final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

/// ─────────────────────────────────────────────────────────────
/// FIREBASE SERVICE PROVIDER
/// ─────────────────────────────────────────────────────────────
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService.instance;
});

/// ─────────────────────────────────────────────────────────────
/// DREAM REPOSITORIES (LOCAL + FIRESTORE + COMBINED)
/// ─────────────────────────────────────────────────────────────
final dreamSqlRepositoryProvider = Provider<DreamSqlRepository>((ref) {
  return DreamSqlRepository(); // Local Drift-based repository
});

final dreamFirestoreRepositoryProvider =
    Provider<DreamFirestoreRepository>((ref) {
  return DreamFirestoreRepository(FirebaseFirestore.instance);
});

final dreamRepositoryProvider = Provider<DreamRepository>((ref) {
  final local = ref.watch(dreamSqlRepositoryProvider);
  final remote = ref.watch(dreamFirestoreRepositoryProvider);
  return DreamRepository(localDb: local, remoteDb: remote);
});

/// ─────────────────────────────────────────────────────────────
/// AI MIRROR SERVICE PROVIDER
/// ─────────────────────────────────────────────────────────────
final aiMirrorServiceProvider = Provider<AiMirrorService>((ref) {
  return AiMirrorService();
});

/// ─────────────────────────────────────────────────────────────
/// QUESTION REPOSITORY PROVIDER
/// ─────────────────────────────────────────────────────────────
final questionRepositoryProvider =
    FutureProvider<QuestionRepository>((ref) async {
  return await QuestionRepository.instance;
});

/// ─────────────────────────────────────────────────────────────
/// REFLECTION REPOSITORY PROVIDER
/// ─────────────────────────────────────────────────────────────
final reflectionRepositoryProvider = Provider<ReflectionRepository>((ref) {
  return ReflectionRepository();
});

/// ─────────────────────────────────────────────────────────────
/// MIRROR MODE STATE
/// ─────────────────────────────────────────────────────────────
final inMirrorModeProvider = StateProvider<bool>((ref) => false);

/// Secure storage instance for simple secure prefs used by providers
final _secureStorage = FlutterSecureStorage();

/// ─────────────────────────────────────────────────────────────
/// ONBOARDING STATE MANAGEMENT
/// ─────────────────────────────────────────────────────────────
class OnboardingNotifier extends StateNotifier<OnboardingStatus> {
  OnboardingNotifier() : super(const OnboardingStatus()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final completedRaw = await _secureStorage.read(key: 'onboarding_completed');
      final useCloudRaw = await _secureStorage.read(key: 'use_cloud_backup');
      final consentRaw = await _secureStorage.read(key: 'consent_given');
      final darkModeRaw = await _secureStorage.read(key: 'dark_mode');
      final notificationsRaw = await _secureStorage.read(key: 'notifications_enabled');

      state = state.copyWith(
        completed: completedRaw == 'true',
        useCloudBackup: useCloudRaw == 'true',
        consentGiven: consentRaw == 'true',
        darkMode: darkModeRaw == 'true',
        notificationsEnabled: notificationsRaw == 'true',
        completedAt: completedRaw == 'true' ? DateTime.now() : null,
      );
    } catch (_) {
      // ignore read errors
    }
  }

  Future<void> setCloudBackup(bool value) async {
    state = state.copyWith(useCloudBackup: value);
    await _secureStorage.write(key: 'use_cloud_backup', value: value ? 'true' : 'false');
  }

  Future<void> setDarkMode(bool value) async {
    state = state.copyWith(darkMode: value);
    await _secureStorage.write(key: 'dark_mode', value: value ? 'true' : 'false');
  }

  Future<void> setNotifications(bool value) async {
    state = state.copyWith(notificationsEnabled: value);
    await _secureStorage.write(key: 'notifications_enabled', value: value ? 'true' : 'false');
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(
      completed: true,
      completedAt: DateTime.now(),
      consentGiven: true,
    );
    await _secureStorage.write(key: 'onboarding_completed', value: 'true');
    await _secureStorage.write(key: 'consent_given', value: 'true');
  }
}

final onboardingStatusProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingStatus>((ref) {
  return OnboardingNotifier();
});

/// ─────────────────────────────────────────────────────────────
/// TIMELINE FILTERS
/// ─────────────────────────────────────────────────────────────
final timelineKeywordFilterProvider = StateProvider<String?>((ref) => null);
final timelineSentimentFilterProvider = StateProvider<String?>((ref) => null);

/// ─────────────────────────────────────────────────────────────
/// ANSWERS & QUESTIONS
/// ─────────────────────────────────────────────────────────────
final answersProvider = FutureProvider<List<Answer>>((ref) async {
  final repo = await ref.watch(questionRepositoryProvider.future);
  return repo.fetchAnswers();
});

final answerCountProvider = FutureProvider<int>((ref) async {
  final repo = await ref.watch(questionRepositoryProvider.future);
  return repo.getAnswerCount();
});

final todayContentProvider = FutureProvider<dynamic>((ref) async {
  final repo = await ref.watch(questionRepositoryProvider.future);
  return repo.getTodayContent();
});

final groupedAnswersProvider =
    FutureProvider<Map<DateTime, List<Answer>>>((ref) async {
  final repo = await ref.watch(questionRepositoryProvider.future);
  return repo.fetchAnswersGroupedByDay();
});

final filteredAnswersProvider = FutureProvider<List<Answer>>((ref) async {
  final repo = await ref.watch(questionRepositoryProvider.future);
  final keyword = ref.watch(timelineKeywordFilterProvider);
  final sentiment = ref.watch(timelineSentimentFilterProvider);
  return repo.fetchAnswersFiltered(keyword: keyword, sentimentLabel: sentiment);
});
