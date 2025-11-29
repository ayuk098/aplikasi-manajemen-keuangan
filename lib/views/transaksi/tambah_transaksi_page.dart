import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../../models/kategori_model.dart';
import '../../controllers/transaksi_controller.dart';
import '../../controllers/dompet_controller.dart';

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
  bool _isLoading = false;

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
    final kategoriBox = Hive.box<KategoriModel>('kategori');

    /// ================================================================
    /// FIX: FILTER KATEGORI BERDASARKAN USER ID + TIPE
    /// ================================================================
    final kategoriFiltered = kategoriBox.values
        .where((k) => k.userId == transaksiC.currentUserId && k.tipe == _tipe)
        .toList();

    /// Ambil dompet sesuai user
    final dompetC = Provider.of<DompetController>(context);
    final semuaDompetUser = dompetC.semuaDompet;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text("Tambah transaksi"),
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
                  // ================= TAB Pemasukan / Pengeluaran =================
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
                          // ================= DESKRIPSI =================
                          _label("Deskripsi"),
                          _inputField(
                            controller: _deskripsiC,
                            hint: "Masukkan deskripsi",
                            validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                          ),
                          const SizedBox(height: 20),

                          // ================= JUMLAH =================
                          _label("Jumlah"),
                          _inputField(
                            controller: _jumlahC,
                            hint: "Rp 0",
                            isNumber: true,
                            validator: (v) {
                              if (v!.isEmpty) return "Wajib diisi";
                              if (double.tryParse(v) == null) {
                                return "Masukkan angka valid";
                              }
                              if (double.parse(v) <= 0) {
                                return "Jumlah harus > 0";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // ================= TANGGAL =================
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
                                  Icon(
                                    Icons.calendar_today,
                                    size: 20,
                                    color: primary,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    DateFormat("dd/MM/yyyy").format(_tanggal),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const Spacer(),
                                  Text(
                                    DateFormat(
                                      'EEEE',
                                      'id_ID',
                                    ).format(_tanggal),
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

                          // ================= PILIH KATEGORI =================
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
                                hint: const Text("Pilih kategori"),
                                isExpanded: true,
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

                          // ================= DOMPET =================
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
                                  return RadioListTile<String>(
                                    value: d.id,
                                    groupValue: _dompetId,
                                    activeColor: primary,
                                    title: Text(
                                      d.nama,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "Rp ${NumberFormat('#,##0').format(d.saldoAwal)}",
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

                  // ================= BUTTON SIMPAN =================
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
                        onPressed: _simpanTransaksi,
                        child: const Text(
                          "Simpan transaksi",
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

  // ==========================================================
  // SIMPAN TRANSAKSI
  // ==========================================================

  Future<void> _simpanTransaksi() async {
    if (!_formKey.currentState!.validate()) return;

    if (_kategoriId == null) {
      _showSnack("Pilih kategori terlebih dahulu", Colors.orange);
      return;
    }

    if (_dompetId == null) {
      _showSnack("Pilih dompet terlebih dahulu", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final transaksiC = Provider.of<TransaksiController>(
        context,
        listen: false,
      );

      await transaksiC.tambahTransaksi(
        jumlah: double.parse(_jumlahC.text),
        kategoriId: _kategoriId!,
        dompetId: _dompetId!,
        deskripsi: _deskripsiC.text.trim(),
        tipe: _tipe,
        tanggal: _tanggal,
      );

      _showSnack("Transaksi berhasil disimpan!", primary);

      Navigator.pop(context);
    } catch (e) {
      _showSnack("Gagal menyimpan transaksi: $e", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ==========================================================
  // REUSABLE WIDGETS
  // ==========================================================

  Widget _tabButton(String label, String value) {
    final isActive = _tipe == value;
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

  Widget _label(String t) {
    return Padding(
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
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    bool isNumber = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          prefix: isNumber ? const Text("Rp ") : null,
          border: InputBorder.none,
        ),
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

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
