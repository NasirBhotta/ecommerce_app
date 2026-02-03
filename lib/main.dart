import 'package:ecommerce_app/data/repositories/auth_repo.dart';
import 'package:ecommerce_app/data/repositories/order_repo.dart';
import 'package:ecommerce_app/data/repositories/user_repo.dart';
import 'package:ecommerce_app/features/authentication/controllers/auth/forgot_pass_controller.dart';
import 'package:ecommerce_app/features/authentication/controllers/auth/login_controller.dart';
import 'package:ecommerce_app/features/authentication/controllers/auth/reset_pass_controller.dart';
import 'package:ecommerce_app/features/authentication/controllers/auth/signup_controller.dart';
import 'package:ecommerce_app/features/shop/controllers/account_privact_contoller.dart';
import 'package:ecommerce_app/features/shop/controllers/addresses_controller.dart';
import 'package:ecommerce_app/features/shop/controllers/bank_account_controller.dart';
import 'package:ecommerce_app/features/shop/controllers/cart_controller.dart';
import 'package:ecommerce_app/features/shop/controllers/coupons_controller.dart';
import 'package:ecommerce_app/features/shop/controllers/home_controller.dart';
import 'package:ecommerce_app/features/shop/controllers/navigation_controller.dart';
import 'package:ecommerce_app/features/shop/controllers/notifications_controller.dart';
import 'package:ecommerce_app/features/shop/controllers/orders_controller.dart';
import 'package:ecommerce_app/features/shop/controllers/product_detail_controller.dart';
import 'package:ecommerce_app/features/shop/controllers/profile_controller.dart';
import 'package:ecommerce_app/features/shop/controllers/profile_edit_controller.dart';
import 'package:ecommerce_app/features/shop/controllers/store_controller.dart';
import 'package:ecommerce_app/features/shop/controllers/whishlist_controller.dart';
import 'package:ecommerce_app/firebase_options.dart';
import 'package:ecommerce_app/util/theme/custom_theme/text_theme.dart';
import 'package:ecommerce_app/util/theme/theme.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  Stripe.publishableKey =
      'pk_test_51SuIzBR2isNwrykZXBnXKwPdhLAi3MYTCfFV6vmEhkytyzY91ZvzXBmGXVwl9N3d9taQPhnEHU11jiit2AqAeTqf00Nj98cNLG';

  await GetStorage.init();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((FirebaseApp value) {
    Get.put(AuthenticationRepository());
    Get.put(UserRepository());
  });

  // await FirebaseAppCheck.instance.activate(
  //   // For Android
  //   androidProvider: AndroidProvider.debug,
  //   // For iOS
  //   appleProvider: AppleProvider.debug,
  // );
  runApp(const EcommrceApp());
}

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Lazy initialization - controllers created only when needed
    Get.lazyPut<LoginController>(() => LoginController(), fenix: true);
    Get.lazyPut<SignUpController>(() => SignUpController(), fenix: true);
    Get.lazyPut<ForgotPasswordController>(
      () => ForgotPasswordController(),
      fenix: true,
    );
    Get.lazyPut<ResetPasswordController>(
      () => ResetPasswordController(),
      fenix: true,
    );
    Get.lazyPut<NavigationController>(
      () => NavigationController(),
      fenix: true,
    );
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);

    Get.lazyPut<ProductDetailController>(
      () => ProductDetailController(),
      fenix: true,
    );

    Get.lazyPut<StoreController>(() => StoreController(), fenix: true);
    Get.lazyPut<WishlistController>(() => WishlistController(), fenix: true);

    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
    Get.lazyPut<ProfileEditController>(
      () => ProfileEditController(),
      fenix: true,
    );
    Get.lazyPut<AddressController>(() => AddressController(), fenix: true);
    Get.lazyPut<OrdersController>(() => OrdersController(), fenix: true);
    Get.lazyPut<OrderRepository>(() => OrderRepository(), fenix: true);

    Get.lazyPut<CartController>(() => CartController(), fenix: true);
    Get.lazyPut<BankAccountController>(
      () => BankAccountController(),
      fenix: true,
    );
    Get.lazyPut<CouponsController>(() => CouponsController(), fenix: true);
    Get.lazyPut<NotificationsController>(
      () => NotificationsController(),
      fenix: true,
    );
    Get.lazyPut<AccountPrivacyController>(
      () => AccountPrivacyController(),
      fenix: true,
    );
  }
}

class EcommrceApp extends StatelessWidget {
  const EcommrceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'E-Commerce App',
      themeMode: ThemeMode.system,
      theme: BAppTheme.lightTheme,
      darkTheme: BAppTheme.darkTheme,
      initialBinding: AppBindings(),
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),

      home: const Scaffold(
        backgroundColor: BColors.primary,
        body: Center(child: CircularProgressIndicator(color: BColors.white)),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
