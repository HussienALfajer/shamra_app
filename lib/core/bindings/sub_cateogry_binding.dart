import 'package:get/get.dart';
import 'package:shamra_app/presentation/controllers/sub_category_controller.dart';

class SubCategoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SubCategoryController>(() => SubCategoryController());
  }
}
