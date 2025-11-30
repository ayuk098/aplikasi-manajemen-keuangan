import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../../controllers/transaksi_controller.dart';
import '../../controllers/auth_controller.dart'; // Import AuthController kamu
import '../../models/transaksi_model.dart';
import '../../models/kategori_model.dart';
import '../../models/dompet_model.dart';

class EditTransaksiPage extends StatefulWidget {
  final TransaksiModel transaksi;
  const EditTransaksiPage({super.key, required this.transaksi});

  @override
  State<EditTransaksiPage> createState() => _EditTransaksiPageState();
}

class _EditTransaksiPageState extends State<EditTransaksiPage> {
  late TextEditingController _deskripsiC;
  late TextEditingController _jumlahC;
  late String _tipe;
  late String? _kategoriId;
  late String? _dompetId;
  late DateTime _tanggal;

  final _formKey = GlobalKey<FormState>();

  final Color primary = const Color(0xFF006C4E);
  final Color accent = const Color(0xFF018062);
  final Color borderColor = const Color(0xFFE0E0E0);

  bool _isLoading = false;
  bool _isInit = true;

  @override
  void initState() {
    super.initState();
    _deskripsiC = TextEditingController(text: widget.transaksi.deskripsi);
    // _jumlahC diisi nanti di didChangeDependencies agar bisa akses AuthController
    _jumlahC = TextEditingController();
    _tipe = widget.transaksi.tipe;
    _kategoriId = widget.transaksi.kategoriId;
    _dompetId = widget.transaksi.dompetId;
    _tanggal = widget.transaksi.tanggal;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      // Akses AuthController tanpa mengubah file AuthController
      final authC = Provider.of<AuthController>(context, listen: false);

      // LOGIKA KONVERSI TAMPILAN:
      // Ambil IDR dari DB -> Kalikan dengan selectedRate milik AuthController
      double convertedValue =
          widget.transaksi.jumlah *
          authC.selectedRate; // <--- PAKE selectedRate

      // Format tampilan (hilangkan .0 jika bulat)
      _jumlahC.text = convertedValue % 1 == 0
          ? convertedValue.toInt().toString()
          : convertedValue.toStringAsFixed(2);

      _isInit = false;
    }
  }

  @override
  void dispose() {
    _deskripsiC.dispose();
    _jumlahC.dispose();
    super.dispose();
  }

  // Helper lokal untuk simbol (karena _symbolForCurrency di AuthController itu private)
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
    final transaksiC = Provider.of<TransaksiController>(context);
    final authC = Provider.of<AuthController>(context);

    // Ambil variable langsung dari AuthController kamu
    final double currentRate = authC.selectedRate; // <--- PAKE selectedRate
    final String currencyCode =
        authC.selectedCurrency; // <--- PAKE selectedCurrency
    final String currencySymbol = _getSymbol(currencyCode);

    final sessionBox = Hive.box('session');
    final currentUserId = sessionBox.get('userId');

    final kategoriBox = Hive.box<KategoriModel>('kategori');
    final kategoriFiltered = kategoriBox.values
        .where((e) => e.userId == currentUserId && e.tipe == _tipe)
        .toList();

    final dompetBox = Hive.box<DompetModel>('dompet');
    final dompetFiltered = dompetBox.values
        .where((e) => e.userId == currentUserId)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text("Edit transaksi"),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFF006C4E)),
              ),
            )
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  // TIPE SELEKTOR
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
                    child: _tipeSelector(),
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
                            hint: "Masukkan deskripsi",
                            controller: _deskripsiC,
                            validator: (v) =>
                                v!.isEmpty ? "Deskripsi wajib diisi" : null,
                          ),
                          const SizedBox(height: 20),

                          _label("Jumlah"),
                          // Input Field dengan Simbol Dinamis
                          _inputField(
                            hint: "0",
                            controller: _jumlahC,
                            isNumber: true,
                            currencySymbol: currencySymbol,
                            validator: (v) {
                              if (v!.isEmpty) return "Jumlah wajib diisi";
                              if (double.tryParse(v.replaceAll(',', '')) ==
                                  null) {
                                return "Masukkan angka yang valid";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          _label("Tanggal"),
                          GestureDetector(
                            onTap: () => _selectDate(context),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: borderColor),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    DateFormat("dd/MM/yyyy").format(_tanggal),
                                  ),
                                  const Spacer(),
                                  Text(
                                    DateFormat(
                                      'EEEE',
                                      'id_ID',
                                    ).format(_tanggal),
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          _label("Pilih kategori"),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: borderColor),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _kategoriId,
                                isExpanded: true,
                                hint: const Text("Pilih kategori"),
                                items: kategoriFiltered.map((k) {
                                  return DropdownMenuItem(
                                    value: k.id,
                                    child: Text(k.nama),
                                  );
                                }).toList(),
                                onChanged: (v) =>
                                    setState(() => _kategoriId = v),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          _label("Pilih dompet"),
                          if (dompetFiltered.isEmpty)
                            // Tampilan peringatan jika dompet kosong
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.orange),
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.orange[50],
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.warning,
                                    color: Colors.orange[800],
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      "Belum ada dompet. Tambahkan dulu.",
                                      style: TextStyle(color: Colors.orange),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            // LIST DOMPET DENGAN SALDO TERKONVERSI
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: borderColor),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: dompetFiltered.map((d) {
                                  // HITUNG KONVERSI SALDO DOMPET
                                  // Saldo asli (IDR) * selectedRate = Saldo Tampil
                                  double convertedSaldo =
                                      d.saldoAwal * currentRate;

                                  return RadioListTile<String>(
                                    value: d.id,
                                    groupValue: _dompetId,
                                    activeColor: primary,
                                    title: Text(d.nama),
                                    subtitle: Text(
                                      // Tampilkan Simbol + Saldo Terkonversi
                                      "$currencySymbol ${NumberFormat('#,##0.##').format(convertedSaldo)}",
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    onChanged: (v) =>
                                        setState(() => _dompetId = v),
                                  );
                                }).toList(),
                              ),
                            ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),

                  // TOMBOL UPDATE
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _updateTransaksi,
                        child: const Text(
                          "Update transaksi",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final pilih = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pilih != null) setState(() => _tanggal = pilih);
  }

  Future<void> _updateTransaksi() async {
    if (!_formKey.currentState!.validate()) return;
    if (_kategoriId == null) return _error("Pilih kategori terlebih dahulu");
    if (_dompetId == null) return _error("Pilih dompet terlebih dahulu");

    setState(() => _isLoading = true);

    try {
      final transaksiC = Provider.of<TransaksiController>(
        context,
        listen: false,
      );
      final authC = Provider.of<AuthController>(context, listen: false);

      // 1. Ambil angka input user (misal user input "5" dollar)
      double inputAmount = double.parse(_jumlahC.text.replaceAll(',', ''));

      // 2. Kembalikan ke IDR sebelum disimpan (5 / rate = IDR asli)
      double finalAmountIDR =
          inputAmount / authC.selectedRate; // <--- PAKE selectedRate

      final updated = TransaksiModel(
        id: widget.transaksi.id,
        jumlah: finalAmountIDR, // Simpan ke DB dalam bentuk IDR
        kategoriId: _kategoriId!,
        dompetId: _dompetId!,
        tanggal: _tanggal,
        deskripsi: _deskripsiC.text.trim(),
        tipe: _tipe,
        userId: widget.transaksi.userId,
      );

      await transaksiC.updateTransaksi(widget.transaksi.id, updated);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Transaksi berhasil diperbarui!"),
          backgroundColor: primary,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      _error("Gagal update transaksi: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _error(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text(msg)));
  }

  Widget _tipeSelector() {
    return Container(
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
    );
  }

  Widget _tabButton(String label, String value) {
    final isActive = value == _tipe;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _tipe = value;
          _kategoriId = null;
        }),
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

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _inputField({
    String? hint,
    TextEditingController? controller,
    bool isNumber = false,
    String? currencySymbol,
    required String? Function(String?)? validator,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(10),
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
              keyboardType: isNumber
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.text,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
