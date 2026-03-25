import 'package:flutter/material.dart';

class WallpaperSettings {
  Color dotColor;
  Color backgroundColor;
  bool showPercentage;
  bool isCircle;
  int gridDensity;

  WallpaperSettings({
    required this.dotColor,
    required this.backgroundColor,
    this.showPercentage = true,
    this.isCircle = true,
    this.gridDensity = 10,
  });

  Map<String, dynamic> toMap() => {
        'dotColor': dotColor.value,
        'backgroundColor': backgroundColor.value,
        'showPercentage': showPercentage,
        'isCircle': isCircle,
        'gridDensity': gridDensity,
      };
}