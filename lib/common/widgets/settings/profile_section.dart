import 'package:ecommerce_app/util/constants/sized.dart';
import 'package:flutter/material.dart';

class BProfileSectionHeading extends StatelessWidget {
  const BProfileSectionHeading({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: BSizes.paddingMd,
        top: BSizes.spaceBetweenSections,
        bottom: BSizes.spaceBetweenItems,
      ),
      child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
    );
  }
}
