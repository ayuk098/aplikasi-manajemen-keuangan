import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/kategori_controller.dart';
import '../../models/kategori_model.dart';

class EditKategoriDialog extends StatefulWidget {
  final KategoriModel kategori;

  const EditKategoriDialog({super.key, required this.kategori});

  @override
  State<EditKategoriDialog> createState() => _EditKategoriDialogState();
}

class _EditKategoriDialogState extends State<EditKategoriDialog> {
  late TextEditingController _namaC;
  final Color _primaryColor = const Color(0xFF00674F);

  @override
  void initState() {
    super.initState();
    _namaC = TextEditingController(text: widget.kategori.nama);
  }

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
            const Text(
              "Edit Kategori",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
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
                      
                      kategoriC.editKategori(
                        widget.kategori.id, 
                        _namaC.text, 
                        widget.kategori.tipe // Tetap gunakan tipe yang sama
                      );
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