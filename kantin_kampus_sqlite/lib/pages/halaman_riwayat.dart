import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/pesanan.dart';

class HalamanRiwayat extends StatefulWidget {
  const HalamanRiwayat({super.key});
  @override
  State<HalamanRiwayat> createState() => _HalamanRiwayatState();
}

class _HalamanRiwayatState extends State<HalamanRiwayat> {
  late Future<List<Pesanan>> _daftarPesanan;
  @override
  void initState() {
    super.initState();
    _muatUlangData();
  }

  void _muatUlangData() {
    setState(() {
      _daftarPesanan = DatabaseHelper.instance.ambilSemuaPesanan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pesanan')),
      body: FutureBuilder<List<Pesanan>>(
        future: _daftarPesanan,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final daftar = snapshot.data ?? [];
          if (daftar.isEmpty) {
            return const Center(child: Text('Belum ada riwayat pesanan.'));
          }
          return ListView.builder(
            itemCount: daftar.length,
            itemBuilder: (context, index) {
              final pesanan = daftar[index];
              return Dismissible(
                key: ValueKey(pesanan.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) async {
                  await DatabaseHelper.instance.hapusPesanan(pesanan.id!);
                  _muatUlangData();
                },
                child: ListTile(
                  title: Text(pesanan.ringkasanItem),
                  subtitle: Text(
                    '${pesanan.totalItem} item • ${pesanan.tanggal}',
                  ),
                  trailing: Text('Rp${pesanan.totalHarga}'),
                  onTap: () async {
                    final controller = TextEditingController(
                      text: pesanan.totalItem.toString(),
                    );
                    final jumlahBaru = await showDialog<int>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Ubah Jumlah Item'),
                        content: TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(
                              context,
                              int.tryParse(controller.text),
                            ),
                            child: const Text('Simpan'),
                          ),
                        ],
                      ),
                    );
                    if (jumlahBaru != null) {
                      await DatabaseHelper.instance.ubahPesanan(
                        Pesanan(
                          id: pesanan.id,
                          ringkasanItem: pesanan.ringkasanItem,
                          totalItem: jumlahBaru,
                          totalHarga: pesanan.totalHarga,
                          tanggal: pesanan.tanggal,
                        ),
                      );
                      _muatUlangData();
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
