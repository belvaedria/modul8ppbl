class Produk {
 final String id;
 final String nama;
 final int harga;
 const Produk({required this.id, required this.nama, required this.harga});
}

class ItemKeranjang {
 final Produk produk;
 int jumlah;
 ItemKeranjang({required this.produk, this.jumlah = 1});
 int get subtotal => produk.harga * jumlah;
}