import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/dompet_controller.dart';
import '../../controllers/auth_controller.dart'; // 1. Import AuthController

class TambahDompetDialog extends StatefulWidget {
  const TambahDompetDialog({super.key});

  @override
  State<TambahDompetDialog> createState() => _TambahDompetDialogState();
}

class _TambahDompetDialogState extends State<TambahDompetDialog> {
  final namaC = TextEditingController();
  final saldoC = TextEditingController(text: "0");
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    namaC.dispose();
    saldoC.dispose();
    super.dispose();
  }

  // 2. Helper Simbol Mata Uang
  String _getSymbol(String currencyCode) {
    switch (currencyCode) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'SGD':
        return 'S\$';
      case 'JPY':
        return '¥';
      case 'MYR':
        return 'RM';
      case 'AUD':
        return 'A\$';
      case 'IDR':
      default:
        return 'Rp';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dompetController = Provider.of<DompetController>(context);

    // 3. AMBIL DATA AUTH UNTUK SIMBOL & RATE
    final authC = Provider.of<AuthController>(context);
    final String currencySymbol = _getSymbol(authC.selectedCurrency);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF006C4E).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.add_circle_outline,
                      color: Color(0xFF006C4E),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Tambah Dompet Baru",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF006C4E),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              const Text(
                "Buat dompet baru untuk mengelola keuangan Anda",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),

              const SizedBox(height: 25),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: namaC,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        labelText: "Nama Dompet",
                        labelStyle: const TextStyle(color: Colors.grey),
                        hintText: "Contoh: Dompet Utama, Tabungan, dll.",
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF006C4E),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        prefixIcon: const Icon(
                          Icons.account_balance_wallet,
                          color: Colors.grey,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama dompet tidak boleh kosong';
                        }
                        if (value.length < 2) {
                          return 'Nama dompet minimal 2 karakter';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      controller: saldoC,
                      style: const TextStyle(fontSize: 16),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Saldo Awal",
                        labelStyle: const TextStyle(color: Colors.grey),
                        hintText: "0",
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        // 4. GUNAKAN SIMBOL DINAMIS
                        prefixText: "$currencySymbol ",
                        prefixStyle: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF006C4E),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        prefixIcon: const Icon(
                          Icons.attach_money,
                          color: Colors.grey,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Saldo tidak boleh kosong';
                        }
                        if (double.tryParse(value.replaceAll(',', '')) ==
                            null) {
                          return 'Masukkan angka yang valid';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: const Text(
                        "Batal",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // 5. LOGIKA KONVERSI SIMPAN
                          // Ambil input user (misal 100 USD)
                          double inputAmount =
                              double.tryParse(
                                saldoC.text.replaceAll(',', ''),
                              ) ??
                              0;

                          // Kembalikan ke IDR sebelum disimpan (100 / rate = IDR Asli)
                          double finalSaldoIDR =
                              inputAmount / authC.selectedRate;

                          dompetController.tambahDompet(
                            namaC.text.trim(),
                            finalSaldoIDR, // Simpan sebagai IDR
                          );
                          Navigator.pop(context);

                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Dompet berhasil ditambahkan!',
                              ),
                              backgroundColor: const Color(0xFF006C4E),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006C4E),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check, size: 20, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            "Simpan",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
