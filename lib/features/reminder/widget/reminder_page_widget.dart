import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '../provider/remind_time_provider.dart';
import '../provider/reminder_provider.dart';
import 'days_selection_widget.dart';
import 'select_time_widget.dart';
import 'selection_buttons.dart';

class ReminderPage extends ConsumerWidget {
  const ReminderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ReminderPageContent();
  }
}

class _ReminderPageContent extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ReminderPageContent> createState() => _ReminderPageContentState();
}

class _ReminderPageContentState extends ConsumerState<_ReminderPageContent> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reminderTime = ref.watch(reminderProvider).reminder?.reminderTime;
      if (reminderTime != null) {
        ref.read(remindTimeProvider.notifier).setTime(reminderTime);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: SheetHeader(
        closeButtonPosition: CloseButtonPosition.left,
        title: LocaleKeys.habit_reminder.tr(),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              Column(
                children: [
                  CustomHeader(
                    text: LocaleKeys.common_days.tr(),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: DaySelectionWidget(),
                      ),
                    ),
                  ),
                  SelectionButtons(),
                ],
              ),
              const SizedBox(height: 30),
              CustomHeader(
                text: LocaleKeys.reminder_time.tr(),
                child: SelectTimeWidget().animate(),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 32)),
            ],
          ),
        ),
      ),
    );
  }
}
