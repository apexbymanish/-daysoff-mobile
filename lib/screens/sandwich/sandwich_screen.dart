import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/models/sandwiches_response.dart';
import '../../providers/preferences_provider.dart';
import '../../providers/sandwiches_provider.dart';
import '../../providers/selection_provider.dart';
import '../../theme/colors.dart';
import 'widgets/sandwich_card.dart';

class SandwichScreen extends ConsumerWidget {
  const SandwichScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final country = ref.watch(selectedCountryProvider);
    final year = ref.watch(selectedYearProvider);
    final weekend = ref.watch(weekendProvider);
    final query = SandwichesQuery(country: country, year: year, workweek: weekend);
    final async = ref.watch(sandwichesProvider(query));
    return Scaffold(
      appBar: AppBar(title: const Text('Sandwich days')),
      body: SafeArea(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _SandwichError(
              onRetry: () => ref.invalidate(sandwichesProvider(query))),
          data: (resp) => _SandwichList(response: resp),
        ),
      ),
    );
  }
}

class _SandwichList extends StatelessWidget {
  const _SandwichList({required this.response});
  final SandwichesResponse response;

  @override
  Widget build(BuildContext context) {
    if (response.sandwiches.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No sandwich days this year.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: DaysoffColors.neutral700)),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Single workdays between days off — take one, gain a long weekend.',
            style: TextStyle(fontSize: 13, color: DaysoffColors.neutral700),
          ),
        ),
        for (final s in response.sandwiches) SandwichCard(record: s),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _SandwichError extends StatelessWidget {
  const _SandwichError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Couldn't load sandwich days.",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
