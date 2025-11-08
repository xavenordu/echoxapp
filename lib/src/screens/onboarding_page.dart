import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echoxapp/providers.dart';
import 'package:echoxapp/src/widgets/privacy_toggle.dart';
import 'package:echoxapp/src/navigation/main_navigator.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  int _step = 0;

  void _nextStep() {
    setState(() {
      if (_step < 2) _step++;
    });
  }

  void _previousStep() {
    setState(() {
      if (_step > 0) _step--;
    });
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(onboardingStatusProvider);
    final theme = Theme.of(context);

    final steps = [
      _buildWelcomeStep(theme),
      _buildPreferencesStep(theme, status),
      _buildPrivacyStep(theme, status),
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            children: [
              // Progress bar
              LinearProgressIndicator(
                value: (_step + 1) / steps.length,
                backgroundColor: theme.colorScheme.surfaceVariant,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),

              // Animated step transition
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                  child: steps[_step],
                ),
              ),

              const SizedBox(height: 24),

              // Navigation buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_step > 0)
                    OutlinedButton(
                      onPressed: _previousStep,
                      child: const Text('Back'),
                    ),
                  ElevatedButton(
                      onPressed: () async {
                        if (_step < steps.length - 1) {
                          _nextStep();
                        } else {
                          await ref
                              .read(onboardingStatusProvider.notifier)
                              .completeOnboarding();
                          if (context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const MainNavigator()),
                            );
                          }
                        }
                      },
                      child: Text(_step == steps.length - 1 ? 'Finish' : 'Next'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Step 1 — Welcome
  Widget _buildWelcomeStep(ThemeData theme) {
    return Column(
      key: const ValueKey(0),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome to EchoX',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'A private space for daily reflection and self-discovery.',
          style: theme.textTheme.titleMedium,
        ),
        const Spacer(),
        Center(
          child: Icon(Icons.self_improvement, size: 120, color: theme.colorScheme.primary),
        ),
        const Spacer(),
      ],
    );
  }

  // Step 2 — Preferences
  Widget _buildPreferencesStep(ThemeData theme, dynamic status) {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Personalize Your Experience', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 16),

        PrivacyToggle(
          icon: Icons.brightness_6,
          title: 'Dark Mode',
          description: 'Use dark mode for a calmer journaling experience.',
          value: status.darkMode,
          onChanged: (val) => ref.read(onboardingStatusProvider.notifier).setDarkMode(val),
        ),
        const SizedBox(height: 12),

        PrivacyToggle(
          icon: Icons.notifications_active,
          title: 'Daily Reflection Reminder',
          description: 'Receive a gentle reminder to write each day.',
          value: status.notificationsEnabled,
          onChanged: (val) => ref.read(onboardingStatusProvider.notifier).setNotifications(val),
        ),
        const Spacer(),
      ],
    );
  }

  // Step 3 — Privacy
  Widget _buildPrivacyStep(ThemeData theme, dynamic status) {
    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.shield, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Text('Privacy & Data', style: theme.textTheme.headlineSmall),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.info_outline),
              tooltip: 'Learn about how your data is handled securely.',
              onPressed: () => _showPrivacyInfo(context),
            )
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Your reflections are private. You can delete or export them anytime. '
          'We never share your data with third parties.',
        ),
        const SizedBox(height: 24),

        PrivacyToggle(
          icon: Icons.cloud_upload,
          title: 'Cloud Backup',
          description: 'Securely sync your reflections across devices.',
          value: status.useCloudBackup,
          onChanged: (value) => ref.read(onboardingStatusProvider.notifier).setCloudBackup(value),
        ),
        const Spacer(),
        Text(
          'By continuing, you agree to our Privacy Policy and Terms of Service.',
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showPrivacyInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Your Privacy at EchoX'),
        content: const Text(
          'EchoX encrypts all your data locally. Cloud sync is optional and fully secure. '
          'You can export or delete your data at any time from Settings.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Got it')),
        ],
      ),
    );
  }
}
