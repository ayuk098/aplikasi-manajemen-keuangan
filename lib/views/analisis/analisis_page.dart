import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:intl/intl.dart';

import '../../controllers/transaksi_controller.dart';
import '../../controllers/kategori_controller.dart';
import '../../models/transaksi_model.dart';
import '../../models/kategori_model.dart';

class AnalisisPage extends StatefulWidget {
  const AnalisisPage({super.key});

  @override
  State<AnalisisPage> createState() => _AnalisisPageState();
}

// Filter tipe untuk dropdown
enum FilterTipe { pengeluaran, pemasukan, semua }

class _AnalisisPageState extends State<AnalisisPage> {
  final Color primaryColor = const Color(0xFF006C4E);

  // Realtime / Bulanan
  String _selectedPeriod = "Realtime";
  // Filter tipe pemasukan/pengeluaran/semua
  FilterTipe _selectedType = FilterTipe.pengeluaran;

  Map<String, double> dataMap = {"Tidak Ada Data": 100.0};
  List<Color> colorList = [Colors.grey];

  // Total nominal transaksi yang tampil di chart (untuk persen legend)
  double _chartSum = 0.0;
  double _displayTotal = 0.0;

  late TransaksiController _transaksiC;
  late KategoriController _kategoriC;
  bool _listenerRegistered = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _transaksiC = context.read<TransaksiController>();
      _kategoriC = context.read<KategoriController>();

      _transaksiC.addListener(_onDataChanged);
      _kategoriC.addListener(_onDataChanged);
      _listenerRegistered = true;

