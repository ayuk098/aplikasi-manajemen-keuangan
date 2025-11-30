import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/kategori_controller.dart';

class TambahKategoriDialog extends StatefulWidget {
  final String selectedTipe;

  const TambahKategoriDialog({
    super.key,
    required this.selectedTipe,
  });

  @override
  State<TambahKategoriDialog> createState() => _TambahKategoriDialogState();
}

class _TambahKategoriDialogState extends State<TambahKategoriDialog> {
  final _namaC = TextEditingController();
  final Color _primaryColor = const Color(0xFF00674F);

  @override
  Widget build(BuildContext context) {
    final kategoriC = Provider.of<KategoriController>(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.add, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  "Tambah Kategori ${widget.selectedTipe == 'pemasukan' ? 'Pemasukan' : 'Pengeluaran'}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.selectedTipe == "pemasukan" 
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.selectedTipe == "pemasukan" 
                      ? Colors.green 
                      : Colors.red,
                  width: 1,
                ),
              ),
              child: Text(
                "Tipe: ${widget.selectedTipe == 'pemasukan' ? 'Pemasukan' : 'Pengeluaran'}",
                style: TextStyle(
                  color: widget.selectedTipe == "pemasukan" 
                      ? Colors.green 
                      : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              "Nama Kategori",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _namaC,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "Masukkan nama kategori",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Batal"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_namaC.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Nama kategori harus diisi")),
                        );
                        return;
                      }
                      
                      kategoriC.tambahKategori(_namaC.text, widget.selectedTipe);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Simpan"),
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
  void dispose() {
    _namaC.dispose();
    super.dispose();
  }
}