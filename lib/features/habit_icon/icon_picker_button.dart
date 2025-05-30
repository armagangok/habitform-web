import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import 'provider/habit_icon_provider.dart';

class IconPickerButton extends ConsumerWidget {
  final String? selectedIcon;

  const IconPickerButton({
    super.key,
    this.selectedIcon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIcon = ref.watch(iconProvider) ?? this.selectedIcon ?? '📝';

    // // Icons for the background grid
    // final List<IconData> backgroundIcons = [
    //   FontAwesomeIcons.dumbbell,
    //   FontAwesomeIcons.pizzaSlice,
    //   FontAwesomeIcons.personRunning,
    //   FontAwesomeIcons.camera,
    //   FontAwesomeIcons.paw,
    //   FontAwesomeIcons.futbol,
    //   FontAwesomeIcons.gamepad,
    //   FontAwesomeIcons.heart,
    //   FontAwesomeIcons.book,
    //   FontAwesomeIcons.penToSquare,
    //   FontAwesomeIcons.music,
    //   FontAwesomeIcons.bell,
    //   FontAwesomeIcons.briefcase,
    //   FontAwesomeIcons.gift,
    //   FontAwesomeIcons.lightbulb,
    //   FontAwesomeIcons.moneyBillWave,
    //   FontAwesomeIcons.utensils,
    //   FontAwesomeIcons.bicycle,
    //   FontAwesomeIcons.leaf,
    //   FontAwesomeIcons.brain,
    //   FontAwesomeIcons.rulerCombined,
    // ];

    return SizedBox(
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // // Background with icons in a grid layout
          // Positioned.fill(
          //   child: LayoutBuilder(builder: (context, constraints) {
          //     // Calculate grid layout based on available space
          //     const iconsPerRow = 7; // 7 icons per row
          //     const rows = 3; // 3 rows total

          //     // Only use icons that fit in the grid
          //     final visibleIcons = backgroundIcons.take(iconsPerRow * rows).toList();

          //     return GridView.count(
          //       crossAxisCount: iconsPerRow,
          //       shrinkWrap: true,
          //       physics: const NeverScrollableScrollPhysics(),
          //       children: visibleIcons.asMap().entries.map((entry) {
          //         int index = entry.key; // Get the index
          //         IconData icon = entry.value; // Get the icon

          //         // Determine rotation based on index
          //         double rotationAngle = index % 2 == 0 ? -16.8 * (3.14 / 180) : 16.8 * (3.14 / 180); // Convert degrees to radians

          //         return Opacity(
          //           opacity: 1,
          //           child: Padding(
          //             padding: const EdgeInsets.all(8.0),
          //             child: Transform.rotate(
          //               angle: rotationAngle, // Apply rotation
          //               child: Card(
          //                 shape: RoundedRectangleBorder(
          //                   borderRadius: BorderRadius.circular(8),
          //                   side: BorderSide(
          //                     color: Colors.grey.withValues(alpha: 0.7),
          //                     width: .5,
          //                   ),
          //                 ),
          //                 child: Padding(
          //                   padding: const EdgeInsets.all(5.0),
          //                   child: Center(
          //                     child: Icon(
          //                       icon,
          //                       size: 18,
          //                       color: context.theme.iconTheme.color,
          //                     ),
          //                   ),
          //                 ),
          //               ),
          //             ),
          //           ),
          //         );
          //       }).toList(),
          //     );
          //   }),
          // ),

          // Card(
          //   child: CustomBlurWidget(
          //     blurValue: 100,
          //     child: SizedBox.expand(),
          //   ),
          // ),
          // Main button
          CustomButton(
            onPressed: () {
              context.hideKeyboard();

              navigator.navigateTo(path: KRoute.iconPage);
            },
            child: Container(
              height: 90,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.theme.scaffoldBackgroundColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey.withValues(alpha: .7),
                  width: .5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.25),
                    spreadRadius: 15,
                    blurRadius: 50,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Text(
                selectedIcon,
                style: const TextStyle(fontSize: 40, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
