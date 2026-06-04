import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/saved_breaks_provider.dart';
import '../../theme/colors.dart';

class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(savedBreaksProvider);
    final fmt = DateFormat('MMM d');
    return Scaffold(
      appBar: AppBar(title: const Text('Saved')),
      body: SafeArea(
        child: saved.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Nothing saved yet — plan a break to get started.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: DaysoffColors.neutral700)),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: saved.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final b = saved[i];
                  return ListTile(
                    leading: Icon(
                      b.kind == 'sandwich' ? Icons.bakery_dining : Icons.event_available,
                      color: DaysoffColors.sage,
                    ),
                    title: Text(b.label),
                    subtitle: Text(
                        '${fmt.format(b.start)} – ${fmt.format(b.end)} · ${b.ptoCost} PTO'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () =>
                          ref.read(savedBreaksProvider.notifier).remove(b.id),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