      _generateChartData(
        _transaksiC.semuaTransaksi,
        _kategoriC.semuaKategori,
      );
    });
  }

  @override
  void dispose() {
    if (_listenerRegistered) {
      _transaksiC.removeListener(_onDataChanged);
      _kategoriC.removeListener(_onDataChanged);
    }
    super.dispose();
  }

  void _onDataChanged() {
    if (!mounted) return;
    _generateChartData(
      _transaksiC.semuaTransaksi,
      _kategoriC.semuaKategori,
    );
  }

  // LOGIKA DATA (periode + tipe)
  void _generateChartData(
    List<TransaksiModel> semuaTransaksi,
    List<KategoriModel> semuaKategori,
  ) {
    if (!mounted) return;

    final now = DateTime.now();

    // Filter dulu berdasarkan periode (Realtime / Bulanan)
    List<TransaksiModel> filteredByPeriod = semuaTransaksi.where((t) {
      final tanggal = t.tanggal;
      if (_selectedPeriod == "Realtime") {
        // hari ini
        return tanggal.year == now.year &&
            tanggal.month == now.month &&
            tanggal.day == now.day;
      } else {
        // bulan ini
        return tanggal.year == now.year && tanggal.month == now.month;
      }
    }).toList();

    // Total pemasukan & pengeluaran di PERIODE terpilih
    final totalPemasukan = filteredByPeriod
        .where((t) => t.tipe == "pemasukan")
        .fold(0.0, (sum, t) => sum + t.jumlah);

    final totalPengeluaran = filteredByPeriod
        .where((t) => t.tipe == "pengeluaran")
        .fold(0.0, (sum, t) => sum + t.jumlah);

    //Filter transaksi untuk CHART sesuai tipe
    final List<TransaksiModel> filteredForChart =
        filteredByPeriod.where((t) {
      switch (_selectedType) {
        case FilterTipe.pemasukan:
          return t.tipe == "pemasukan";
        case FilterTipe.pengeluaran:
          return t.tipe == "pengeluaran";
        case FilterTipe.semua:
          return true;
      }
    }).toList();

    //Kelompokkan per kategori
    final Map<String, double> categoryTotals = {};
    for (var t in filteredForChart) {
      final kategori = semuaKategori.firstWhere(
        (k) => k.id == t.kategoriId,
        orElse: () => KategoriModel(
          id: t.kategoriId,
          nama: "Kategori Lain",
          tipe: t.tipe,
          userId: t.userId,
        ),
      );

      categoryTotals.update(
        kategori.nama,
        (value) => value + t.jumlah,
        ifAbsent: () => t.jumlah,
      );
    }

    //Total nominal untuk persen legend (jumlah semua slice)
    final chartSum =
        filteredForChart.fold(0.0, (sum, t) => sum + t.jumlah);

    //Total yang ditampilkan di bawah chart
    double displayTotal;
    switch (_selectedType) {
      case FilterTipe.pemasukan:
        displayTotal = totalPemasukan;
        break;
      case FilterTipe.pengeluaran:
        displayTotal = totalPengeluaran;
        break;
      case FilterTipe.semua:
        displayTotal = totalPemasukan - totalPengeluaran;
        break;
    }

    //Warna slice chart
    final baseColors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.cyan,
      Colors.indigo,
    ];

    int idx = 0;
    final List<Color> newColors = [];
    Map<String, double> newDataMap = {};

    if (categoryTotals.isNotEmpty) {
      categoryTotals.forEach((key, value) {
        newDataMap[key] = value;
        newColors.add(baseColors[idx % baseColors.length]);
        idx++;
      });
    } else {
      newDataMap = {"Tidak Ada Data": 100.0};
      newColors.add(Colors.grey);
    }

    setState(() {
      dataMap = newDataMap;
      colorList = newColors;
      _chartSum = chartSum;
      _displayTotal = displayTotal;
    });
  }

  // HELPER UI
  String _formatCurrency(double value) {
    final f = NumberFormat('#,##0', 'id_ID');
    return f.format(value);
  }

  Widget _buildLegend() {
    if (dataMap.isEmpty ||
        (dataMap.keys.first == "Tidak Ada Data" && _chartSum == 0.0)) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          "Tidak ada data transaksi untuk periode ini.",
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      children: dataMap.keys.map((key) {
        final index = dataMap.keys.toList().indexOf(key);
        final color = colorList[index % colorList.length];
        final amount = dataMap[key]!;
        final percentage =
            _chartSum > 0 ? (amount / _chartSum * 100) : 0.0;

        return Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  key,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Rp ${_formatCurrency(amount)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${percentage.toStringAsFixed(1)}%",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // BUILD
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(170),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            20,
            topPadding + 8, 
            20,
            20,
          ),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Analisis Keuangan",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 16),

              // ===== SEGMENTED CONTROL REALTIME / BULANAN =====
              Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Row(
                  children: [
                    // REALTIME
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPeriod = "Realtime";
                          });
                          _onDataChanged();
                        },
                        child: Container(
                          margin: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: _selectedPeriod == "Realtime"
                                ? primaryColor
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Realtime",
                            style: TextStyle(
                              color: _selectedPeriod == "Realtime"
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // BULANAN
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPeriod = "Bulanan";
                          });
                          _onDataChanged();
                        },
                        child: Container(
                          margin: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: _selectedPeriod == "Bulanan"
                                ? primaryColor
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Bulanan",
                            style: TextStyle(
                              color: _selectedPeriod == "Bulanan"
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Container(
                height: 40, 
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<FilterTipe>(
                    value: _selectedType,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: FilterTipe.pengeluaran,
                        child: Text("Pengeluaran"),
                      ),
                      DropdownMenuItem(
                        value: FilterTipe.pemasukan,
                        child: Text("Pemasukan"),
                      ),
                      DropdownMenuItem(
                        value: FilterTipe.semua,
                        child: Text("Pemasukan & Pengeluaran"),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => _selectedType = v);
                        _onDataChanged();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32),

            PieChart(
              dataMap: dataMap,
              colorList: colorList,
              chartType: ChartType.ring,
              ringStrokeWidth: 32,
              chartRadius: MediaQuery.of(context).size.width / 2.5,
              animationDuration: const Duration(milliseconds: 800),
              centerText: "",
              chartLegendSpacing: 32,
              legendOptions: const LegendOptions(showLegends: false),
              chartValuesOptions: const ChartValuesOptions(
                showChartValues: false,
                showChartValueBackground: false,
                showChartValuesInPercentage: false,
                showChartValuesOutside: false,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              "Total: Rp ${_formatCurrency(_displayTotal)}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),
            _buildLegend(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
