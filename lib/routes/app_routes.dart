import 'package:flutter/material.dart';

import '../views/login_page.dart';
import '../views/register_page.dart';
import '../views/beranda_page.dart';
import '../views/main_navigation.dart';

import '../views/transaksi/tambah_transaksi_page.dart';
import '../views/transaksi/edit_transaksi_page.dart';
import '../models/transaksi_model.dart';

import '../views/kategori/kategori_page.dart';
import '../views/register_succes_page.dart';
import '../views/welcome_page.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/login': (_) => const LoginPage(),
    '/register': (_) => const RegisterPage(),
    '/success-register': (_) => const RegisterSuccessPage(),

    '/welcome': (_) => const WelcomePage(),   // ⬅️ NEW

    '/beranda': (_) => const BerandaPage(),
    '/main': (_) => const MainNavigation(),

    '/tambahTransaksi': (_) => const TambahTransaksiPage(),
    '/kategori': (_) => const KategoriPage(),
  };

  static Route<dynamic>? onGenerate(RouteSettings settings) {
    switch (settings.name) {
      case '/editTransaksi':
        final transaksi = settings.arguments as TransaksiModel;
        return MaterialPageRoute(
          builder: (_) => EditTransaksiPage(transaksi: transaksi),
        );
    }
    return null;
  }
}
