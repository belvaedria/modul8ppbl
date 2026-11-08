import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/keranjang_cubit.dart';
import '../models/produk.dart';
import '../widgets/produk_card.dart';
import '../widgets/theme_toggle_button.dart';

class HalamanProduk extends StatelessWidget {
  const HalamanProduk({super.key});
  static const daftarProduk = [
    Produk(id: 'p1', nama: 'Nasi Goreng', harga: 15000),
    Produk(id: 'p2', nama: 'Es Teh Manis', harga: 5000),
    Produk(id: 'p3', nama: 'Ayam Geprek', harga: 18000),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produk'),
        actions: const [ThemeToggleButton()],
      ),
      body: ListView.builder(
        itemCount: daftarProduk.length,
        itemBuilder: (context, index) {
          final produk = daftarProduk[index];
          return ProductCard(
            produk: produk,
            onTambah: () => context.read<KeranjangCubit>().tambah(produk),
          );
        },
      ),
    );
  }
}
