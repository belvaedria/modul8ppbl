import 'package:flutter_bloc/flutter_bloc.dart';
import '../database/database_helper.dart';
import 'sensor_event.dart';
import 'sensor_state.dart';

class SensorBloc extends Bloc<SensorEvent, SensorState> {
  final DatabaseHelper databaseHelper;

  SensorBloc({DatabaseHelper? databaseHelper})
      : databaseHelper = databaseHelper ?? DatabaseHelper.instance,
        super(const SensorState()) {
    on<SensorDataRequested>(_onDataRequested);
    on<SensorReadingAdded>(_onReadingAdded);
    on<SensorReadingUpdated>(_onReadingUpdated);
    on<SensorReadingDeleted>(_onReadingDeleted);
  }

  // Mengambil data dari SQLite
  Future<void> _loadData(Emitter<SensorState> emit) async {
    final riwayat = await databaseHelper.getAllSensors();
    final terbaru = await databaseHelper.getLatestSensors();

    emit(
      state.copyWith(
        status: SensorStatus.success,
        riwayatSensor: riwayat,
        sensorTerbaru: terbaru,
      ),
    );
  }

  // Memuat data sensor
  Future<void> _onDataRequested(
    SensorDataRequested event,
    Emitter<SensorState> emit,
  ) async {
    emit(state.copyWith(status: SensorStatus.loading));

    try {
      await _loadData(emit);
    } catch (e) {
      emit(
        state.copyWith(
          status: SensorStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // Menambahkan pembacaan sensor
  Future<void> _onReadingAdded(
    SensorReadingAdded event,
    Emitter<SensorState> emit,
  ) async {
    try {
      await databaseHelper.insertSensor(event.sensor);
      await _loadData(emit);
    } catch (e) {
      emit(
        state.copyWith(
          status: SensorStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // Mengoreksi nilai pembacaan sensor
  Future<void> _onReadingUpdated(
    SensorReadingUpdated event,
    Emitter<SensorState> emit,
  ) async {
    try {
      await databaseHelper.updateSensor(
        event.id,
        event.nilai,
      );

      await _loadData(emit);
    } catch (e) {
      emit(
        state.copyWith(
          status: SensorStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // Menghapus pembacaan sensor
  Future<void> _onReadingDeleted(
    SensorReadingDeleted event,
    Emitter<SensorState> emit,
  ) async {
    try {
      await databaseHelper.deleteSensor(event.id);
      await _loadData(emit);
    } catch (e) {
      emit(
        state.copyWith(
          status: SensorStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
