import 'package:flutter_bloc/flutter_bloc.dart';
import 'device_event.dart';
import 'device_state.dart';

class DeviceBloc extends Bloc<DeviceEvent, DeviceState> {
  DeviceBloc() : super(DeviceLoading()) {
    on<LoadDevicesEvent>(_onLoadDevices);
  }

  void _onLoadDevices(LoadDevicesEvent event, Emitter<DeviceState> emit) async {
    emit(DeviceLoading());
    await Future.delayed(const Duration(seconds: 1)); // Simulate loading
    emit(DeviceLoaded(["Device A", "Device B", "Device C"]));
  }
}
