import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/pembacaan_sensor.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/status_badge.dart';

class RiwayatSensorPage extends StatefulWidget {
  const RiwayatSensorPage({super.key});

  @override
  State<RiwayatSensorPage> createState() =>
      _RiwayatSensorPageState();
}

class _RiwayatSensorPageState extends State<RiwayatSensorPage> {
  late Future<_RiwayatData> _futureData;

  @override
  void initState() {
    super.initState();
    _futureData = _loadData();
  }

  // Mengambil seluruh riwayat dan data terbaru dari SQLite
  Future<_RiwayatData> _loadData() async {
    final riwayat =
        await DatabaseHelper.instance.getAllSensors();

    final terbaru =
        await DatabaseHelper.instance.getLatestSensors();

    return _RiwayatData(
      riwayat: riwayat,
      terbaru: terbaru,
    );
  }

  // Memuat ulang data dari database
  Future<void> _refreshData() async {
    setState(() {
      _futureData = _loadData();
    });

    await _futureData;
  }

  // Mengubah kode jenis sensor menjadi nama yang mudah dibaca
  String _getSensorName(String jenisSensor) {
    switch (jenisSensor) {
      case 'ketinggian_air':
        return 'Ketinggian Air';

      case 'pergeseran_tanah':
        return 'Pergeseran Tanah';

      case 'curah_hujan':
        return 'Curah Hujan';

      default:
        return jenisSensor;
    }
  }

  // Menentukan satuan sensor
  String _getSensorUnit(String jenisSensor) {
    switch (jenisSensor) {
      case 'ketinggian_air':
        return 'cm';

      case 'pergeseran_tanah':
        return 'mm';

      case 'curah_hujan':
        return 'mm';

      default:
        return '';
    }
  }

  // Menentukan ikon sensor
  IconData _getSensorIcon(String jenisSensor) {
    switch (jenisSensor) {
      case 'ketinggian_air':
        return Icons.water;

      case 'pergeseran_tanah':
        return Icons.terrain;

      case 'curah_hujan':
        return Icons.cloud;

      default:
        return Icons.sensors;
    }
  }

  // Menentukan warna ikon sensor
  Color _getSensorColor(String jenisSensor) {
    switch (jenisSensor) {
      case 'ketinggian_air':
        return Colors.blue;

      case 'pergeseran_tanah':
        return Colors.orange;

      case 'curah_hujan':
        return Colors.teal;

      default:
        return Colors.grey;
    }
  }

  // Menentukan status berdasarkan nilai sensor
  StatusSiaga _getSensorStatus(
    String jenisSensor,
    double nilai,
  ) {
    switch (jenisSensor) {
      case 'ketinggian_air':
        if (nilai >= 150) {
          return StatusSiaga.siaga;
        }

        if (nilai >= 100) {
          return StatusSiaga.waspada;
        }

        return StatusSiaga.aman;

      case 'pergeseran_tanah':
        if (nilai >= 10) {
          return StatusSiaga.siaga;
        }

        if (nilai >= 5) {
          return StatusSiaga.waspada;
        }

        return StatusSiaga.aman;

      case 'curah_hujan':
        if (nilai >= 100) {
          return StatusSiaga.siaga;
        }

        if (nilai >= 50) {
          return StatusSiaga.waspada;
        }

        return StatusSiaga.aman;

      default:
        return StatusSiaga.aman;
    }
  }

  // Menentukan status siaga keseluruhan dari data terbaru
  StatusSiaga _getOverallStatus(
    List<PembacaanSensor> sensors,
  ) {
    StatusSiaga overall = StatusSiaga.aman;

    for (final sensor in sensors) {
      final status = _getSensorStatus(
        sensor.jenisSensor,
        sensor.nilai,
      );

      if (status == StatusSiaga.siaga) {
        return StatusSiaga.siaga;
      }

      if (status == StatusSiaga.waspada) {
        overall = StatusSiaga.waspada;
      }
    }

    return overall;
  }

  // Mengubah waktu ISO menjadi tampilan yang mudah dibaca
  String _formatDate(String waktu) {
    try {
      final date = DateTime.parse(waktu).toLocal();

      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year;

      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      final second = date.second.toString().padLeft(2, '0');

      return '$day/$month/$year $hour:$minute:$second';
    } catch (e) {
      return waktu;
    }
  }

