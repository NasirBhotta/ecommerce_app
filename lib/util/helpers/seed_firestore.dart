// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ecommerce_app/firebase_options.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/widgets.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

//   final db = FirebaseFirestore.instance;

// }

import 'package:cloud_firestore/cloud_firestore.dart';

class SeedFirestore {
  static Future<void> seedFirestore() async {
    final db = FirebaseFirestore.instance;

    final brands = <Map<String, dynamic>>[
      {
        "id": "nike",
        "name": "Nike",
        "logoUrl":
            "https://upload.wikimedia.org/wikipedia/commons/a/a6/Logo_NIKE.svg",
        "productCount": 3,
        "verified": true,
        "category": "Sports",
      },
      {
        "id": "adidas",
        "name": "Adidas",
        "logoUrl":
            "https://upload.wikimedia.org/wikipedia/commons/2/20/Adidas_Logo.svg",
        "productCount": 3,
        "verified": true,
        "category": "Sports",
      },
      {
        "id": "puma",
        "name": "Puma",
        "logoUrl":
            "https://upload.wikimedia.org/wikipedia/commons/f/fd/PUMA_Logo.svg",
        "productCount": 2,
        "verified": true,
        "category": "Sports",
      },
      {
        "id": "ikea",
        "name": "IKEA",
        "logoUrl":
            "https://upload.wikimedia.org/wikipedia/commons/c/cf/IKEA_logo.svg",
        "productCount": 3,
        "verified": true,
        "category": "Furniture",
      },
      {
        "id": "ashley",
        "name": "Ashley",
        "logoUrl":
            "https://upload.wikimedia.org/wikipedia/commons/1/15/Ashley_Furniture_logo.svg",
        "productCount": 2,
        "verified": true,
        "category": "Furniture",
      },
      {
        "id": "kenwood",
        "name": "Kenwood",
        "logoUrl":
            "https://upload.wikimedia.org/wikipedia/commons/7/74/Kenwood_logo.svg",
        "productCount": 3,
        "verified": true,
        "category": "Electronics",
      },
      {
        "id": "samsung",
        "name": "Samsung",
        "logoUrl":
            "https://upload.wikimedia.org/wikipedia/commons/2/24/Samsung_Logo.svg",
        "productCount": 2,
        "verified": true,
        "category": "Electronics",
      },
      {
        "id": "zara",
        "name": "Zara",
        "logoUrl":
            "https://upload.wikimedia.org/wikipedia/commons/7/79/Zara_Logo.svg",
        "productCount": 3,
        "verified": true,
        "category": "Clothes",
      },
      {
        "id": "hm",
        "name": "H&M",
        "logoUrl":
            "https://upload.wikimedia.org/wikipedia/commons/5/5e/H%26M-Logo.svg",
        "productCount": 2,
        "verified": true,
        "category": "Clothes",
      },
    ];

    final products = <Map<String, dynamic>>[
      {
        "id": "nike1",
        "name": "Nike Air Max",
        "price": 299.99,
        "discountPercent": 50,
        "category": "Sports",
        "brandId": "nike",
        "brandName": "Nike",
        "imageUrl":
            "https://static.nike.com/a/images/t_PDP_1280_v1/f_auto,q_auto:eco/0ed0e1b3-bc4b-42c0-bfc8-b2dfd0638825/air-max-90-mens-shoes-KkLcGR.png",
        "images": [],
        "isSuggested": true,
        "inStock": true,
      },
      {
        "id": "nike2",
        "name": "Nike Jordan",
        "price": 249.99,
        "discountPercent": 40,
        "category": "Sports",
        "brandId": "nike",
        "brandName": "Nike",
        "imageUrl":
            "https://static.nike.com/a/images/t_PDP_1280_v1/f_auto,q_auto:eco/2dbf4df0-aba2-480f-aa83-6859ed3fa6ab/air-jordan-1-mid-shoes-8MVZkq.png",
        "images": [],
        "isSuggested": true,
        "inStock": true,
      },
      {
        "id": "nike3",
        "name": "Nike Running",
        "price": 189.99,
        "discountPercent": 30,
        "category": "Sports",
        "brandId": "nike",
        "brandName": "Nike",
        "imageUrl":
            "https://static.nike.com/a/images/t_PDP_1280_v1/f_auto,q_auto:eco/b737bd00-ff6a-422c-a472-9f85be9f02ae/air-zoom-pegasus-38-mens-running-shoes-L7rnkv.png",
        "images": [],
        "isSuggested": false,
        "inStock": true,
      },
      {
        "id": "adidas1",
        "name": "Adidas Ultraboost",
        "price": 179.99,
        "discountPercent": 35,
        "category": "Sports",
        "brandId": "adidas",
        "brandName": "Adidas",
        "imageUrl":
            "https://assets.adidas.com/images/w_600,f_auto,q_auto/7a40ba4e3d2544f58b52acda0120d199_9366/Ultraboost_22_Shoes_Black_S23866_01_standard.jpg",
        "images": [],
        "isSuggested": false,
        "inStock": true,
      },
      {
        "id": "adidas2",
        "name": "Adidas Soccer Ball",
        "price": 49.99,
        "discountPercent": 20,
        "category": "Sports",
        "brandId": "adidas",
        "brandName": "Adidas",
        "imageUrl":
            "https://assets.adidas.com/images/w_600,f_auto,q_auto/264fc89fbd7f4f2aaf7dac4901885120_9366/Soccer_Ball_White_HN3584_01_standard.jpg",
        "images": [],
        "isSuggested": true,
        "inStock": true,
      },
      {
        "id": "puma1",
        "name": "Puma Suede Classic",
        "price": 129.99,
        "discountPercent": 30,
        "category": "Sports",
        "brandId": "puma",
        "brandName": "Puma",
        "imageUrl":
            "https://images.puma.com/image/upload/f_auto,q_auto,b_rgb:fafafa/global/374678/01/sv01/fnd/PNA/fmt/png",
        "images": [],
        "isSuggested": false,
        "inStock": true,
      },
      {
        "id": "ikea1",
        "name": "Office Desk",
        "price": 249.99,
        "discountPercent": 30,
        "category": "Furniture",
        "brandId": "ikea",
        "brandName": "IKEA",
        "imageUrl":
            "https://www.ikea.com/us/en/images/products/linnmon-adils-table__0615279_PE702149_S5.JPG",
        "images": [],
        "isSuggested": false,
        "inStock": true,
      },
      {
        "id": "ashley1",
        "name": "Sofa Set",
        "price": 899.99,
        "discountPercent": 35,
        "category": "Furniture",
        "brandId": "ashley",
        "brandName": "Ashley",
        "imageUrl":
            "https://ashleyfurniture.scene7.com/is/image/AshleyFurniture/8880108-80-1-ASH.jpg",
        "images": [],
        "isSuggested": true,
        "inStock": true,
      },
      {
        "id": "kenwood1",
        "name": "Kitchen Mixer",
        "price": 399.99,
        "discountPercent": 15,
        "category": "Electronics",
        "brandId": "kenwood",
        "brandName": "Kenwood",
        "imageUrl":
            "https://kenwoodworld.com/media/catalog/product/cache/1/image/800x800/9df78eab33525d08d6e5fb8d27136e95/k/m/kmix-kitchen-machine.png",
        "images": [],
        "isSuggested": false,
        "inStock": true,
      },
      {
        "id": "samsung1",
        "name": "Smart TV 55\"",
        "price": 799.99,
        "discountPercent": 25,
        "category": "Electronics",
        "brandId": "samsung",
        "brandName": "Samsung",
        "imageUrl":
            "https://images.samsung.com/is/image/samsung/p6pim/levant/qa55q60baeuxzn/gallery/levant-q60b-qe55q60baeuxzn-414993746?720_576_PNG.png",
        "images": [],
        "isSuggested": true,
        "inStock": true,
      },
      {
        "id": "zara1",
        "name": "Denim Jacket",
        "price": 89.99,
        "discountPercent": 40,
        "category": "Clothes",
        "brandId": "zara",
        "brandName": "Zara",
        "imageUrl":
            "https://static.zara.net/photos///2025/I/0/1/p/2643/150/800/2/w/563/2643150800_6_1_1.jpg",
        "images": [],
        "isSuggested": true,
        "inStock": true,
      },
      {
        "id": "hm1",
        "name": "Summer Dress",
        "price": 49.99,
        "discountPercent": 45,
        "category": "Clothes",
        "brandId": "hm",
        "brandName": "H&M",
        "imageUrl":
            "https://lp2.hm.com/hmgoepprod?set=source[/wear/2025/1/0058/100?hm.jpg]",
        "images": [],
        "isSuggested": true,
        "inStock": true,
      },
    ];

    final brandBatch = db.batch();
    for (final brand in brands) {
      final id = brand['id'] as String;
      brandBatch.set(
        db.collection('brands').doc(id),
        brand,
        SetOptions(merge: true),
      );
    }
    await brandBatch.commit();

    final productBatch = db.batch();
    for (final product in products) {
      final id = product['id'] as String;
      productBatch.set(
        db.collection('products').doc(id),
        product,
        SetOptions(merge: true),
      );
    }
    await productBatch.commit();
  }
}
