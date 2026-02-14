import 'package:get/get.dart';

class AdminNavigationController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  final List<String> items = const [
    'Dashboard',
    'Orders',
    'Products',
    'Users',
    'Notifications',
  ];

  void select(int index) {
    selectedIndex.value = index;
  }
}
