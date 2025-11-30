import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../../models/kategori_model.dart';
import '../../controllers/transaksi_controller.dart';
import '../../controllers/dompet_controller.dart';
import '../../controllers/currency_controller.dart';

class TambahTransaksiPage extends StatefulWidget {
  const TambahTransaksiPage({super.key});

  @override
  State<TambahTransaksiPage> createState() => _TambahTransaksiPageState();
}

class _TambahTransaksiPageState extends State<TambahTransaksiPage> {
  final _deskripsiC = TextEditingController();
  final _jumlahC = TextEditingController();
  DateTime _tanggal = DateTime.now();

  String _tipe = "pemasukan";
  String? _kategoriId;
  String? _dompetId;

  final _formKey = GlobalKey<FormState>();

  final Color primary = const Color(0xFF006C4E);
  final Color accent = const Color(0xFF018062);
  final Color borderColor = const Color(0xFFE0E0E0);

  @override
  void dispose() {
    _deskripsiC.dispose();
    _jumlahC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transaksiC = Provider.of<TransaksiController>(context);
    final dompetC = Provider.of<DompetController>(context);
    final currencyC = Provider.of<CurrencyController>(context);

    final simbol = currencyC.formatCurrency(1).replaceAll(RegExp(r'[0-9., ]'), "");

    final kategoriBox = Hive.box<KategoriModel>('kategori');
    final kategoriFiltered = kategoriBox.values
        .where((k) => k.userId == transaksiC.currentUserId && k.tipe == _tipe)
        .toList();

    final semuaDompetUser = dompetC.semuaDompet;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text("Tambah transaksi"),
      ),
      body: transaksiC.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Column(
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
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label("Deskripsi"),
                          _inputField(
                            controller: _deskripsiC,
                            hint: "Masukkan deskripsi",
                            validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                          ),
                          const SizedBox(height: 20),

                          _label("Jumlah"),
                          _inputField(
                            controller: _jumlahC,
                            hint: "0",
                            isNumber: true,
                            currencySymbol: simbol,
                            validator: (v) {
                              if (v!.isEmpty) return "Wajib diisi";
                              if (double.tryParse(v.replaceAll(',', '')) == null) {
                                return "Input angka tidak valid";
                              }
                              if (double.parse(v.replaceAll(',', '')) <= 0) {
                                return "Jumlah harus > 0";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          _label("Tanggal"),
                          GestureDetector(
                            onTap: () async {
                              final pilih = await showDatePicker(
                                context: context,
                                initialDate: _tanggal,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );
                              if (pilih != null) {
                                setState(() => _tanggal = pilih);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: borderColor),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 20, color: primary),
                                  const SizedBox(width: 10),
                                  Text(
                                    DateFormat("dd/MM/yyyy").format(_tanggal),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const Spacer(),
                                  Text(
                                    DateFormat('EEEE', 'id_ID').format(_tanggal),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          _label("Kategori"),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(color: borderColor),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _kategoriId,
                                hint: const Text("Pilih kategori"),
                                isExpanded: true,
                                items: kategoriFiltered
                                    .map(
                                      (k) => DropdownMenuItem(
                                        value: k.id,
                                        child: Text(k.nama),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) => setState(() => _kategoriId = v),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          _label("Pilih dompet"),
                          if (semuaDompetUser.isEmpty)
                            _emptyDompetWarning()
                          else
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: borderColor),
                              ),
                              child: Column(
                                children: semuaDompetUser.map((d) {
                                  double convertedSaldo = currencyC.convertFromIdr(d.saldoAwal);

                                  return RadioListTile<String>(
                                    value: d.id,
                                    groupValue: _dompetId,
                                    activeColor: primary,
                                    title: Text(
                                      d.nama,
                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    subtitle: Text(
                                      currencyC.formatCurrency(convertedSaldo),
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    onChanged: (v) => setState(() => _dompetId = v),
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),


                  Container(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _simpan,
                        child: const Text(
                          "Simpan transaksi",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    if (_kategoriId == null || _dompetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih kategori dan dompet dulu")),
      );
      return;
    }

    final transaksiC = Provider.of<TransaksiController>(context, listen: false);
    final currencyC = Provider.of<CurrencyController>(context, listen: false);

    double inputAmount = double.parse(_jumlahC.text.replaceAll(',', ''));

    double finalAmountIDR = currencyC.convertFromIdr(inputAmount);

    await transaksiC.simpanTransaksi(
      deskripsi: _deskripsiC.text,
      jumlahText: finalAmountIDR.toString(),
      tanggal: _tanggal,
      tipe: _tipe,
      kategoriId: _kategoriId!,
      dompetId: _dompetId!,
    );

    if (mounted) Navigator.pop(context);
  }

  Widget _tabButton(String label, String value) {
    final active = _tipe == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _tipe = value;
            _kategoriId = null;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? primary : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          t,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      );

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    bool isNumber = false,
    String? currencySymbol,
    required String? Function(String?) validator,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          if (isNumber && currencySymbol != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                currencySymbol,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
          Expanded(
            child: TextFormField(
              controller: controller,
              validator: validator,
              keyboardType: isNumber ? TextInputType.number : TextInputType.text,
              decoration: InputDecoration(
                hintText: isNumber ? "0" : hint,
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyDompetWarning() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(10),
        color: Colors.orange[50],
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.orange[800]),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Belum ada dompet. Silakan buat dompet terlebih dahulu.",
              style: TextStyle(color: Colors.orange[800]),
            ),
          ),
        ],
      ),
    );
  }
}
