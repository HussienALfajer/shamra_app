import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/models/branch.dart';
import '../../data/repositories/branch_repository.dart';
import '../widgets/common_widgets.dart';
import 'auth_controller.dart';

class BranchController extends GetxController {
  final BranchRepository _branchRepository = BranchRepository();

  // Observables
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

  /// Load all active branches
  Future<void> loadBranches() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final branches = await _branchRepository.getActiveBranches();
      _branches.value = branches;

      // Sort branches: main branch first, then by sortOrder
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

  /// Select a branch using AuthController
  Future<void> selectBranch(Branch branch) async {
    try {
      _isSelecting.value = true;
      _errorMessage.value = '';
      _selectedBranch.value = branch;

      final authController = Get.find<AuthController>();
      final success = await authController.selectBranch(branch.id);

      if (!success) {
        _selectedBranch.value = null;
        _errorMessage.value = authController.errorMessage;
      }
    } catch (e) {
      _errorMessage.value = e.toString();
      _selectedBranch.value = null;

      ShamraSnackBar.show(
        context: Get.context!,
        message: 'فشل في اختيار الفرع: ${e.toString()}',
        type: SnackBarType.error,
      );
    } finally {
      _isSelecting.value = false;
    }
  }

  /// Refresh branches list
  Future<void> refreshBranches() async {
    await loadBranches();
  }

  /// Clear error message
  void clearError() {
    _errorMessage.value = '';
  }

  /// Reset selection state (يمكن استدعاؤها عند الحاجة من الصفحة بدل onClose)
  void resetSelection() {
    _selectedBranch.value = null;
    _isSelecting.value = false;
  }

  /// Logout using AuthController
  void logout() {
    _showLogoutDialog();
  }

  /// Show logout confirmation dialog
  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'تسجيل الخروج',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        content: const Text(
          'هل تريد تسجيل الخروج والعودة لصفحة تسجيل الدخول؟',
          style: TextStyle(color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog first
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

  /// Perform logout using AuthController
  void _performLogout() async {
    try {
      // لا تعدّل Rx أثناء التخلص من الصفحة
      _selectedBranch.value = null;
      _errorMessage.value = '';

      final authController = Get.find<AuthController>();
      await authController.logout();
    } catch (e) {
      ShamraSnackBar.show(
        context: Get.context!,
        message: 'خطأ أثناء تسجيل الخروج: ${e.toString()}',
        type: SnackBarType.error,
      );
    }
  }

  /// Get branch by ID
  Branch? getBranchById(String branchId) {
    try {
      return _branches.firstWhere((branch) => branch.id == branchId);
    } catch (e) {
      return null;
    }
  }

  /// Check if branch is selected
  bool isBranchSelected(Branch branch) {
    return _selectedBranch.value?.id == branch.id;
  }

  /// Get main branch
  Branch? get mainBranch {
    try {
      return _branches.firstWhere((branch) => branch.isMainBranch);
    } catch (e) {
      return null;
    }
  }

  /// Get branches count
  int get branchesCount => _branches.length;

  /// Check if has branches
  bool get hasBranches => _branches.isNotEmpty;

  /// Check if has error
  bool get hasError => _errorMessage.value.isNotEmpty;

  @override
  void onClose() {

    super.onClose();
  }
}
