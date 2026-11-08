import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/produk.dart';

class KeranjangCubit extends Cubit<List<ItemKeranjang>> {
  KeranjangCubit() : super([]);
  void tambah(Produk produk) {
    final daftar = List<ItemKeranjang>.from(state);
    final index = daftar.indexWhere((item) => item.produk.id == produk.id);
    if (index >= 0) {
      daftar[index].jumlah++;
    } else {
      daftar.add(ItemKeranjang(produk: produk));
    }
    emit(daftar);
  }

  void kurangi(Produk produk) {
    final daftar = List<ItemKeranjang>.from(state);
    final index = daftar.indexWhere((item) => item.produk.id == produk.id);
    if (index < 0) return;
    if (daftar[index].jumlah > 1) {
      daftar[index].jumlah--;
    } else {
      daftar.removeAt(index);
    }
    emit(daftar);
  }

  void kosongkan() {
    emit([]);
  }
}
