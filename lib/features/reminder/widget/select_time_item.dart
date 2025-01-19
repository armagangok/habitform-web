import 'dart:math';

import '../../../core/core.dart';
import '../bloc/day_selection/day_selection_cubit.dart';
import '../bloc/picker_extend/picker_extend_cubit.dart';
import '../bloc/remind_time/remind_time_cubit.dart';
import '../models/days/days_enum.dart';

class SelectTimeItem extends StatelessWidget {
  const SelectTimeItem({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DaySelectionCubit, List<Days>>(
      builder: (context, selectedDays) {
        if (selectedDays.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<PickerExtendCubit>().setValue(false);
          });
          return const SizedBox.shrink();
        }

        return BlocBuilder<PickerExtendCubit, bool>(
          builder: (context, state) {
            final isExpanded = state;
            return BlocBuilder<RemindTimeCubit, DateTime?>(
              builder: (context, state) {
                final remindTime = state;
                return AnimatedSize(
                  duration: Duration(milliseconds: 300),
                  child: CupertinoListTile(
                    title: Text(LocaleKeys.reminder_select_time.tr()),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          remindTime?.toHHMM() ?? LocaleKeys.common_none.tr(),
                          style: TextStyle(
                            color: CupertinoColors.systemBlue,
                            fontWeight: FontWeight.normal,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Transform.rotate(
                          angle: isExpanded ? pi / 2 : 0,
                          child: CupertinoListTileChevron().animate().fadeIn(),
                        ),
                      ],
                    ),
                    onTap: () {
                      context.read<PickerExtendCubit>().switchExtendValue();
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
