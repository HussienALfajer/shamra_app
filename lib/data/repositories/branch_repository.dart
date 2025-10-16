// lib/data/repositories/branch_repository.dart
import '../models/branch.dart';
import '../services/branch_service.dart';

class BranchRepository {
  /// Get active branches only.
  Future<List<Branch>> getActiveBranches() async {
    try {
      return await BranchService.getActiveBranches();
    } catch (e) {
      rethrow;
    }
  }

  /// Get branch by ID.
  Future<Branch> getBranchById(String branchId) async {
    try {
      return await BranchService.getBranchById(branchId);
    } catch (e) {
      rethrow;
    }
  }
}