import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/core.dart';
import '../../models/create_habit_step.dart';
import '../../provider/create_habit_provider.dart';
import 'base_step_widget.dart';

class HabitNameStep extends ConsumerStatefulWidget {
  const HabitNameStep({super.key});

  @override
  ConsumerState<HabitNameStep> createState() => _HabitNameStepState();
}

class _HabitNameStepState extends ConsumerState<HabitNameStep> {
  late TextEditingController _controller;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    final initial = ref.read(createHabitProvider);
    // Use provider controller if ready; otherwise create a temporary one
    _controller = initial.value?.habitNameController ?? TextEditingController();
    _controller.addListener(_onTextChanged);
    _updateValidation();
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    _updateValidation();
  }

  void _updateValidation() {
    final isValid = _controller.text.trim().isNotEmpty;
    if (isValid != _isValid) {
      setState(() {
        _isValid = isValid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keep controller in sync with provider once available
    ref.listen(createHabitProvider, (prev, next) {
      if (next.hasValue && next.value != null) {
        final providerController = next.value!.habitNameController;
        if (!identical(providerController, _controller)) {
          if (_controller.text.isNotEmpty && providerController.text != _controller.text) {
            providerController.text = _controller.text;
          }
          _controller.removeListener(_onTextChanged);
          _controller = providerController;
          _controller.addListener(_onTextChanged);
          _updateValidation();
          setState(() {});
        }
      }
    });
    return BaseStepWidget(
      step: CreateHabitStep.habitName,
      canProceed: _isValid,
      onNext: () {
        ref.read(createHabitProvider.notifier).nextStep();
      },
      child: Column(
        children: [
          // Step title and description
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What habit would you like to build?',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose a clear, specific name for your habit. For example: "Drink 8 glasses of water" instead of just "Stay hydrated".',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                ),
              ],
            ),
          ),

          // Input section
          CupertinoListSection.insetGrouped(
            children: [
              CupertinoListTile(
                title: CupertinoTextField(
                  controller: _controller,
                  placeholder: LocaleKeys.habit_habit_name.tr(),
                  decoration: null,
                  style: Theme.of(context).textTheme.titleMedium,
                  autofocus: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
