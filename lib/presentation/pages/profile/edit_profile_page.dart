import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/common_widgets.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _phoneFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final authController = Get.find<AuthController>();
    final user = authController.currentUser;

    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: GetBuilder<AuthController>(
          builder: (authController) {
            final user = authController.currentUser;

            if (user == null) {
              return const Center(
                child: Text(
                  'لا توجد بيانات مستخدم',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            }

            return _buildBody(authController, user);
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 1,
      title: const Text(
        'تعديل الملف الشخصي',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      leading: IconButton(
        onPressed: () => _handleBack(),
        icon: const Icon(
          Icons.arrow_back_ios_rounded,
          color: AppColors.textPrimary,
        ),
      ),
      actions: [
        GetBuilder<AuthController>(
          builder: (authController) => TextButton(
            onPressed: authController.isLoading
                ? null
                : () => _saveProfile(authController),
            child: authController.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  )
                : Text(
                    'حفظ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: authController.isLoading
                          ? AppColors.textSecondary
                          : AppColors.primary,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody(AuthController authController, dynamic user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Profile Avatar
            _buildProfileAvatar(user),
            const SizedBox(height: 32),

            // Personal Information
            _buildPersonalInfoCard(),
            const SizedBox(height: 24),

            // Action Buttons
            _buildActionButtons(authController),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(dynamic user) {
    String getFirstLetter() {
      if (user?.firstName != null && user.firstName.toString().isNotEmpty) {
        return user.firstName.toString().substring(0, 1).toUpperCase();
      }
      return 'H';
    }

    return Center(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(60),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Text(
                getFirstLetter(),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    return ShamraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'المعلومات الشخصية',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // First Name
          ShamraTextField(
            label: 'الاسم الأول',
            hintText: 'أدخل اسمك الأول',
            icon: Icons.person_outline,
            controller: _firstNameController,
            textCapitalization: TextCapitalization.words,
            isRequired: true,
            onSubmitted: (_) => _firstNameFocus.nextFocus(),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'الاسم الأول مطلوب';
              }
              if (value.trim().length < 2) {
                return 'الاسم يجب أن يحتوي على حرفين على الأقل';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Last Name
          ShamraTextField(
            label: 'الاسم الأخير',
            hintText: 'أدخل اسمك الأخير',
            icon: Icons.person_outline,
            controller: _lastNameController,
            textCapitalization: TextCapitalization.words,
            isRequired: true,
            onSubmitted: (_) => _lastNameFocus.nextFocus(),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'الاسم الأخير مطلوب';
              }
              if (value.trim().length < 2) {
                return 'الاسم يجب أن يحتوي على حرفين على الأقل';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AuthController authController) {
    return Column(
      children: [
        // Save Button
        ShamraButton(
          text: 'حفظ التغييرات',
          onPressed: authController.isLoading
              ? null
              : () => _saveProfile(authController),
          isLoading: authController.isLoading,
          icon: Icons.save_outlined,
          width: double.infinity,
        ),
        const SizedBox(height: 16),

        // Cancel Button
        ShamraButton(
          text: 'إلغاء',
          onPressed: authController.isLoading ? null : () => _handleBack(),
          isOutlined: true,
          icon: Icons.close_rounded,
          width: double.infinity,
        ),
      ],
    );
  }

  void _handleBack() {
    // Check if there are unsaved changes
    final authController = Get.find<AuthController>();
    final user = authController.currentUser;

    if (user == null) {
      Get.back();
      return;
    }

    final hasChanges =
        _firstNameController.text.trim() != user.firstName ||
        _lastNameController.text.trim() != user.lastName ||
        _phoneController.text.trim() != (user.phoneNumber ?? '');

    if (hasChanges) {
      _showUnsavedChangesDialog();
    } else {
      Get.back();
    }
  }

  void _showUnsavedChangesDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'تغييرات غير محفوظة',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'لديك تغييرات غير محفوظة. هل تريد المغادرة بدون حفظ؟',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'البقاء',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(); // Go back to profile page
            },
            child: const Text(
              'مغادرة',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile(AuthController authController) async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Unfocus all fields
    FocusScope.of(context).unfocus();

    final user = authController.currentUser;

    if (user == null) {
      ShamraSnackBar.show(
        context: context,
        message: 'لا توجد بيانات مستخدم',
        type: SnackBarType.error,
      );
      return;
    }

    // Check if any changes were made
    final hasChanges =
        _firstNameController.text.trim() != user.firstName ||
        _lastNameController.text.trim() != user.lastName ||
        _phoneController.text.trim() != (user.phoneNumber ?? '');

    if (!hasChanges) {
      ShamraSnackBar.show(
        context: context,
        message: 'لا توجد تغييرات للحفظ',
        type: SnackBarType.info,
      );
      return;
    }

    // Update profile
    final success = await authController.updateProfile(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phoneNumber: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
    );

    if (success) {
      // Update controllers with new data
      setState(() {
        _firstNameController.text = authController.currentUser?.firstName ?? '';
        _lastNameController.text = authController.currentUser?.lastName ?? '';
        _phoneController.text = authController.currentUser?.phoneNumber ?? '';
      });

      // Delay navigation to allow UI to update
      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        Get.back(); // Return to profile page
      }
    }
  }
}