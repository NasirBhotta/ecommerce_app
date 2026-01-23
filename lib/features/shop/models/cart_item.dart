import 'package:get/get.dart';

class CartItem {
  final String id;
  final String name;
  final RxInt quantity;

  CartItem({required this.id, required this.name, required int quantity})
    : quantity = quantity.obs;
}
