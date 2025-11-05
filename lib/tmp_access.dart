import 'package:echoxapp/providers.dart' as prov;

void test() {
  // reference provider to test visibility via prefix
  final p = prov.onboardingStatusProvider;
  print(p);
}
