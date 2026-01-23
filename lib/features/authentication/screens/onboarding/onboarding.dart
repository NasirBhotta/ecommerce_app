import 'package:ecommerce_app/features/authentication/controllers/onboarding/onboarding_controller.dart';
import 'package:ecommerce_app/util/constants/sized.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gif/gif.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(BSizes.paddingLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: controller.images.length,
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Gif(
                        controller: controller.gifControllers[index],
                        image: AssetImage(controller.images[index]),
                        height: BSizes.imageXLarge,
                        fit: BoxFit.contain,
                        fps: 30,
                        autostart: Autostart.once,
                        onFetchCompleted: () {
                          controller.gifControllers[index].repeat(
                            period: const Duration(seconds: 2),
                          );
                        },
                      ),
                      const SizedBox(height: BSizes.spaceBetweenItems),
                      Text(
                        controller.titles[index],
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: BSizes.fontXl,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: BSizes.spaceBetweenItems),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: BSizes.paddingMd,
                        ),
                        child: Text(
                          controller.subtitles[index],
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            fontSize: BSizes.fontMd,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: BSizes.paddingLg),
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      controller.images.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        width:
                            controller.currentIndex.value == index ? 24.0 : 8.0,
                        height: 8.0,
                        decoration: BoxDecoration(
                          color:
                              controller.currentIndex.value == index
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: controller.nextPage,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: BSizes.paddingMd,
                        vertical: BSizes.paddingSm,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          BSizes.buttonRadius,
                        ),
                      ),
                    ),
                    child: const Icon(Icons.arrow_forward, size: BSizes.iconMd),
                  ),
                ],
              ),
            ),
            const SizedBox(height: BSizes.paddingSm),
          ],
        ),
      ),
    );
  }
}
