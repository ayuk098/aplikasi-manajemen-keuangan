import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/../controllers/dompet_controller.dart';
import '/../controllers/auth_controller.dart';
import '/../models/dompet_model.dart';
import 'tambah_dompet_dialog.dart';
import 'edit_dompet_dialog.dart';

class DompetPage extends StatelessWidget {
  const DompetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dompetController = Provider.of<DompetController>(context);
    final auth = Provider.of<AuthController>(context); // <-- ambil auth
    final semuaDompet = dompetController.semuaDompet;

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00695C),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const TambahDompetDialog(),
          );
        },
        child: const Icon(Icons.add, size: 26),
      ),

      appBar: AppBar(
        backgroundColor: const Color(0xFF006C4E),
        title: const Text("Dompet", style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),

      body: semuaDompet.isEmpty
          ? _buildEmptyState()
          : _buildDompetList(
              semuaDompet,
              dompetController,
              auth,        // <-- kirim auth
              context,
            ),
    );
  }

  // -------------------------------------------------------
  //  UI KETIKA DOMPET MASIH KOSONG
  // -------------------------------------------------------
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/saku.png',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          const Text(
            'Data Masih Kosong',
            style: TextStyle(
              fontSize: 18,
              color: Color.fromARGB(255, 77, 77, 77),
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Tambahkan dompet pertama Anda untuk mulai mengelola keuangan',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------
  //  LIST DOMPET
  // -------------------------------------------------------
  Widget _buildDompetList(
    List<DompetModel> semuaDompet,
    DompetController controller,
    AuthController auth,         // <-- terima auth di sini
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: ListView.builder(
        itemCount: semuaDompet.length,
        itemBuilder: (context, index) {
          final d = semuaDompet[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF00695C)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // NAMA + SALDO
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.nama,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "Saldo: ${auth.formatFromIdr(d.saldoAwal)}",
                      ),
                    ],
                  ),
                ),

                // HAPUS BUTTON
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    controller.hapusDompet(d.id);
                  },
                ),

                // EDIT BUTTON
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.black87),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => EditDompetDialog(dompet: d),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
