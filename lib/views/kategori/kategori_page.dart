import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/kategori_controller.dart';
import 'edit_kategori_dialog.dart';
import 'tambah_kategori_page.dart';

class KategoriPage extends StatefulWidget {
  const KategoriPage({super.key});

  @override
  State<KategoriPage> createState() => _KategoriPageState();
}

class _KategoriPageState extends State<KategoriPage> {
  String _selectedTipe = "pengeluaran";

  final Color primary = const Color(0xFF006C4E);
  final Color accent = const Color(0xFF018062);
  final Color borderColor = const Color(0xFFE0E0E0);

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<KategoriController>(
        context,
        listen: false,
      ).initDefaultKategori();
    });
  }

  @override
  Widget build(BuildContext context) {
    final kategoriC = Provider.of<KategoriController>(context);
    final filteredKategori = kategoriC.semuaKategori
        .where((k) => k.tipe == _selectedTipe)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Kategori",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => TambahKategoriDialog(selectedTipe: _selectedTipe),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _tabButton("Pemasukan", "pemasukan"),
                  _tabButton("Pengeluaran", "pengeluaran"),
                ],
              ),
            ),
          ),

          Expanded(
            child: filteredKategori.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.category, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "Belum ada kategori",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: filteredKategori.length,
                    itemBuilder: (context, index) {
                      final k = filteredKategori[index];

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getIconForKategori(k.nama),
                              color: primary,
                              size: 22,
                            ),
                          ),
                          title: Text(
                            k.nama,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) =>
                                        EditKategoriDialog(kategori: k),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                onPressed: () async {
                                  final confirm = await showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text("Hapus Kategori"),
                                      content: Text(
                                        "Yakin mau hapus kategori '${k.nama}'?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: const Text("Batal"),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          child: const Text("Hapus"),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    kategoriC.hapusKategori(k.id);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton(String label, String value) {
    final bool isActive = _selectedTipe == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTipe = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? primary : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForKategori(String nama) {
    final lower = nama.toLowerCase();
    if (lower.contains('gaji')) return Icons.payments;
    if (lower.contains('bonus')) return Icons.card_giftcard;
    if (lower.contains('proyek')) return Icons.work;
    if (lower.contains('usaha')) return Icons.storefront;
    if (lower.contains('jualan')) return Icons.shopping_bag;
    if (lower.contains('invest') || lower.contains('dividen'))
      return Icons.trending_up;
    if (lower.contains('hadiah')) return Icons.emoji_events;
    if (lower.contains('makan') || lower.contains('kuliner'))
      return Icons.restaurant_menu;
    if (lower.contains('minum') || lower.contains('kopi'))
      return Icons.local_cafe;
    if (lower.contains('snack') || lower.contains('cemilan'))
      return Icons.icecream;
    if (lower.contains('belanja') || lower.contains('shopping'))
      return Icons.shopping_cart;
    if (lower.contains('sembako') || lower.contains('kebutuhan'))
      return Icons.local_grocery_store;

    if (lower.contains('transport') || lower.contains('angkut'))
      return Icons.directions_car;
    if (lower.contains('bensin') || lower.contains('fuel'))
      return Icons.local_gas_station;
    if (lower.contains('ojek') ||
        lower.contains('gojek') ||
        lower.contains('grab'))
      return Icons.motorcycle;
    if (lower.contains('parkir')) return Icons.local_parking;
    if (lower.contains('kesehatan')) return Icons.local_hospital;
    if (lower.contains('obat')) return Icons.medical_services;

    if (lower.contains('pendidikan') ||
        lower.contains('kuliah') ||
        lower.contains('sekolah'))
      return Icons.school;
    if (lower.contains('buku')) return Icons.book;
    if (lower.contains('listrik')) return Icons.bolt;
    if (lower.contains('air')) return Icons.water_drop;
    if (lower.contains('wifi') || lower.contains('internet')) return Icons.wifi;
    if (lower.contains('sewa') || lower.contains('kontrakan'))
      return Icons.home_work;

    if (lower.contains('hiburan')) return Icons.movie;
    if (lower.contains('game')) return Icons.sports_esports;
    if (lower.contains('musik') || lower.contains('music'))
      return Icons.music_note;
    if (lower.contains('nonton') || lower.contains('bioskop'))
      return Icons.local_movies;
    if (lower.contains('tabung')) return Icons.savings;
    if (lower.contains('utang') || lower.contains('pinjam'))
      return Icons.request_quote;
    if (lower.contains('asuransi')) return Icons.verified_user;
    if (lower.contains('donasi') || lower.contains('amal'))
      return Icons.volunteer_activism;
    if (lower.contains('kado')) return Icons.card_giftcard;
    if (lower.contains('hobi')) return Icons.palette;
    if (lower.contains('olahraga')) return Icons.fitness_center;
    if (lower.contains('servis')) return Icons.build;
    if (lower.contains('sparepart')) return Icons.car_repair;
    if (lower.contains('skincare') ||
        lower.contains('perawatan') ||
        lower.contains('kosmetik'))
      return Icons.brush;

    if (lower.contains('fashion') || lower.contains('kostum'))
      return Icons.checkroom;

    return Icons.category;
  }
}
