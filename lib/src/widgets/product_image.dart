import 'package:flutter/material.dart';

Widget buildProductImage(
  String imageSource, {
  BoxFit fit = BoxFit.cover,
  double? width,
  double? height,
  FilterQuality filterQuality = FilterQuality.low,
  Widget? placeholder,
}) {
  final Widget fallback = placeholder ?? _defaultPlaceholder(width, height);
  if (imageSource.trim().isEmpty) {
    return fallback;
  }

  if (imageSource.startsWith('http')) {
    return Image.network(
      imageSource,
      fit: fit,
      width: width,
      height: height,
      filterQuality: filterQuality,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }

  return Image.asset(
    imageSource,
    fit: fit,
    width: width,
    height: height,
    filterQuality: filterQuality,
    errorBuilder: (context, error, stackTrace) => fallback,
  );
}

Widget _defaultPlaceholder(double? width, double? height) {
  return SizedBox(
    width: width,
    height: height,
    child: const Center(
      child: Icon(
        Icons.cleaning_services,
        size: 32,
        color: Colors.grey,
      ),
    ),
  );
}
