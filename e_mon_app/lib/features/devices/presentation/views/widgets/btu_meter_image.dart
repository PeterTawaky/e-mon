import 'package:e_mon_app/core/utils/app_assets.dart';
import 'package:flutter/material.dart';

class BtuMeterImage extends StatelessWidget {
  const BtuMeterImage({super.key, this.height});

  final double? height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      Assets.imagesWintersBtuMeter,
      height: height,
      fit: BoxFit.contain,
    );
  }
}
