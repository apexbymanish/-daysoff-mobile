import 'package:flutter/material.dart';

/// Stub. See docs/stitch/screens/01-onboarding.md for the spec.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _StubScaffold(title: 'Onboarding (stub)');
  }
}

class _StubScaffold extends StatelessWidget {
  const _StubScaffold({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('TODO: implement $title')),
    );
  }
}
