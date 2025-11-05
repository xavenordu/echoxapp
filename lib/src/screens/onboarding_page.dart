import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echoxapp/src/models/onboarding_status.dart';
import 'package:echoxapp/src/widgets/privacy_toggle.dart';
import 'package:echoxapp/providers.dart';

// Onboarding logic is provided by `onboardingStatusProvider` in `providers.dart`.

class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(onboardingStatusProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
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
              const SizedBox(height: 32),
              
              // Privacy section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.shield, color: theme.colorScheme.primary),
                          const SizedBox(width: 12),
                          Text(
                            'Privacy & Data',
                            style: theme.textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Your reflections are private. You can delete or export them anytime. '
                        'We never share your data with third parties.',
                      ),
                      const SizedBox(height: 24),
                      
                      // Privacy toggles
                      PrivacyToggle(
                        icon: Icons.cloud_upload,
                        title: 'Cloud Backup',
                        description: 'Securely sync your reflections across devices.',
                        value: status.useCloudBackup,
                        onChanged: (value) {
                          ref.read(onboardingStatusProvider.notifier)
                            .setCloudBackup(value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Consent text
              Text(
                'By continuing, you agree to our Privacy Policy and Terms of Service.',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Get Started button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(onboardingStatusProvider.notifier)
                      .completeOnboarding()
                      .then((_) {
                        // Navigate to home page
                        Navigator.of(context).pushReplacementNamed('/home');
                      });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Get Started'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}