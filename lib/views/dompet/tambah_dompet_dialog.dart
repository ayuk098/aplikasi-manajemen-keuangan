import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/dompet_controller.dart';
import '../../controllers/currency_controller.dart';

class TambahDompetDialog extends StatefulWidget {
  const TambahDompetDialog({super.key});

  @override
  State<TambahDompetDialog> createState() => _TambahDompetDialogState();
}

class _TambahDompetDialogState extends State<TambahDompetDialog> {
  final namaC = TextEditingController();
  final saldoC = TextEditingController(text: "0");
  final _formKey = GlobalKey<FormState>();

  bool _isFormatting = false;

  @override
  void initState() {
    super.initState();
    saldoC.addListener(() {
      if (_isFormatting) return;
      _isFormatting = true;

      final currencyC = Provider.of<CurrencyController>(context, listen: false);
      final selected = currencyC.selectedCurrency;

      String raw = saldoC.text;

      if (selected == 'IDR') {
        raw = raw.replaceAll(RegExp(r'[^0-9]'), '');
        if (raw.isEmpty) {
          saldoC.text = '0';
          saldoC.selection = TextSelection.collapsed(
            offset: saldoC.text.length,
          );
          _isFormatting = false;
          return;
        }
        final number = double.tryParse(raw) ?? 0;
        final formatted = currencyC.formatCurrency(number);
        saldoC.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      } else {
        raw = raw.replaceAll(RegExp(r'[^0-9.]'), '');
        final parts = raw.split('.');
        if (parts.length > 2) {
          raw = parts.sublist(0, 2).join('.');
        }

        if (raw.isEmpty || raw == '.') {
          saldoC.text = '0';
          saldoC.selection = TextSelection.collapsed(
            offset: saldoC.text.length,
          );
          _isFormatting = false;
          return;
        }

        final number = double.tryParse(raw) ?? 0;
        final formatted = currencyC.formatCurrency(number);
        saldoC.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }

      _isFormatting = false;
    });
  }

  @override
  void dispose() {
    namaC.dispose();
    saldoC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dompetC = Provider.of<DompetController>(context);
    final currencyC = Provider.of<CurrencyController>(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Tambah Dompet Baru",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006C4E),
                ),
              ),
              const SizedBox(height: 20),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    //nama dompet
                    TextFormField(
                      controller: namaC,
                      decoration: InputDecoration(
                        labelText: "Nama Dompet",
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "Nama dompet tidak boleh kosong";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    //saldo awal
                    TextFormField(
                      controller: saldoC,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: "Saldo Awal",
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Saldo tidak boleh kosong';
                        }
                        
                        final cleaned = value.replaceAll(
                          RegExp(r'[^0-9.]'),
                          '',
                        );
                        if (cleaned.isEmpty) return 'Masukkan angka yang valid';
                        if (double.tryParse(cleaned) == null)
                          return 'Masukkan angka yang valid';
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Batal"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006C4E),
                      ),
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) return;
                        final selected = currencyC.selectedCurrency;
                        String rawText = saldoC.text;

                        double inputValueInSelectedCurrency = 0;

                        if (selected == 'IDR') {
                          final rawDigits = rawText.replaceAll(
                            RegExp(r'[^0-9]'),
                            '',
                          );
                          inputValueInSelectedCurrency =
                              double.tryParse(rawDigits) ?? 0;
                        } else {
                          final rawNum = rawText.replaceAll(
                            RegExp(r'[^0-9.]'),
                            '',
                          );
                          inputValueInSelectedCurrency =
                              double.tryParse(rawNum) ?? 0;
                        }

                        final rate = currencyC.selectedRate;
                        double saldoIDR = rate != 0
                            ? (inputValueInSelectedCurrency / rate)
                            : 0;

                        dompetC.tambahDompet(namaC.text.trim(), saldoIDR);

                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Dompet berhasil ditambahkan!"),
                            backgroundColor: Color(0xFF006C4E),
                          ),
                        );
                      },
                      child: const Text(
                        "Simpan",
                        style: TextStyle(color: Colors.white),
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
