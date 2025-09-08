import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/models/branch.dart';
import '../../data/repositories/branch_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../routes/app_routes.dart';

class BranchController extends GetxController {
  final BranchRepository _branchRepository = BranchRepository();
  final AuthRepository _authRepository = AuthRepository();

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

  // Load all active branches
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
      Get.snackbar(
        'خطأ',
        'فشل في تحميل الفروع: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Select a branch
  Future<void> selectBranch(Branch branch) async {
    try {
      _isSelecting.value = true;
      _errorMessage.value = '';
      _selectedBranch.value = branch;

      // Call the selectBranch API
      final response = await _authRepository.selectBranch(branchId: branch.id);

      if (response.success) {
        Get.snackbar(
          'نجح',
          'تم اختيار فرع ${branch.displayName} بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );

        // Navigate to main page after successful branch selection
        Get.offAllNamed(Routes.main);
      } else {
        throw Exception(
          response.message.isEmpty ? 'فشل في اختيار الفرع' : response.message,
        );
      }
    } catch (e) {
      _errorMessage.value = e.toString();
      _selectedBranch.value = null;

      Get.snackbar(
        'خطأ',
        'فشل في اختيار الفرع: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isSelecting.value = false;
    }
  }

  // Refresh branches
  Future<void> refreshBranches() async {
    await loadBranches();
  }

  // Clear error message
  void clearError() {
    _errorMessage.value = '';
  }

  // Logout and go back to login
  void logout() {
    Get.dialog(
      AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل تريد تسجيل الخروج والعودة لصفحة تسجيل الدخول؟'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // Close dialog
              await _authRepository.logout();
              Get.offAllNamed(Routes.login);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}
