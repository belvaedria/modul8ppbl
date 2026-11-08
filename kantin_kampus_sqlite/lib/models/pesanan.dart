class Pesanan {
  final int? id;
  final String ringkasanItem;
  final int totalItem;
  final int totalHarga;
  final String tanggal;
  Pesanan({
    this.id,
    required this.ringkasanItem,
    required this.totalItem,
    required this.totalHarga,
    required this.tanggal,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ringkasan_item': ringkasanItem,
      'total_item': totalItem,
      'total_harga': totalHarga,
      'tanggal': tanggal,
    };
  }

  factory Pesanan.fromMap(Map<String, dynamic> map) {
    return Pesanan(
      id: map['id'] as int?,
      ringkasanItem: map['ringkasan_item'] as String,
      totalItem: map['total_item'] as int,
      totalHarga: map['total_harga'] as int,
      tanggal: map['tanggal'] as String,
    );
  }
}
