import 'package:equatable/equatable.dart';
import '../models/pembacaan_sensor.dart';

enum SensorStatus {
  initial,
  loading,
  success,
  failure,
}

class SensorState extends Equatable {
  final SensorStatus status;
  final List<PembacaanSensor> riwayatSensor;
  final List<PembacaanSensor> sensorTerbaru;
  final String? errorMessage;

  const SensorState({
    this.status = SensorStatus.initial,
    this.riwayatSensor = const [],
    this.sensorTerbaru = const [],
    this.errorMessage,
  });

  SensorState copyWith({
    SensorStatus? status,
    List<PembacaanSensor>? riwayatSensor,
    List<PembacaanSensor>? sensorTerbaru,
    String? errorMessage,
  }) {
    return SensorState(
      status: status ?? this.status,
      riwayatSensor: riwayatSensor ?? this.riwayatSensor,
      sensorTerbaru: sensorTerbaru ?? this.sensorTerbaru,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        riwayatSensor,
        sensorTerbaru,
        errorMessage,
      ];
}