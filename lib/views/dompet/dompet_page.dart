import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/dompet_controller.dart';
import '../../controllers/currency_controller.dart'; 
import '../../models/dompet_model.dart';

import 'tambah_dompet_dialog.dart';
import 'edit_dompet_dialog.dart';

class DompetPage extends StatelessWidget {
  const DompetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dompetController = Provider.of<DompetController>(context);
    final currency = Provider.of<CurrencyController>(context); 

    final semuaDompet = dompetController.semuaDompet;

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00695C),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const TambahDompetDialog(),
          );
        },
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFF006C4E),
        title: const Text(
          "Dompet",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: semuaDompet.isEmpty
          ? _buildEmpty()
          : _buildList(semuaDompet, dompetController, currency, context),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset("assets/images/saku.png", height: 180),
          const SizedBox(height: 16),
          const Text(
            "Data Masih Kosong",
            style: TextStyle(fontSize: 18, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Tambahkan dompet pertama Anda untuk mulai mengelola keuangan",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

 
  Widget _buildList(
    List<DompetModel> data,
    DompetController controller,
    CurrencyController currency, 
    BuildContext context,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: data.length,
      itemBuilder: (context, i) {
        final d = data[i];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF00695C)),
          ),
          child: Row(
            children: [
              // Nama & saldo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.nama,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text("Saldo: ${currency.formatFromIdr(d.saldoAwal)}"),
                  ],
                ),
              ),

              // Edit
              IconButton(
                icon: const Icon(
                  Icons.edit,
                  color: Color.fromARGB(221, 69, 149, 228),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => EditDompetDialog(dompet: d),
                  );
                },
              ),

              // Hapus
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  controller.hapusDompet(d.id);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
