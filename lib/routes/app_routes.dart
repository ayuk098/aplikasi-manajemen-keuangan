import 'package:flutter/material.dart';

// Auth & Beranda
import '../views/login_page.dart';
import '../views/register_page.dart';
import '../views/beranda_page.dart';

// Transaksi
import '../views/transaksi/tambah_transaksi_page.dart';
import '../views/transaksi/edit_transaksi_page.dart';
import '../models/transaksi_model.dart';

// Kategori
import '../views/kategori/kategori_page.dart';
import '../views/main_navigation.dart';

class AppRoutes {
  static String initialRoute = '/login';

  // ROUTES STATIS
  static Map<String, WidgetBuilder> routes = {
    '/login': (context) => const LoginPage(),
    '/register': (context) => const RegisterPage(),
    '/beranda': (context) => const BerandaPage(),
    '/main': (context) => const MainNavigation(),

    // TRANSAKSI
    '/tambahTransaksi': (context) => const TambahTransaksiPage(),

    // KATEGORI
    '/kategori': (context) => const KategoriPage(),
    // Route '/tambahKategori' dihapus karena menggunakan dialog
  };

  // ROUTES DINAMIS (yang butuh arguments)
  static Route<dynamic>? onGenerate(RouteSettings settings) {
    switch (settings.name) {
      /// EDIT TRANSAKSI
      case '/editTransaksi':
        final transaksi = settings.arguments as TransaksiModel;
        return MaterialPageRoute(
          builder: (_) => EditTransaksiPage(transaksi: transaksi),
        );

      default:
        return null;
    }
  }
}
