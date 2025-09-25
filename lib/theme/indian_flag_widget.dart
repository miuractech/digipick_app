import 'package:flutter/material.dart';
import 'package:flag/flag.dart';

/// A reusable widget that displays the Indian flag using the flag package
class IndianFlagWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const IndianFlagWidget({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(18),
      child: Flag.fromCode(
        FlagsCode.IN, // India country code
        width: width ?? 20,
        height: height ?? 14,
        fit: BoxFit.cover,
      ),
    );
  }
}

/// Alternative implementation using a simple container-based flag
/// if the flag package doesn't work as expected
class SimpleIndianFlagWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const SimpleIndianFlagWidget({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final flagWidth = width ?? 20;
    final flagHeight = height ?? 14;
    final stripeHeight = flagHeight / 3;

    return Container(
      width: flagWidth,
      height: flagHeight,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(2),
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
      child: Column(
        children: [
          // Saffron stripe
          Container(
            width: flagWidth,
            height: stripeHeight,
            decoration: BoxDecoration(
              color: const Color(0xFFFF9933), // Saffron
              borderRadius: BorderRadius.only(
                topLeft: (borderRadius ?? BorderRadius.circular(2)).topLeft,
                topRight: (borderRadius ?? BorderRadius.circular(2)).topRight,
              ),
            ),
          ),
          // White stripe with chakra
          Container(
            width: flagWidth,
            height: stripeHeight,
            color: Colors.white,
            child: Center(
              child: Container(
                width: stripeHeight * 0.6,
                height: stripeHeight * 0.6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF000080), // Navy blue
                    width: 0.5,
                  ),
                ),
                child: const Icon(
                  Icons.trip_origin,
                  size: 4,
                  color: Color(0xFF000080),
                ),
              ),
            ),
          ),
          // Green stripe
          Container(
            width: flagWidth,
            height: stripeHeight,
            decoration: BoxDecoration(
              color: const Color(0xFF138808), // India green
              borderRadius: BorderRadius.only(
                bottomLeft: (borderRadius ?? BorderRadius.circular(2)).bottomLeft,
                bottomRight: (borderRadius ?? BorderRadius.circular(2)).bottomRight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
