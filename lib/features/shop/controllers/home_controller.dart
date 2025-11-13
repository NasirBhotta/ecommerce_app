import 'package:get/get.dart';

class HomeController extends GetxController {
  static HomeController get instance => Get.find();

  // Observable for carousel index
  final carousalCurrentIndex = 0.obs;

  // Update carousel index
  void updatePageIndicator(int index) {
    carousalCurrentIndex.value = index;
  }

  // Sample categories data
  final categories = [
    {'icon': 'sports_baseball', 'title': 'Sports'},
    {'icon': 'chair', 'title': 'Furniture'},
    {'icon': 'devices', 'title': 'Electronics'},
    {'icon': 'checkroom', 'title': 'Clothes'},
    {'icon': 'pets', 'title': 'Animals'},
    {'icon': 'shopping_bag', 'title': 'Shoes'},
  ];

  // Sample banner data
  final banners = [
    'assets/images/banners/banner1.jpg',
    'assets/images/banners/banner2.jpg',
    'assets/images/banners/banner3.jpg',
  ];

  // Sample products data
  final products = [
    {
      'name': 'Nike Air Sneakers',
      'price': '\$299.99',
      'discount': '70%',
      'image': 'assets/images/products/sneakers.jpg',
    },
    {
      'name': 'Blue T-Shirt',
      'price': '\$49.99',
      'discount': '40%',
      'image': 'assets/images/products/tshirt.jpg',
    },
  ];
}
