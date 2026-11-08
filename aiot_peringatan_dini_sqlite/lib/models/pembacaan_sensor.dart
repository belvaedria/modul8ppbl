
class PembacaanSensor {
  final int? id;
  final String jenisSensor;
  final double nilai;
  final String lokasiPos;
  final String waktu;

  PembacaanSensor({
    this.id,
    required this.jenisSensor,
    required this.nilai,
    required this.lokasiPos,
    required this.waktu,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'jenis_sensor': jenisSensor,
      'nilai': nilai,
      'lokasi_pos': lokasiPos,
      'waktu': waktu,
    };
  }

  factory PembacaanSensor.fromMap(Map<String, dynamic> map) {
    return PembacaanSensor(
      id: map['id'] as int?,
      jenisSensor: map['jenis_sensor'] as String,
      nilai: (map['nilai'] as num).toDouble(),
      lokasiPos: map['lokasi_pos'] as String,
      waktu: map['waktu'] as String,
    );
  }
}
