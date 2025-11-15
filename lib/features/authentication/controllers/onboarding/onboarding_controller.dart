import 'package:ecommerce_app/features/authentication/screens/authscreens/login.dart';
import 'package:ecommerce_app/util/constants/BText.dart';
import 'package:ecommerce_app/util/constants/Bimages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:gif/gif.dart';

class OnboardingController extends GetxController
    with GetTickerProviderStateMixin {
  // Observables
  final currentIndex = 0.obs;

  // Controllers
  late PageController pageController;
  late List<GifController> gifControllers;

  // Data
  final List<int> gifFrames = [0, 0, 0];

  final List<String> images = [
    BImages.onBoardingImage1,
    BImages.onBoardingImage2,
    BImages.onBoardingImage3,
  ];

  final List<String> titles = [
    BTexts.onBoardingTitle1,
    BTexts.onBoardingTitle2,
    BTexts.onBoardingTitle3,
  ];

  final List<String> subtitles = [
    BTexts.onBoardingSubTitle1,
    BTexts.onBoardingSubTitle2,
    BTexts.onBoardingSubTitle3,
  ];

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    gifControllers = List.generate(
      images.length,
      (_) => GifController(vsync: this),
    );
  }

  @override
  void onClose() {
    for (final controller in gifControllers) {
      controller.dispose();
    }
    pageController.dispose();
    super.onClose();
  }

  void onPageChanged(int index) {
    gifControllers[currentIndex.value].stop();
    currentIndex.value = index;
    if (gifFrames[index] > 0) {
      gifControllers[index].repeat(
        min: 0,
        max: gifFrames[index] - 1,
        period: const Duration(seconds: 2),
      );
    }
  }

  void nextPage() {
    if (currentIndex.value == images.length - 1) {
      // Smooth transition with fade

      final deviceStorage = GetStorage();
      deviceStorage.write("isFirstTime", false);
      Get.offAll(
        () => const LoginScreen(),
        transition: Transition.rightToLeft,

        duration: const Duration(milliseconds: 250),
      );
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void skipToEnd() {
    pageController.animateToPage(
      images.length - 1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }
}
