import 'package:flutter/widgets.dart';

class ProductTourStep {
  const ProductTourStep({
    required this.videoAssetPath,
    this.title,
    this.description,
    this.isNetworkVideo = false,
    this.targetKey,
    this.highlightPadding = 8,
    this.highlightBorderRadius = 12,
  });

  final String videoAssetPath;
  final String? title;
  final String? description;
  final bool isNetworkVideo;
  final GlobalKey? targetKey;
  final double highlightPadding;
  final double highlightBorderRadius;
}