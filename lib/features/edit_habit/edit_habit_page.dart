import '/core/core.dart';
import '/core/widgets/flushbar_widget.dart';
import '/core/widgets/habit_color_sheet/cubit/habit_color_cubit.dart';
import '/core/widgets/habit_icon/cubit/habit_icon_cubit.dart';
import '/core/widgets/habit_icon/icon_picker_sheet.dart';
import '/models/models.dart';
import '../../core/helpers/spacing_helper.dart';
import '../habits/bloc/habit_bloc.dart';
import '../reminder/bloc/reminder/reminder_bloc.dart';
import '../reminder/widget/reminder_selection_widget.dart';
import 'bloc/edit_habit_bloc.dart';
import 'provider/edit_habit_provider.dart';

class EditHabitPage extends StatefulWidget {
  final Habit habit;

  const EditHabitPage({super.key, required this.habit});

  @override
  State<EditHabitPage> createState() => _EditHabitPageState();
}

class _EditHabitPageState extends State<EditHabitPage> {
  final FocusNode _focusNode = FocusNode();
  late final TextEditingController _habitNameController;
  late final TextEditingController _habitDescriptionController;
  late final ReminderBloc _reminderBloc;
  late final HabitEmojiCubit _habitEmojiCubit;
  late final HabitColorCubit _habitColorCubit;

  @override
  void initState() {
    super.initState();
    _habitNameController = TextEditingController(text: widget.habit.habitName);
    _habitDescriptionController = TextEditingController(text: widget.habit.habitDescription);
    _reminderBloc = ReminderBloc()
      ..add(InitializeReminderEvent(
        reminder: widget.habit.reminderModel,
        context: context,
      ));
    _habitEmojiCubit = HabitEmojiCubit()..pickIcon(widget.habit.emoji);
    _habitColorCubit = HabitColorCubit()..pickColor(Color(widget.habit.colorCode));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _habitNameController.dispose();
    _habitDescriptionController.dispose();
    _reminderBloc.close();
    _habitEmojiCubit.close();
    _habitColorCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _reminderBloc),
        BlocProvider.value(value: _habitEmojiCubit),
        BlocProvider.value(value: _habitColorCubit),
      ],
      child: Builder(
        builder: (context) {
          return EditHabitProvider(
            habit: widget.habit,
            child: BlocConsumer<HabitBloc, HabitState>(
              listener: (context, state) {
                if (state is HabitsFetched) {
                  final updatedHabit = state.habits.firstWhere(
                    (h) => h.id == widget.habit.id,
                    orElse: () => widget.habit,
                  );
                  if (updatedHabit != widget.habit) {
                    // Update text controllers with new values
                    _habitNameController.text = updatedHabit.habitName;
                    _habitDescriptionController.text = updatedHabit.habitDescription ?? '';
                  }
                }
              },
              builder: (context, habitState) {
                return Builder(
                  builder: (context) {
                    return CupertinoPageScaffold(
                      navigationBar: SheetHeader(
                        title: LocaleKeys.habit_edit_habit.tr(),
                        closeButtonPosition: CloseButtonPosition.left,
                        trailing: BlocConsumer<EditHabitBloc, EditHabitState>(
                          listener: (context, state) {
                            if (state is EditHabitSuccess) {
                              Navigator.pop(context);
                            }
                            if (state is EditHabitFailure) {
                              AppFlushbar.shared.errorFlushbar(state.error);
                            }
                          },
                          builder: (context, state) {
                            return CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: state is EditHabitLoading
                                  ? null
                                  : () {
                                      final reminderState = context.read<ReminderBloc>().state;
                                      final habitIconState = context.read<HabitEmojiCubit>().state;
                                      final habitColorState = context.read<HabitColorCubit>().state;

                                      final updatedHabit = widget.habit.copyWith(
                                        habitName: _habitNameController.text,
                                        habitDescription: _habitDescriptionController.text,
                                        emoji: habitIconState.emoji ?? widget.habit.emoji,
                                        colorCode: habitColorState.color?.value ?? widget.habit.colorCode,
                                        reminderModel: reminderState.reminder,
                                      );

                                      context.read<EditHabitBloc>().add(UpdateEditHabitEvent(habit: updatedHabit));
                                    },
                              child: state is EditHabitLoading
                                  ? const CupertinoActivityIndicator()
                                  : Text(
                                      LocaleKeys.common_save.tr(),
                                      style: context.titleMedium?.copyWith(
                                        color: context.primary,
                                      ),
                                    ),
                            );
                          },
                        ),
                      ),
                      child: ListView(
                        padding: const EdgeInsets.all(15),
                        children: [
                          SafeArea(
                            bottom: false,
                            child: Column(
                              spacing: KSpacing.betweenListItems,
                              children: [
                                CustomHeader(
                                  text: LocaleKeys.habit_habit_name.tr().toUpperCase(),
                                  child: _buildHabitTextField(
                                    controller: _habitNameController,
                                  ),
                                ),
                                CustomHeader(
                                  text: LocaleKeys.habit_habit_description.tr().toUpperCase(),
                                  child: _buildHabitTextField(
                                    controller: _habitDescriptionController,
                                  ),
                                ),
                                ReminderSelectionWidget(),
                                CustomHeader(
                                  text: LocaleKeys.common_icon.tr().toUpperCase(),
                                  child: IconPickerSheet(
                                    selectedIcon: widget.habit.emoji,
                                    onIconSelected: (icon) {
                                      context.read<HabitEmojiCubit>().pickIcon(icon);
                                    },
                                  ),
                                ),
                                CustomHeader(
                                  text: LocaleKeys.colors_color.tr().toUpperCase(),
                                  child: ColorPickerSheet(
                                    selectedColor: Color(widget.habit.colorCode),
                                    onColorSelected: (color) {
                                      context.read<HabitColorCubit>().pickColor(color);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildHabitTextField({required TextEditingController controller, String? placeHolder}) {
    return Card(
      child: CupertinoTextField(
        padding: EdgeInsets.all(10),
        maxLines: null,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        placeholder: placeHolder,
        controller: controller,
      ),
    );
  }
}
