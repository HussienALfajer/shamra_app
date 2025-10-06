import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/common_widgets.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final authController = Get.find<AuthController>();
    final user = authController.currentUser;

    // Initialize controllers with current user data
    final firstNameController = TextEditingController(text: user?.firstName ?? '');
    final lastNameController = TextEditingController(text: user?.lastName ?? '');
    final phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
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
            onPressed: () => Get.back(),
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
                    : () => _saveProfile(
                  formKey,
                  authController,
                  firstNameController,
                  lastNameController,
                  phoneController,
                ),
                child: Text(
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
          ],
        ),
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

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    // Profile Avatar Section
                    _buildProfileAvatar(user),
                    const SizedBox(height: 32),

                    // Personal Information Card
                    ShamraCard(
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

                          // First Name Field
                          ShamraTextField(
                            label: 'الاسم الأول',
                            hintText: 'أدخل اسمك الأول',
                            icon: Icons.person_outline,
                            controller: firstNameController,
                            textCapitalization: TextCapitalization.words,
                            isRequired: true,
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

                          // Last Name Field
                          ShamraTextField(
                            label: 'الاسم الأخير',
                            hintText: 'أدخل اسمك الأخير',
                            icon: Icons.person_outline,
                            controller: lastNameController,
                            textCapitalization: TextCapitalization.words,
                            isRequired: true,
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
                          const SizedBox(height: 16),

                          // Phone Number Field
                          ShamraTextField(
                            label: 'رقم الهاتف',
                            hintText: 'أدخل رقم هاتفك (اختياري)',
                            icon: Icons.phone_outlined,
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value != null && value.trim().isNotEmpty) {
                                if (value.trim().length < 8) {
                                  return 'رقم الهاتف يجب أن يحتوي على 8 أرقام على الأقل';
                                }
                                if (!RegExp(r'^[0-9+\-\s()]+$').hasMatch(value)) {
                                  return 'رقم الهاتف يحتوي على رموز غير صحيحة';
                                }
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Account Information Card
                    ShamraCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.email_outlined,
                                color: AppColors.secondary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'معلومات الحساب',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Email Field (Read Only)
                          ShamraTextField(
                            label: 'البريد الإلكتروني',
                            hintText: user.email,
                            icon: Icons.email_outlined,
                            controller: emailController,
                            keyboardType: TextInputType.none,
                            hintColor: AppColors.textPrimary,
                            hintStyle: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            customIconColor: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'لا يمكن تعديل البريد الإلكتروني',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Save Button
                    ShamraButton(
                      text: 'حفظ التغييرات',
                      onPressed: authController.isLoading
                          ? null
                          : () => _saveProfile(
                        formKey,
                        authController,
                        firstNameController,
                        lastNameController,
                        phoneController,
                      ),
                      isLoading: authController.isLoading,
                      icon: Icons.save_outlined,
                      width: double.infinity,
                    ),

                    const SizedBox(height: 16),

                    // Cancel Button
                    ShamraButton(
                      text: 'إلغاء',
                      onPressed: authController.isLoading ? null : () => Get.back(),
                      isOutlined: true,
                      icon: Icons.close_rounded,
                      width: double.infinity,
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
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
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.edit_outlined,
                color: AppColors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveProfile(
      GlobalKey<FormState> formKey,
      AuthController authController,
      TextEditingController firstNameController,
      TextEditingController lastNameController,
      TextEditingController phoneController,
      ) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final user = authController.currentUser;

    if (user == null) {
      ShamraSnackBar.show(
        context: Get.context!,
        message: 'لا توجد بيانات مستخدم',
        type: SnackBarType.error,
      );
      return;
    }

    // Check if any changes were made
    final hasChanges = firstNameController.text.trim() != user.firstName ||
        lastNameController.text.trim() != user.lastName ||
        phoneController.text.trim() != (user.phoneNumber ?? '');

    if (!hasChanges) {
      ShamraSnackBar.show(
        context: Get.context!,
        message: 'لا توجد تغييرات للحفظ',
        type: SnackBarType.info,
      );
      return;
    }

    final success = await authController.updateProfile(
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      phoneNumber: phoneController.text.trim().isEmpty
          ? null
          : phoneController.text.trim(),
    );

    if (success) {
      Get.back(); // Return to previous page
    }
  }
}