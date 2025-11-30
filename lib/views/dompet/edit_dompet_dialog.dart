import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/dompet_controller.dart';
import '../../controllers/auth_controller.dart'; // 1. Import AuthController
import '../../models/dompet_model.dart';

class EditDompetDialog extends StatefulWidget {
  final DompetModel dompet;

  const EditDompetDialog({super.key, required this.dompet});

  @override
  State<EditDompetDialog> createState() => _EditDompetDialogState();
}

class _EditDompetDialogState extends State<EditDompetDialog> {
  late TextEditingController namaC;
  late TextEditingController saldoC;
  final _formKey = GlobalKey<FormState>();

  // Penanda inisialisasi agar data tidak tertimpa saat rebuild
  bool _isInit = true;

  @override
  void initState() {
    super.initState();
    namaC = TextEditingController(text: widget.dompet.nama);
    // Saldo diinisialisasi kosong dulu, nanti diisi di didChangeDependencies
    saldoC = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final authC = Provider.of<AuthController>(context, listen: false);

      // 2. LOGIKA KONVERSI TAMPILAN
      // Saldo DB (IDR) * Rate = Saldo Tampil
      double convertedSaldo = widget.dompet.saldoAwal * authC.selectedRate;

      // Format: Hapus desimal .00 jika bulat
      saldoC.text = convertedSaldo % 1 == 0
          ? convertedSaldo.toInt().toString()
          : convertedSaldo.toStringAsFixed(2);

      _isInit = false;
    }
  }

  @override
  void dispose() {
    namaC.dispose();
    saldoC.dispose();
    super.dispose();
  }

  // Helper Simbol
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

    // 3. AMBIL DATA AUTH
    final authC = Provider.of<AuthController>(context);
    final String currencySymbol = _getSymbol(authC.selectedCurrency);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
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
                    Icons.account_balance_wallet,
                    color: Color(0xFF006C4E),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "Edit Dompet",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF006C4E),
                    ),
                  ),
                ),
              ],
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF006C4E)),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama dompet tidak boleh kosong';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  TextFormField(
                    controller: saldoC,
                    style: const TextStyle(fontSize: 16),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: "Saldo Awal",
                      labelStyle: const TextStyle(color: Colors.grey),
                      // 4. GUNAKAN SIMBOL DINAMIS
                      prefixText: "$currencySymbol ",
                      prefixStyle: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF006C4E)),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Saldo tidak boleh kosong';
                      }
                      // Remove comma for validation
                      if (double.tryParse(value.replaceAll(',', '')) == null) {
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
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // 5. LOGIKA KONVERSI SIMPAN (Write)
                        // Ambil input user (USD/EUR/dll)
                        double inputAmount = double.parse(
                          saldoC.text.replaceAll(',', ''),
                        );

                        // Kembalikan ke IDR sebelum simpan ke DB
                        // Input / Rate = IDR
                        double finalSaldoIDR = inputAmount / authC.selectedRate;

                        dompetController.editDompet(
                          widget.dompet.id,
                          namaC.text.trim(),
                          finalSaldoIDR, // Kirim IDR ke controller
                        );
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Dompet berhasil diperbarui!'),
                            backgroundColor: const Color(0xFF006C4E),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
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
                    child: const Text(
                      "Update",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
