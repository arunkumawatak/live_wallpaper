import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_wallpaper/models/settings_model.dart';
import '../viewmodels/settings_viewmodel.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final dayOfYear = _getDayOfYear();
    final totalDots = _isLeapYear(DateTime.now().year) ? 366 : 365;

    return Scaffold(
      appBar: AppBar(
        title: const Text('365 Year Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Live Preview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                elevation: 8,
                clipBehavior: Clip.antiAlias,
                child: AspectRatio(
                  aspectRatio: 9 / 16, // portrait phone preview
                  child: CustomPaint(
                    painter: YearProgressPainter(
                      settings: settings,
                      dayOfYear: dayOfYear,
                      totalDots: totalDots,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.wallpaper),
              label: const Text('Set as Live Wallpaper'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: () {
                ref.read(settingsProvider.notifier).setWallpaper();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Wallpaper chooser opened – select "Year Progress Wallpaper"'),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Tip: Settings changes update instantly in preview and on wallpaper.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  int _getDayOfYear() {
    final now = DateTime.now();
    final start = DateTime(now.year, 1, 1);
    return now.difference(start).inDays + 1;
  }

  bool _isLeapYear(int year) =>
      year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);
}

// ============== PREVIEW PAINTER (exact mirror of native Canvas) ==============
class YearProgressPainter extends CustomPainter {
  final WallpaperSettings settings;
  final int dayOfYear;
  final int totalDots;

  YearProgressPainter({
    required this.settings,
    required this.dayOfYear,
    required this.totalDots,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    canvas.drawColor(settings.backgroundColor, BlendMode.src);

    final cols = settings.gridDensity;
    final rows = ((totalDots + cols - 1) / cols).ceil();
    final cellW = size.width / cols;
    final cellH = size.height / rows;
    final dotSize = (cellW < cellH ? cellW : cellH) * 0.72;

    final filledPaint = Paint()
      ..color = settings.dotColor
      ..style = PaintingStyle.fill;
    final unfilledPaint = Paint()
      ..color = settings.dotColor.withAlpha(80)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < totalDots; i++) {
      final row = i ~/ cols;
      final col = i % cols;
      final x = col * cellW + cellW / 2;
      final y = row * cellH + cellH / 2;

      final paint = i < dayOfYear ? filledPaint : unfilledPaint;

      if (settings.isCircle) {
        canvas.drawCircle(Offset(x, y), dotSize / 2, paint);
      } else {
        final rect = Rect.fromCenter(
          center: Offset(x, y),
          width: dotSize,
          height: dotSize,
        );
        canvas.drawRect(rect, paint);
      }
    }

    // Percentage (center, large, white with shadow)
    if (settings.showPercentage) {
      final percent = (dayOfYear / totalDots * 100).round();
      final textPainter = TextPainter(
        text: TextSpan(
          text: '$percent%',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 68,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(color: Colors.black26, blurRadius: 8, offset: Offset(2, 2))
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(
          (size.width - textPainter.width) / 2,
          (size.height - textPainter.height) / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant YearProgressPainter old) =>
      settings != old.settings ||
      dayOfYear != old.dayOfYear ||
      totalDots != old.totalDots;
}