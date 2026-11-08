
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/sensor_bloc.dart';
import '../blocs/sensor_event.dart';
import '../blocs/sensor_state.dart';
import '../models/pembacaan_sensor.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/sensor_card.dart';
import '../widgets/status_badge.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Timer? _timer;
  final Random _random = Random();

  int _simulationIndex = 0;

  final List<Map<String, dynamic>> _sensorTypes = [
    {
      'jenis': 'ketinggian_air',
      'nama': 'Ketinggian Air',
      'satuan': 'cm',
      'lokasi': 'Pos Sungai Citarum',
      'icon': Icons.water,
      'warna': Colors.blue,
    },
    {
      'jenis': 'pergeseran_tanah',
      'nama': 'Pergeseran Tanah',
      'satuan': 'mm',
      'lokasi': 'Pos Pemantauan Dago',
      'icon': Icons.terrain,
      'warna': Colors.orange,
    },
    {
      'jenis': 'curah_hujan',
      'nama': 'Curah Hujan',
      'satuan': 'mm',
      'lokasi': 'Pos Pemantauan Lembang',
      'icon': Icons.cloud,
      'warna': Colors.teal,
    },
  ];

  @override
  void initState() {
    super.initState();

    context.read<SensorBloc>().add(
          const SensorDataRequested(),
        );

    _initializeSimulation();

    _timer = Timer.periodic(
      const Duration(seconds: 10),
      (timer) {
        _simulateSensorReading();
      },
    );
  }

  // Membuat pembacaan awal untuk ketiga sensor
  void _initializeSimulation() {
    for (final sensor in _sensorTypes) {
      _addSimulatedReading(sensor);
    }
  }

  // Simulasi pembacaan sensor secara berkala
  void _simulateSensorReading() {
    final sensor = _sensorTypes[
        _simulationIndex % _sensorTypes.length];

    _addSimulatedReading(sensor);

    _simulationIndex++;
  }

  // Menghasilkan nilai sensor simulasi
  void _addSimulatedReading(Map<String, dynamic> sensor) {
    double nilai;

    switch (sensor['jenis']) {
      case 'ketinggian_air':
        nilai = 50 + _random.nextDouble() * 120;
        break;

      case 'pergeseran_tanah':
        nilai = _random.nextDouble() * 15;
        break;

      case 'curah_hujan':
        nilai = _random.nextDouble() * 150;
        break;

      default:
        nilai = 0;
    }

    final pembacaan = PembacaanSensor(
      jenisSensor: sensor['jenis'],
      nilai: double.parse(nilai.toStringAsFixed(1)),
      lokasiPos: sensor['lokasi'],
      waktu: DateTime.now().toIso8601String(),
    );

    context.read<SensorBloc>().add(
          SensorReadingAdded(pembacaan),
        );
  }

  // Mencari pembacaan terbaru berdasarkan jenis sensor
  PembacaanSensor? _getLatestReading(
    SensorState state,
    String jenisSensor,
  ) {
    for (final sensor in state.sensorTerbaru) {
      if (sensor.jenisSensor == jenisSensor) {
        return sensor;
      }
    }

    return null;
  }

  // Menentukan status berdasarkan nilai pembacaan
  StatusSiaga _getSensorStatus(
    String jenisSensor,
    double nilai,
  ) {
    switch (jenisSensor) {
      case 'ketinggian_air':
        if (nilai >= 150) return StatusSiaga.siaga;
        if (nilai >= 100) return StatusSiaga.waspada;
        return StatusSiaga.aman;

      case 'pergeseran_tanah':
        if (nilai >= 10) return StatusSiaga.siaga;
        if (nilai >= 5) return StatusSiaga.waspada;
        return StatusSiaga.aman;

      case 'curah_hujan':
        if (nilai >= 100) return StatusSiaga.siaga;
        if (nilai >= 50) return StatusSiaga.waspada;
        return StatusSiaga.aman;

      default:
        return StatusSiaga.aman;
    }
  }

  // Menampilkan form input manual
  Future<void> _showManualInputDialog() async {
    final formKey = GlobalKey<FormState>();

    final nilaiController = TextEditingController();
    final lokasiController = TextEditingController();

    String selectedSensor = 'ketinggian_air';

    try {
      await showDialog(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Input Pembacaan Sensor'),
                content: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          value: selectedSensor,
                          decoration: const InputDecoration(
                            labelText: 'Jenis Sensor',
                            prefixIcon: Icon(Icons.sensors),
                          ),
                          items: _sensorTypes.map((sensor) {
                            return DropdownMenuItem<String>(
                              value: sensor['jenis'],
                              child: Text(sensor['nama']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() {
                                selectedSensor = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: nilaiController,
                          keyboardType:
                              const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Nilai Pembacaan',
                            hintText: 'Contoh: 125.5',
                            prefixIcon: Icon(Icons.analytics),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Nilai wajib diisi';
                            }

                            final parsed = double.tryParse(
                              value.trim().replaceAll(',', '.'),
                            );

                            if (parsed == null ||
                                !parsed.isFinite ||
                                parsed < 0) {
                              return 'Masukkan angka valid dan tidak negatif';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: lokasiController,
                          decoration: const InputDecoration(
                            labelText: 'Lokasi Pos',
                            hintText: 'Contoh: Pos Sungai Citarum',
                            prefixIcon: Icon(Icons.location_on),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Lokasi wajib diisi';
                            }

                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    child: const Text('Batal'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (!formKey.currentState!.validate()) {
                        return;
                      }

                      final sensor = PembacaanSensor(
                        jenisSensor: selectedSensor,
                        nilai: double.parse(
                          nilaiController.text
                              .trim()
                              .replaceAll(',', '.'),
                        ),
                        lokasiPos: lokasiController.text.trim(),
                        waktu: DateTime.now().toIso8601String(),
                      );

                      Navigator.pop(dialogContext);

                      this.context.read<SensorBloc>().add(
                            SensorReadingAdded(sensor),
                          );

                      ScaffoldMessenger.of(this.context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Pembacaan sensor berhasil disimpan',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: const Text('Simpan'),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      nilaiController.dispose();
      lokasiController.dispose();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Dashboard Pemantauan',
        actions: [
          IconButton(
            tooltip: 'Riwayat Sensor',
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.pushNamed(context, '/riwayat');
            },
          ),
        ],
      ),
      body: BlocBuilder<SensorBloc, SensorState>(
        builder: (context, state) {
          if (state.status == SensorStatus.loading &&
              state.sensorTerbaru.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.status == SensorStatus.failure &&
              state.sensorTerbaru.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.errorMessage ??
                          'Gagal memuat data sensor',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<SensorBloc>().add(
                              const SensorDataRequested(),
                            );
                      },
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<SensorBloc>().add(
                    const SensorDataRequested(),
                  );

              await context
                  .read<SensorBloc>()
                  .stream
                  .firstWhere(
                    (state) =>
                        state.status != SensorStatus.loading,
                  );
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header Dashboard
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1565C0),
                        Color(0xFF00838F),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.shield,
                        color: Colors.white,
                        size: 36,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Pusat Pemantauan Bencana',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Sistem peringatan dini berbasis AIoT '
                        'untuk mendukung pemantauan kondisi '
                        'lingkungan secara berkala.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Judul Sensor
                const Row(
                  children: [
                    Icon(
                      Icons.sensors,
                      color: Color(0xFF1565C0),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Pemantauan Sensor',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Daftar kartu sensor
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount =
                        constraints.maxWidth >= 650 ? 3 : 2;

                    return GridView.builder(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      itemCount: _sensorTypes.length,
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio:
                            crossAxisCount == 3 ? 0.85 : 0.95,
                      ),
                      itemBuilder: (context, index) {
                        final sensor = _sensorTypes[index];

                        final latest = _getLatestReading(
                          state,
                          sensor['jenis'],
                        );

                        return SensorCard(
                          jenisSensor: sensor['nama'],
                          lokasi: latest?.lokasiPos ??
                              sensor['lokasi'],
                          nilai: latest?.nilai ?? 0,
                          satuan: sensor['satuan'],
                          icon: sensor['icon'],
                          warna: sensor['warna'],
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Status sensor
                const Text(
                  'Status Kondisi Sensor',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                ..._sensorTypes.map((sensor) {
                  final latest = _getLatestReading(
                    state,
                    sensor['jenis'],
                  );

                  final status = latest == null
                      ? null
                      : _getSensorStatus(
                          sensor['jenis'],
                          latest.nilai,
                        );

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: Icon(
                        sensor['icon'],
                        color: sensor['warna'],
                      ),
                      title: Text(sensor['nama']),
                      subtitle: Text(
                        latest == null
                            ? 'Belum ada pembacaan'
                            : '${latest.nilai} ${sensor['satuan']}',
                      ),
                      trailing: status == null
                          ? const Text('Menunggu data')
                          : StatusBadge(status: status),
                    ),
                  );
                }),

                const SizedBox(height: 16),

                // Informasi simulasi
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.autorenew,
                          color: Colors.blue,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Simulasi Sensor Aktif',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Pembacaan otomatis setiap 10 detik '
                                'dan disimpan ke SQLite.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Tombol input manual
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _showManualInputDialog,
                    icon: const Icon(Icons.add),
                    label: const Text(
                      'Input Pembacaan Sensor Manual',
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Tombol riwayat
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/riwayat',
                      );
                    },
                    icon: const Icon(Icons.history),
                    label: const Text('Lihat Riwayat Sensor'),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
