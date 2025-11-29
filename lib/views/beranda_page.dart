import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../controllers/auth_controller.dart';
import '../controllers/transaksi_controller.dart';
import '../models/transaksi_model.dart';

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  DateTime _selectedDate = DateTime.now();
  final Color _primaryColor = const Color(0xFF00674F);
  bool _isDateFormatInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeDateFormat();
  }

  Future<void> _initializeDateFormat() async {
    await initializeDateFormatting('id_ID', null);
    setState(() {
      _isDateFormatInitialized = true;
    });
  }

  List<DateTime> _getWeekDates(DateTime selectedDate) {
    DateTime monday = selectedDate.subtract(
      Duration(days: selectedDate.weekday - 1),
    );

    List<DateTime> weekDates = [];
    for (int i = 0; i < 7; i++) {
      weekDates.add(monday.add(Duration(days: i)));
    }
    return weekDates;
  }

  // Format nama bulan manual untuk menghindari locale issues
  String _getMonthYear(DateTime date) {
    const monthNames = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${monthNames[date.month - 1]} ${date.year}';
  }

  // Format nama hari manual
  String _getDayName(DateTime date) {
    const dayNames = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
    return dayNames[date.weekday % 7];
  }

  @override
  Widget build(BuildContext context) {
    final transaksiC = Provider.of<TransaksiController>(context);
    final auth = Provider.of<AuthController>(context);
    final weekDates = _getWeekDates(_selectedDate);

    if (!_isDateFormatInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text("Beranda"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              auth.logout();
              Navigator.pushReplacementNamed(context, "/login");
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: _primaryColor,
        onPressed: () {
          Navigator.pushNamed(context, "/tambahTransaksi");
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: Column(
        children: [
          // ===================== KALENDER MINGGUAN =====================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: _primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header bulan dan tahun
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _selectedDate = _selectedDate.subtract(
                            const Duration(days: 7),
                          );
                        });
                      },
                    ),
                    Text(
                      _getMonthYear(_selectedDate),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedDate = _selectedDate.add(
                            const Duration(days: 7),
                          );
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Hari dalam minggu (Sen, Sel, Rab, Kam, Jum, Sab, Min)
                Row(
                  children: weekDates
                      .map(
                        (date) => Expanded(
                          child: Column(
                            children: [
                              Text(
                                _getDayName(date),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedDate = date;
                                  });
                                },
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color:
                                        date.day == _selectedDate.day &&
                                            date.month == _selectedDate.month &&
                                            date.year == _selectedDate.year
                                        ? Colors.white
                                        : Colors.transparent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      date.day.toString(),
                                      style: TextStyle(
                                        color:
                                            date.day == _selectedDate.day &&
                                                date.month ==
                                                    _selectedDate.month &&
                                                date.year == _selectedDate.year
                                            ? _primaryColor
                                            : Colors.white,
                                        fontWeight:
                                            date.day == DateTime.now().day &&
                                                date.month ==
                                                    DateTime.now().month &&
                                                date.year == DateTime.now().year
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),

          // ===================== INFORMASI KEUANGAN =====================
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Sisa Uang
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _primaryColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Sisa uang kamu",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 46, 45, 45),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Rp ${_formatCurrency(transaksiC.sisaUang)}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Pemasukan dan Pengeluaran
                Row(
                  children: [
                    Expanded(
                      child: _infoCard(
                        "Pemasukan",
                        transaksiC.totalPemasukan,
                        Colors.green,
                        Icons.arrow_upward,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _infoCard(
                        "Pengeluaran",
                        transaksiC.totalPengeluaran,
                        Colors.red,
                        Icons.arrow_downward,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ===================== HEADER TRANSAKSI =====================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: const Row(
              children: [
                Text(
                  "Transaksi",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // ===================== LISTVIEW TRANSAKSI =====================
          Expanded(
            child: transaksiC.semuaTransaksi.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(
                          image: AssetImage('assets/images/saku.png'),
                          width: 150,
                          height: 150,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Belum ada transaksi",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: transaksiC.semuaTransaksi.length,
                    itemBuilder: (context, index) {
                      final transaksi = transaksiC.semuaTransaksi[index];
                      return _itemTransaksi(context, transaksi, transaksiC);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Format currency tanpa menggunakan NumberFormat untuk menghindari locale issues
  String _formatCurrency(double value) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  // ===================== WIDGET INFO CARD =====================
  Widget _infoCard(String title, double value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Rp ${_formatCurrency(value)}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemTransaksi(
    BuildContext context,
    TransaksiModel t,
    TransaksiController transaksiC,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          // Icon berdasarkan tipe transaksi
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: t.tipe == "pemasukan"
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              t.tipe == "pemasukan" ? Icons.arrow_upward : Icons.arrow_downward,
              color: t.tipe == "pemasukan" ? Colors.green : Colors.red,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          // Konten utama (deskripsi dan jumlah)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Deskripsi
                Text(
                  t.deskripsi,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                // Jumlah
                Text(
                  "Rp ${_formatCurrency(t.jumlah)}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: t.tipe == "pemasukan" ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Tombol aksi (edit dan hapus)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tombol Edit
              Container(
                width: 36,
                height: 36,
                child: IconButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      "/editTransaksi",
                      arguments: t,
                    );
                  },
                  icon: Icon(Icons.edit, color: Colors.blue, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),

              const SizedBox(width: 8),

              // Tombol Hapus
              Container(
                width: 36,
                height: 36,
                child: IconButton(
                  onPressed: () {
                    _showDeleteConfirmationDialog(context, t, transaksiC);
                  },
                  icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===================== DIALOG KONFIRMASI HAPUS =====================
  void _showDeleteConfirmationDialog(
    BuildContext context,
    TransaksiModel transaksi,
    TransaksiController transaksiC,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
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
            children: [
              // Header dengan icon warning
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_rounded,
                  color: Colors.orange,
                  size: 32,
                ),
              ),

              const SizedBox(height: 16),

              // Judul
              const Text(
                "Hapus Transaksi?",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00674F),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Deskripsi
              Text(
                "Transaksi yang dihapus tidak dapat dikembalikan",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // Card preview transaksi
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    // Icon transaksi
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: transaksi.tipe == "pemasukan"
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        transaksi.tipe == "pemasukan"
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: transaksi.tipe == "pemasukan"
                            ? Colors.green
                            : Colors.red,
                        size: 20,
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Detail transaksi
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaksi.deskripsi,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Rp ${_formatCurrency(transaksi.jumlah)}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: transaksi.tipe == "pemasukan"
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Badge tipe
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: transaksi.tipe == "pemasukan"
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: transaksi.tipe == "pemasukan"
                              ? Colors.green.withOpacity(0.3)
                              : Colors.red.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        transaksi.tipe == "pemasukan" ? "MASUK" : "KELUAR",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: transaksi.tipe == "pemasukan"
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Tombol aksi
              Row(
                children: [
                  // Tombol Batal
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.withOpacity(0.3)),
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

                  // Tombol Hapus
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _deleteTransaksi(transaksiC, transaksi);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete, size: 18),
                          SizedBox(width: 6),
                          Text(
                            "Hapus",
                            style: TextStyle(
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

  void _deleteTransaksi(
    TransaksiController transaksiC,
    TransaksiModel transaksi,
  ) {
    transaksiC.hapusTransaksi(transaksi.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Transaksi berhasil dihapus"),
        backgroundColor: _primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
