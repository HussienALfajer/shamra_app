import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/models/branch.dart';
import '../../data/repositories/branch_repository.dart';
import '../widgets/common_widgets.dart';
import 'auth_controller.dart';
import '../../core/services/storage_service.dart';

/// BranchController
/// - Loads active branches
/// - Handles selecting a branch (API) after auth
/// - Provides a light-weight cache selection for pre-auth flows (e.g., Register)
class BranchController extends GetxController {
  final BranchRepository _branchRepository = BranchRepository();

  // State
  final RxList<Branch> _branches = <Branch>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isSelecting = false.obs;
  final RxString _errorMessage = ''.obs;
  final Rx<Branch?> _selectedBranch = Rx<Branch?>(null);

  // Getters
  List<Branch> get branches => _branches;
  bool get isLoading => _isLoading.value;
  bool get isSelecting => _isSelecting.value;
  String get errorMessage => _errorMessage.value;
  Branch? get selectedBranch => _selectedBranch.value;

  @override
  void onInit() {
    super.onInit();
    loadBranches();
  }

  /// Load all active branches from repository.
  Future<void> loadBranches() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final list = await _branchRepository.getActiveBranches();
      _branches
        ..clear()
        ..addAll(list);

      // Sort: main branch first, then by sortOrder.
      _branches.sort((a, b) {
        if (a.isMainBranch && !b.isMainBranch) return -1;
        if (!a.isMainBranch && b.isMainBranch) return 1;
        return a.sortOrder.compareTo(b.sortOrder);
      });
    } catch (e) {
      _errorMessage.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  /// Select a branch via API (requires user to be authenticated).
  /// Mirrors the behavior used on the dedicated Branch Selection page.
  Future<void> selectBranch(Branch branch) async {
    try {
      _isSelecting.value = true;
      _errorMessage.value = '';
      _selectedBranch.value = branch;

      final authController = Get.find<AuthController>();
      final ok = await authController.selectBranch(branch.id);

      if (!ok) {
        _selectedBranch.value = null;
        _errorMessage.value = authController.errorMessage;
      }
    } catch (e) {
      _errorMessage.value = e.toString();
      _selectedBranch.value = null;

      if (Get.context != null) {
        ShamraSnackBar.show(
          context: Get.context!,
          message: 'Branch selection failed: ${e.toString()}',
          type: SnackBarType.error,
        );
      }
    } finally {
      _isSelecting.value = false;
    }
  }

  /// Cache-only selection (no API) for pre-auth flows (e.g., Register).
  /// - Persists selected branch id into storage so Dio adds `x-branch-id` header.
  /// - Keeps current selection state for UI.
  Future<void> cacheSelectedBranch(Branch branch) async {
    _selectedBranch.value = branch;
    await StorageService.saveBranchId(branch.id);
  }

  Future<void> refreshBranches() async => loadBranches();

  void clearError() => _errorMessage.value = '';

  void resetSelection() {
    _selectedBranch.value = null;
    _isSelecting.value = false;
  }

  void logout() {
    _showLogoutDialog();
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'تسجيل الخروج',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87),
        ),
        content: const Text(
          'هل تريد تسجيل الخروج والعودة لصفحة تسجيل الدخول؟',
          style: TextStyle(color: Colors.black54),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _performLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    try {
      _selectedBranch.value = null;
      _errorMessage.value = '';
      final authController = Get.find<AuthController>();
      await authController.logout();
    } catch (e) {
      if (Get.context != null) {
        ShamraSnackBar.show(
          context: Get.context!,
          message: 'Logout error: ${e.toString()}',
          type: SnackBarType.error,
        );
      }
    }
  }

  Branch? getBranchById(String branchId) {
    try {
      return _branches.firstWhere((b) => b.id == branchId);
    } catch (_) {
      return null;
    }
  }

  bool isBranchSelected(Branch branch) => _selectedBranch.value?.id == branch.id;

  Branch? get mainBranch {
    try {
      return _branches.firstWhere((b) => b.isMainBranch);
    } catch (_) {
      return null;
    }
  }

  int get branchesCount => _branches.length;
  bool get hasBranches => _branches.isNotEmpty;
  bool get hasError => _errorMessage.value.isNotEmpty;
}
