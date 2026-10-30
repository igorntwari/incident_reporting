import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Base for controllers that run one-off async actions (sign in, submit,
/// delete...). State is `AsyncValue<void>`: the UI watches it for a loading
/// spinner and listens to it for error snackbars. This keeps the
/// loading/error pattern written once instead of in every controller.
abstract class ActionController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Runs [action], exposing loading/error state. Returns `true` on success.
  Future<bool> run(Future<void> Function() action) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(action);
    if (ref.mounted) state = result;
    return !result.hasError;
  }
}
