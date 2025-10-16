// lib/core/base/base_controller.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../presentation/widgets/common_widgets.dart';

/// Base controller with unified loading/error/info handling.
/// - Wrap async work with safeCall() to manage loading/errors.
/// - Exposes isLoading and errorMessage for the UI.
/// - Optional snack helpers (require BuildContext).
abstract class BaseController extends GetxController {
  final RxBool isLoading = false.obs;

  // Keep RxnString and expose it via a getter to avoid override mismatches.
  final RxnString _errorMessage = RxnString(null);
  RxnString get errorMessage => _errorMessage;

  /// Wrap any async call with loading + error capture.
  Future<T> safeCall<T>(
      Future<T> Function() body, {
        VoidCallback? onFinally,
      }) async {
    try {
      isLoading.value = true;
      _errorMessage.value = null;
      final result = await body();
      return result;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('❌ safeCall error: $e');
        debugPrint(st.toString());
      }
      _errorMessage.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
      onFinally?.call();
    }
  }

  void emitError(String message, {BuildContext? context}) {
    _errorMessage.value = message;
    if (context != null) {
      ShamraSnackBar.show(
        context: context,
        message: message,
        type: SnackBarType.error,
      );
    }
  }

  void emitInfo(String message, {BuildContext? context}) {
    if (context != null) {
      ShamraSnackBar.show(
        context: context,
        message: message,
        type: SnackBarType.info,
      );
    }
  }

  void emitSuccess(String message, {BuildContext? context}) {
    if (context != null) {
      ShamraSnackBar.show(
        context: context,
        message: message,
        type: SnackBarType.success,
      );
    }
  }

  void emitWarning(String message, {BuildContext? context}) {
    if (context != null) {
      ShamraSnackBar.show(
        context: context,
        message: message,
        type: SnackBarType.warning,
      );
    }
  }
}