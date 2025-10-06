import 'package:shamra_app/core/constants/app_constants.dart';

class HelperMethod {
  static getImageUrl(String image) {
    return "${ApiConstants.storageUrl}$image";
  }
}
