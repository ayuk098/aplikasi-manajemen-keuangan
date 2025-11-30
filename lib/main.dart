import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import 'models/user_model.dart';
import 'models/kategori_model.dart';
import 'models/dompet_model.dart';
import 'models/transaksi_model.dart';

import 'services/hive_service.dart';
import 'services/notification_service.dart';

import 'controllers/auth_controller.dart';
import 'controllers/transaksi_controller.dart';
import 'controllers/kategori_controller.dart';
import 'controllers/dompet_controller.dart';

import 'routes/app_routes.dart';
import 'views/landing_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // INIT HIVE
  await Hive.initFlutter();
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(KategoriModelAdapter());
  Hive.registerAdapter(DompetModelAdapter());
  Hive.registerAdapter(TransaksiModelAdapter());

  await HiveService.init();

  // INIT NOTIFICATION SERVICE
  await NotificationService.init();

  // WAJIB UNTUK ANDROID 13+
  await Permission.notification.request();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  String _getCurrentUserId(AuthController auth) {
    return auth.currentUser?.id ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),

        // DOMPET
        ChangeNotifierProxyProvider<AuthController, DompetController>(
          create: (context) {
            final userId = _getCurrentUserId(
              Provider.of<AuthController>(context, listen: false),
            );
            return DompetController(userId);
          },
          update: (context, auth, previous) {
            final userId = _getCurrentUserId(auth);

            if (userId.isNotEmpty &&
                (previous == null || previous.currentUserId != userId)) {
              final c = DompetController(userId);
              c.initDefaultDompet();
              return c;
            }
            return previous ?? DompetController(userId);
          },
        ),

        // KATEGORI
        ChangeNotifierProxyProvider<AuthController, KategoriController>(
          create: (context) {
            final userId = _getCurrentUserId(
              Provider.of<AuthController>(context, listen: false),
            );
            return KategoriController(userId);
          },
          update: (context, auth, previous) {
            final userId = _getCurrentUserId(auth);

            if (userId.isNotEmpty &&
                (previous == null || previous.currentUserId != userId)) {
              final c = KategoriController(userId);
              c.initDefaultKategori();
              return c;
            }
            return previous ?? KategoriController(userId);
          },
        ),

        // TRANSAKSI
        ChangeNotifierProxyProvider2<
          AuthController,
          DompetController,
          TransaksiController
        >(
          create: (context) {
            final userId = _getCurrentUserId(
              Provider.of<AuthController>(context, listen: false),
            );
            final dompet = Provider.of<DompetController>(
              context,
              listen: false,
            );

            return TransaksiController(userId, dompet);
          },
          update: (context, auth, dompet, previous) {
            final userId = _getCurrentUserId(auth);

            if (userId.isNotEmpty &&
                (previous == null || previous.currentUserId != userId)) {
              return TransaksiController(userId, dompet);
            }
            return previous ?? TransaksiController(userId, dompet);
          },
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Keuangan App',

        initialRoute: '/splash',

        routes: {
          '/landing': (_) => const LandingScreen(),
          '/splash': (_) => const SplashScreen(),
          ...AppRoutes.routes,
        },

        onGenerateRoute: AppRoutes.onGenerate,
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;

      final auth = Provider.of<AuthController>(context, listen: false);
      final hasSession = auth.checkSession();

      if (hasSession) {
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        Navigator.pushReplacementNamed(context, '/landing');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SizedBox(height: 20),
            CircularProgressIndicator(color: Color(0xFF00674F)),
          ],
        ),
      ),
    );
  }
}
