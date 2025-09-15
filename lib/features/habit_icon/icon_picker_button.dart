import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import 'provider/habit_icon_provider.dart';

class IconPickerButton extends ConsumerWidget {
  final String? selectedIcon;
  final Color? habitColor;

  const IconPickerButton({
    super.key,
    this.selectedIcon,
    this.habitColor,
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
      height: 130,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomButton(
            onPressed: () {
              context.hideKeyboard();

              navigator.navigateTo(path: KRoute.iconPage);
            },
            child: Center(
              child: Container(
                height: 90,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.theme.scaffoldBackgroundColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: habitColor?.withValues(alpha: 0.7) ?? Colors.grey.withValues(alpha: .7),
                    width: .5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: habitColor?.withValues(alpha: 0.25) ?? Colors.grey.withValues(alpha: 0.25),
                      spreadRadius: 10,
                      blurRadius: 30,
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
          ),
        ],
      ),
    );
  }
}
