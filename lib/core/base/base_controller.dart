import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../presentation/widgets/common_widgets.dart';

/// Base controller with unified loading/error/info handling.
///
/// This abstract controller exposes reactive state variables for loading and
/// error information. It provides a [safeCall] helper to execute
/// asynchronous operations while automatically toggling the [isLoading]
/// flag and capturing any error into [errorMessage]. Callers should
/// listen to these observables from the UI layer to update widgets.
abstract class BaseController extends GetxController {
  /// Whether the controller is currently performing a long‑running operation.
  final RxBool isLoading = false.obs;

  /// Holds the last error message. `null` represents no error.
  final RxnString errorMessage = RxnString(null);

  /// Executes an asynchronous [body] while automatically managing the
  /// [isLoading] and [errorMessage] state. Any thrown exception will be
  /// rethrown after updating [errorMessage].
  Future<T> safeCall<T>(Future<T> Function() body, {VoidCallback? onFinally}) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      final result = await body();
      return result;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('\u274c safeCall error: $e');
        debugPrint(st.toString());
      }
      errorMessage.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
      onFinally?.call();
    }
  }

  /// Emits an error message. Optionally show a snack bar via [context].
  void emitError(String message, {BuildContext? context}) {
    errorMessage.value = message;
    if (context != null) {
      ShamraSnackBar.show(
        context: context,
        message: message,
        type: SnackBarType.error,
      );
    }
  }

  /// Emits an informational message. Optionally show a snack bar via [context].
  void emitInfo(String message, {BuildContext? context}) {
    if (context != null) {
      ShamraSnackBar.show(
        context: context,
        message: message,
        type: SnackBarType.info,
      );
    }
  }

  /// Emits a success message. Optionally show a snack bar via [context].
  void emitSuccess(String message, {BuildContext? context}) {
    if (context != null) {
      ShamraSnackBar.show(
        context: context,
        message: message,
        type: SnackBarType.success,
      );
    }
  }
}
