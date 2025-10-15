import '../models/branch.dart';
import '../../core/services/dio_service.dart';
import '../../core/constants/app_constants.dart';

class BranchService {
  // Get active branches only (for customer selection)
  static Future<List<Branch>> getActiveBranches() async {
    try {
      final response = await DioService.get('${ApiConstants.branches}/active');

      if (response.statusCode == 200) {
        final List<dynamic> branchesData = response.data['data'] ?? [];
        return branchesData.map((branch) => Branch.fromJson(branch)).toList();
      } else {
        throw Exception('Failed to load active branches');
      }
    } catch (e) {
      throw Exception('Error loading active branches: ${e.toString()}');
    }
  }

  // Get branch by ID
  static Future<Branch> getBranchById(String branchId) async {
    try {
      final response = await DioService.get(
        '${ApiConstants.branches}/$branchId',
      );

      if (response.statusCode == 200) {
        return Branch.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to load branch');
      }
    } catch (e) {
      throw Exception('Error loading branch: ${e.toString()}');
    }
  }
}