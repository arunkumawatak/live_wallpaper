import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../viewmodels/settings_viewmodel.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(

     appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // ListTile(
            //   title: const Text("Dot Color"),
            //   trailing: CircleAvatar(backgroundColor: settings.dotColor),
            //   onTap: () {
            //     showDialog(
            //       context: context,
            //       builder: (_) => AlertDialog(
            //         title: const Text("Pick Dot Color"),
            //         content: BlockPicker(
            //           availableColors: [
            //             Color(0xffffcf00),
            //             Color(0xfffdf9b6),
            //             Color(0xff798bd8),
            //             Color(0xff2fe8ff),
            //             Color(0xfffee5a8),
            //             Color(0xfff1e194),
            //             Color(0xffACC8a2),
            //             Color(0xff233d4c),
            //             Color(0xffcbdde9),
            //             Color(0xfffefacd),
            //             Color(0xffffd2c2),
            //           ],
            //           pickerColor: settings.dotColor,
            //           onColorChanged: (color) => ref
            //               .read(settingsProvider.notifier)
            //               .updateDotColor(color),
            //         ),
            //       ),
            //     );
            //   },
            // ),
            ListTile(
              title: const Text("Background Color"),
              trailing: CircleAvatar(backgroundColor: settings.backgroundColor),
              onTap: () {
                showDialog(
                  context: context,

                  builder: (_) => AlertDialog(
                    title: const Text("Pick Background Color"),
                    content: BlockPicker(
                      pickerColor: settings.backgroundColor,
                      availableColors: [
                        Color(0xff014726),
                        Color(0xff720065),
                        Color(0xffffffff),
                        Color(0xff001935),
                        Color(0xffff2e23),
                        Color(0xff5b0e14),
                        Color(0xff1a2517),
                        Color(0xfffd802e),
                        Color(0xff2872a1),
                        Color(0xff5f4a8b),
                        Color(0xff789a99),
                      ],
                      onColorChanged: (color) => ref
                          .read(settingsProvider.notifier)
                          .updatColor(bgColor: color),
                    ),
                  ),
                );
              },
            ),
            SwitchListTile(
              title: const Text("Show Percentage"),
              value: settings.showPercentage,
              onChanged: (val) =>
                  ref.read(settingsProvider.notifier).toggleShowPercentage(val),
            ),
            SwitchListTile(
              title: const Text("Circle Dots"),
              value: settings.isCircle,
              onChanged: (val) =>
                  ref.read(settingsProvider.notifier).toggleShape(val),
            ),
            ListTile(
              title: const Text("Grid Density"),
              subtitle: Slider(
                min: 5,
                max: 20,
                divisions: 15,
                value: settings.gridDensity.toDouble(),
                onChanged: (val) => ref
                    .read(settingsProvider.notifier)
                    .updateGridDensity(val.toInt()),
              ),
              trailing: Text("${settings.gridDensity}"),
            ),
          ],
        ),
      ),
    );
  }
}
