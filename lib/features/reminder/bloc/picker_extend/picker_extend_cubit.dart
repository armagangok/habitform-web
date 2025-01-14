import 'package:bloc/bloc.dart';

class PickerExtendCubit extends Cubit<bool> {
  PickerExtendCubit() : super(false);

  void switchExtendValue() => emit(!state);

  void initialize(bool initialValue) => emit(initialValue);
}