  // Dialog untuk mengoreksi nilai sensor
  Future<void> _showEditDialog(
    PembacaanSensor sensor,
  ) async {
    final controller = TextEditingController(
      text: sensor.nilai.toString(),
    );

    final formKey = GlobalKey<FormState>();

    try {
      await showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Koreksi Pembacaan Sensor'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getSensorName(sensor.jenisSensor),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lokasi: ${sensor.lokasiPos}',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Nilai Baru',
                      suffixText:
                          _getSensorUnit(sensor.jenisSensor),
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
                ],
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
                onPressed: () async {
                  if (!formKey.currentState!.validate()) {
                    return;
                  }

                  final nilaiBaru = double.parse(
                    controller.text
                        .trim()
                        .replaceAll(',', '.'),
                  );

                  Navigator.pop(dialogContext);

                  try {
                    await DatabaseHelper.instance.updateSensor(
                      sensor.id!,
                      nilaiBaru,
                    );

                    if (!mounted) return;

                    await _refreshData();

                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Pembacaan sensor berhasil dikoreksi',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Gagal mengoreksi data: $e',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Simpan Perubahan'),
              ),
            ],
          );
        },
      );
    } finally {
      controller.dispose();
    }
  }

  // Konfirmasi sebelum menghapus data
  Future<bool> _confirmDelete(
    PembacaanSensor sensor,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Pembacaan?'),
          content: Text(
            'Apakah Anda yakin ingin menghapus pembacaan '
            '${_getSensorName(sensor.jenisSensor)} '
            'dengan nilai ${sensor.nilai} '
            '${_getSensorUnit(sensor.jenisSensor)}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  // Menghapus satu pembacaan berdasarkan ID
  Future<void> _deleteSensor(
    PembacaanSensor sensor,
  ) async {
    try {
      await DatabaseHelper.instance.deleteSensor(
        sensor.id!,
      );

      if (!mounted) return;

      await _refreshData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pembacaan sensor berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus data: $e'),
          backgroundColor: Colors.red,
        ),
      );

      await _refreshData();
    }
  }

  // Kartu informasi riwayat sensor
  Widget _buildSensorItem(
    PembacaanSensor sensor,
  ) {
    final status = _getSensorStatus(
      sensor.jenisSensor,
      sensor.nilai,
    );

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getSensorColor(
                    sensor.jenisSensor,
                  ).withValues(alpha: 0.12),
                  child: Icon(
                    _getSensorIcon(sensor.jenisSensor),
                    color: _getSensorColor(
                      sensor.jenisSensor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getSensorName(sensor.jenisSensor),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        sensor.lokasiPos,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Koreksi nilai',
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    _showEditDialog(sensor);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nilai Pembacaan',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${sensor.nilai} '
                      '${_getSensorUnit(sensor.jenisSensor)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                StatusBadge(status: status),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 15,
                  color: Colors.grey,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _formatDate(sensor.waktu),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                Text(
                  'ID: ${sensor.id}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Riwayat Sensor',
        actions: [
          FutureBuilder<_RiwayatData>(
            future: _futureData,
            builder: (context, snapshot) {
              if (!snapshot.hasData ||
                  snapshot.data!.terbaru.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Center(
                    child: Text(
                      'Belum ada data',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                    ),
                  ),
                );
              }

              final status = _getOverallStatus(
                snapshot.data!.terbaru,
              );

              return Padding(
                padding: const EdgeInsets.only(
                  right: 12,
                ),
                child: Center(
                  child: StatusBadge(
                    status: status,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<_RiwayatData>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Gagal mengambil riwayat sensor:\n'
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshData,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data;

          if (data == null || data.riwayat.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshData,
              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Belum Ada Riwayat Sensor',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Pembacaan sensor yang tersimpan '
                      'akan muncul di halaman ini.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: Column(
              children: [
                // Ringkasan riwayat
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(
                      alpha: 0.08,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.storage,
                        color: Colors.blue,
                        size: 30,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Pembacaan Tersimpan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${data.riwayat.length} catatan sensor',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${data.riwayat.length}',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),

                // Judul daftar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Seluruh Riwayat',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'Terbaru dahulu',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Daftar riwayat menggunakan ListView.builder
                Expanded(
                  child: ListView.builder(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    itemCount: data.riwayat.length,
                    itemBuilder: (context, index) {
                      final sensor = data.riwayat[index];

                      return Dismissible(
                        key: ValueKey(sensor.id),
                        direction:
                            DismissDirection.endToStart,
                        confirmDismiss: (direction) {
                          return _confirmDelete(sensor);
                        },
                        onDismissed: (direction) {
                          _deleteSensor(sensor);
                        },
                        background: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          padding: const EdgeInsets.only(
                            right: 24,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius:
                                BorderRadius.circular(16),
                          ),
                          alignment: Alignment.centerRight,
                          child: const Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 28,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Hapus',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        child: _buildSensorItem(sensor),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Model penampung hasil pengambilan data SQLite
class _RiwayatData {
  final List<PembacaanSensor> riwayat;
  final List<PembacaanSensor> terbaru;

  const _RiwayatData({
    required this.riwayat,
    required this.terbaru,
  });
}
