import 'package:bloc/bloc.dart';

class PickerExtendCubit extends Cubit<bool> {
  PickerExtendCubit() : super(false);

  void switchExtendValue() => emit(!state);

  void setValue(bool value) => emit(value);

  void initialize(bool initialValue) => emit(initialValue);
}
