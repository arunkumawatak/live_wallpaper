import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/settings_model.dart';

final settingsProvider =
    StateNotifierProvider<SettingsViewModel, WallpaperSettings>((ref) {
      return SettingsViewModel();
    });

class SettingsViewModel extends StateNotifier<WallpaperSettings> {
  static const platform = MethodChannel('com.example.live_wallpaper/wallpaper');

  SettingsViewModel()
    : super(
        WallpaperSettings(
          dotColor: const Color(0xFFFFC107),
          backgroundColor: Colors.black,
        ),
      );

  // void updateDotColor(Color color) {
  //   state = WallpaperSettings(
  //       dotColor: color,
  //       backgroundColor: state.backgroundColor,
  //       showPercentage: state.showPercentage,
  //       isCircle: state.isCircle,
  //       gridDensity: state.gridDensity);
  //   _sendToNative();
  // }

  // void updatColor({
  //   required Color bgColor,
  //   // required Color dotColor,
  // }) {
  //   print("vcolor$bgColor");
  //   state = WallpaperSettings(
  //     dotColor: state.dotColor,
  //     backgroundColor: bgColor,
  //     showPercentage: state.showPercentage,
  //     isCircle: state.isCircle,
  //     gridDensity: state.gridDensity,
  //   );
  //   _sendToNative();
  // }

  void toggleShowPercentage(bool value) {
    state = WallpaperSettings(
      dotColor: state.dotColor,
      backgroundColor: state.backgroundColor,
      showPercentage: value,
      isCircle: state.isCircle,
      gridDensity: state.gridDensity,
    );
    _sendToNative();
  }

  void toggleShape(bool isCircle) {
    state = WallpaperSettings(
      dotColor: state.dotColor,
      backgroundColor: state.backgroundColor,
      showPercentage: state.showPercentage,
      isCircle: isCircle,
      gridDensity: state.gridDensity,
    );
    _sendToNative();
  }

  void updateGridDensity(int density) {
    state = WallpaperSettings(
      dotColor: state.dotColor,
      backgroundColor: state.backgroundColor,
      showPercentage: state.showPercentage,
      isCircle: state.isCircle,
      gridDensity: density,
    );
    _sendToNative();
  }

  Future<void> _sendToNative() async {
    try {
      int dayOfYear =
          DateTime.now()
              .difference(DateTime(DateTime.now().year, 1, 1))
              .inDays +
          1;
      await platform.invokeMethod('updateSettings', {
        'dayOfYear': dayOfYear,
        'dotColor': state.dotColor.value,
        'backgroundColor': state.backgroundColor.value,
        'showPercentage': state.showPercentage,
        'isCircle': state.isCircle,
        'gridDensity': state.gridDensity,
      });
    } on PlatformException catch (e) {
      print("Error sending settings to native: ${e.message}");
    }
  }

  Future<void> setWallpaper() async {
    try {
      await platform.invokeMethod('setWallpaper');
    } on PlatformException catch (e) {
      print("Error setting wallpaper: ${e.message}");
    }
  }

  void updatColor({required Color bgColor}) {
    final mappedDotColor = colorMapping[bgColor] ?? state.dotColor;

    state = WallpaperSettings(
      dotColor: mappedDotColor,
      backgroundColor: bgColor,
      showPercentage: state.showPercentage,
      isCircle: state.isCircle,
      gridDensity: state.gridDensity,
    );

    _sendToNative();
  }

  final Map<Color, Color> colorMapping = {
    const Color(0xff014726): const Color(0xffffcf00),
    const Color(0xff720065): const Color(0xfffdf9b6),
    const Color(0xffffffff): const Color(0xff798bd8),
    const Color(0xff001935): const Color(0xff2fe8ff),
    const Color(0xffff2e23): const Color(0xfffee5a8),
    const Color(0xff5b0e14): const Color(0xfff1e194),
    const Color(0xff1a2517): const Color(0xffACC8a2),
    const Color(0xfffd802e): const Color(0xff233d4c),
    const Color(0xff2872a1): const Color(0xffcbdde9),
    const Color(0xff5f4a8b): const Color(0xfffefacd),
    const Color(0xff789a99): const Color(0xffffd2c2),
  };
}
