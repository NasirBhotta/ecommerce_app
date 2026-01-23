import 'package:get/get.dart';

class CartItem {
  final String id;
  final String name;
  final String price;
  final String? image;
  final String brand;
  final String size;
  final String color;
  final RxInt quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.image,
    this.brand = 'Unknown',
    this.size = 'M',
    this.color = 'Default',
    required int quantity,
  }) : quantity = quantity.obs;
}
