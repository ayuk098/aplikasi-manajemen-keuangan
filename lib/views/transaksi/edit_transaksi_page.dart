import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../../controllers/transaksi_controller.dart';
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

  @override
  void initState() {
    super.initState();
    _deskripsiC = TextEditingController(text: widget.transaksi.deskripsi);
    _jumlahC = TextEditingController(text: widget.transaksi.jumlah.toString());
    _tipe = widget.transaksi.tipe;
    _kategoriId = widget.transaksi.kategoriId;
    _dompetId = widget.transaksi.dompetId;
    _tanggal = widget.transaksi.tanggal;
  }

  @override
  void dispose() {
    _deskripsiC.dispose();
    _jumlahC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transaksiC = Provider.of<TransaksiController>(context);

    // ===== Ambil User ID login dari session Hive =====
    final sessionBox = Hive.box('session');
    final currentUserId = sessionBox.get('userId');

    // ===== Ambil seluruh kategori milik user =====
    final kategoriBox = Hive.box<KategoriModel>('kategori');
    final kategoriFiltered = kategoriBox.values
        .where((e) => e.userId == currentUserId && e.tipe == _tipe)
        .toList();

    // ===== Ambil seluruh dompet milik user =====
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
                  // ============ Header tipe transaksi ============
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

                  // ============ Content =============
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
                          _inputField(
                            hint: "Rp 0",
                            controller: _jumlahC,
                            isNumber: true,
                            validator: (v) {
                              if (v!.isEmpty) return "Jumlah wajib diisi";
                              if (double.tryParse(v) == null) {
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

                          // ============ KATEGORI =============
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

                          // ============ DOMPET =============
                          _label("Pilih dompet"),
                          if (dompetFiltered.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.orange),
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.orange[50],
                              ),
                              child: const Text(
                                "Belum ada dompet. Tambahkan dulu.",
                                style: TextStyle(color: Colors.orange),
                              ),
                            )
                          else
                            Column(
                              children: dompetFiltered.map((d) {
                                return RadioListTile<String>(
                                  value: d.id,
                                  groupValue: _dompetId,
                                  activeColor: primary,
                                  title: Text(d.nama),
                                  subtitle: Text(
                                    "Rp ${NumberFormat('#,##0').format(d.saldoAwal)}",
                                  ),
                                  onChanged: (v) =>
                                      setState(() => _dompetId = v),
                                );
                              }).toList(),
                            ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),

                  // SAVE BUTTON
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

  // ========== Date Picker ==========
  Future<void> _selectDate(BuildContext context) async {
    final pilih = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pilih != null) setState(() => _tanggal = pilih);
  }

  // ========== Update Transaksi ==========
  Future<void> _updateTransaksi() async {
    if (!_formKey.currentState!.validate()) return;

    if (_kategoriId == null) {
      return _error("Pilih kategori terlebih dahulu");
    }

    if (_dompetId == null) {
      return _error("Pilih dompet terlebih dahulu");
    }

    setState(() => _isLoading = true);

    try {
      final transaksiC = Provider.of<TransaksiController>(
        context,
        listen: false,
      );

      final updated = TransaksiModel(
        id: widget.transaksi.id,
        jumlah: double.parse(_jumlahC.text),
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

  // ========== Helper UI ==========
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
          _kategoriId = null; // Reset kategori saat tipe berubah
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
    String? Function(String?)? validator,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: isNumber
            ? const TextInputType.numberWithOptions(decimal: false)
            : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          prefix: isNumber ? const Text("Rp ") : null,
        ),
      ),
    );
  }
}
