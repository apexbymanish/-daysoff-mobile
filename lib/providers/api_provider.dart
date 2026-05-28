import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';

/// Singleton ApiClient for the app.
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
