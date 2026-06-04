import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// App-wide theme mode (in-memory this phase; persistence is a later task).
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);
