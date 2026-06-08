import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../auth/auth_controller.dart';

/// Singleton ApiClient for the app, wired to the secure token store so the
/// Dio interceptor can attach the access token and refresh it on a 401.
final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(tokenStore: ref.watch(tokenStoreProvider)),
);
