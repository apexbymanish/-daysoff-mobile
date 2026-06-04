import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/models/country.dart';
import '../../providers/countries_provider.dart';
import '../../providers/selection_provider.dart';
import '../../theme/colors.dart';

class CountryPickerScreen extends ConsumerStatefulWidget {
  const CountryPickerScreen({super.key});
  @override
  ConsumerState<CountryPickerScreen> createState() => _CountryPickerScreenState();
}

class _CountryPickerScreenState extends ConsumerState<CountryPickerScreen> {
  static const _pinned = {'KR', 'NP', 'JP', 'IN', 'PH'};
  String _query = '';

  List<Country> _filter(List<Country> all) {
    final q = _query.trim().toLowerCase();
    final matches = q.isEmpty
        ? all
        : all.where((c) =>
            c.name.toLowerCase().contains(q) || c.code.toLowerCase().contains(q));
    final list = matches.toList()
      ..sort((a, b) {
        final ap = _pinned.contains(a.code) ? 0 : 1;
        final bp = _pinned.contains(b.code) ? 0 : 1;
        if (ap != bp) return ap - bp;
        return a.name.compareTo(b.name);
      });
    return list;
  }

  void _select(Country c) {
    ref.read(selectedCountryProvider.notifier).state = c.code;
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(countriesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Where do you work?')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search 250+ countries',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Expanded(
              child: async.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: TextButton(
                    onPressed: () => ref.invalidate(countriesProvider),
                    child: const Text('Retry'),
                  ),
                ),
                data: (all) {
                  final list = _filter(all);
                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final c = list[i];
                      return ListTile(
                        title: Text(c.name),
                        trailing: Text(c.code,
                            style: const TextStyle(color: DaysoffColors.neutral500)),
                        onTap: () => _select(c),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
