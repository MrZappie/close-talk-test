import 'package:equatable/equatable.dart';

abstract class DeviceState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DeviceLoading extends DeviceState {}

class DeviceLoaded extends DeviceState {
  final List<String> devices;

  DeviceLoaded(this.devices);

  @override
  List<Object?> get props => [devices];
}

class DeviceError extends DeviceState {
  final String message;

  DeviceError(this.message);

  @override
  List<Object?> get props => [message];
}
