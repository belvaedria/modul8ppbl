import 'package:flutter/material.dart';

import '../models/produk.dart';

class ProductCard extends StatelessWidget {
  final Produk produk;
  final VoidCallback onTambah;
  const ProductCard({super.key, required this.produk, required this.onTambah});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        title: Text(produk.nama, style: theme.textTheme.titleMedium),
        subtitle: Text(
          'Rp${produk.harga}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.add_circle, color: theme.colorScheme.primary),
          onPressed: onTambah,
        ),
      ),
    );
  }
}
