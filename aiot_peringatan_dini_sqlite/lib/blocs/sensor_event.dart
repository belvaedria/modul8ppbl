import 'package:equatable/equatable.dart';
import '../models/pembacaan_sensor.dart';

abstract class SensorEvent extends Equatable {
  const SensorEvent();

  @override
  List<Object?> get props => [];
}

// Memuat data sensor dari database
class SensorDataRequested extends SensorEvent {
  const SensorDataRequested();
}

// Menambahkan pembacaan sensor
class SensorReadingAdded extends SensorEvent {
  final PembacaanSensor sensor;

  const SensorReadingAdded(this.sensor);

  @override
  List<Object?> get props => [sensor];
}

// Mengoreksi nilai pembacaan sensor
class SensorReadingUpdated extends SensorEvent {
  final int id;
  final double nilai;

  const SensorReadingUpdated({
    required this.id,
    required this.nilai,
  });

  @override
  List<Object?> get props => [id, nilai];
}

// Menghapus pembacaan sensor
class SensorReadingDeleted extends SensorEvent {
  final int id;

  const SensorReadingDeleted(this.id);

  @override
  List<Object?> get props => [id];
}