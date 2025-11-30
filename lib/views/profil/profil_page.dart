import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../services/currency_service.dart';
import 'developer_page.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final Color primaryColor = const Color(0xFF006C4E);
  final ImagePicker _picker = ImagePicker();

  // ====== FOTO PROFIL ======
  File? _localImage;

  Future<void> _pickImage(ImageSource source) async {
    final authC = Provider.of<AuthController>(context, listen: false);

    final picked = await _picker.pickImage(source: source, imageQuality: 70);

    if (picked == null) return;

    setState(() {
      _localImage = File(picked.path);
    });

    // simpan ke Hive
    await authC.updatePhoto(picked.path);
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Pilih dari Galeri"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Ambil dari Kamera"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ====== PENGATURAN MATA UANG APP ======
  bool _isCurrencyExpanded = false;
  bool _isLoadingCurrency = false;
  String _selectedCurrency = "USD";

  final List<String> _currencies = [
    "IDR",
    "USD",
    "EUR",
    "SGD",
    "JPY",
    "MYR",
    "AUD",
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sinkronkan _selectedCurrency dengan auth.selectedCurrency
    final authC = Provider.of<AuthController>(context);
    _selectedCurrency = authC.selectedCurrency;
  }

  Future<void> _setAppCurrency(String currency, AuthController authC) async {
    setState(() {
      _isLoadingCurrency = true;
      _selectedCurrency = currency;
    });

    try {
      if (currency == "IDR") {
        // default: 1 IDR = 1 IDR
        await authC.updateCurrency("IDR", 1.0);
      } else {
        // ambil rate dari CurrencyService
        final rate = await CurrencyService.getRate(currency);

        if (rate == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Gagal mengambil kurs $currency"),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isLoadingCurrency = false);
          return;
        }
        await authC.updateCurrency(currency, rate);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Mata uang aplikasi diubah ke $currency"),
          backgroundColor: primaryColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Terjadi kesalahan: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isLoadingCurrency = false);
  }

  @override
  Widget build(BuildContext context) {
    final authC = Provider.of<AuthController>(context);
    final user = authC.currentUser;
    final topPadding = MediaQuery.of(context).padding.top;

    final fotoPath = user?.fotoPath ?? "";
    final displayName = user?.nama ?? "Nama";

    final File? profileImageFile =
        _localImage ?? (fotoPath.isNotEmpty ? File(fotoPath) : null);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ================= HEADER HIJAU =================
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 24),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Profil",
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 55,
                              backgroundColor: const Color(0xFFE0E0E0),
                              backgroundImage: profileImageFile != null
                                  ? FileImage(profileImageFile)
                                  : null,
                              child: profileImageFile == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 70,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _showImagePickerSheet,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 3,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 20,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Text(
                          displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        if (user?.email != null)
                          Text(
                            user!.email,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ================= MENU =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // ===========================================================
                  //     CARD MATA UANG APLIKASI (USER CUMA PILIH CURRENCY)
                  // ===========================================================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: primaryColor, width: 1.3),
                    ),
                    child: Column(
                      children: [
                        // HEADER CARD
                        InkWell(
                          onTap: () {
                            setState(() {
                              _isCurrencyExpanded = !_isCurrencyExpanded;
                            });
                          },
                          child: Row(
                            children: [
                              Icon(Icons.attach_money, color: primaryColor),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  "Mata Uang Aplikasi",
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                              Icon(
                                _isCurrencyExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: primaryColor,
                              ),
                            ],
                          ),
                        ),

                        if (_isCurrencyExpanded) ...[
                          const SizedBox(height: 10),
                          const Divider(height: 1),
                          const SizedBox(height: 10),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Pilih mata uang yang akan digunakan di seluruh aplikasi:",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Dropdown mata uang
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: primaryColor),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedCurrency,
                                isExpanded: true,
                                items: _currencies
                                    .map(
                                      (c) => DropdownMenuItem(
                                        value: c,
                                        child: Text(c),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null && !_isLoadingCurrency) {
                                    _setAppCurrency(val, authC);
                                  }
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          if (_isLoadingCurrency)
                            Row(
                              children: const [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Mengambil kurs & menyimpan pengaturan...",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            )
                          else
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Mata uang aktif: ${authC.selectedCurrency}",
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ================= DEVELOPER =================
                  MenuCard(
                    primaryColor: primaryColor,
                    icon: Icons.info_outline,
                    label: "Developer",
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => DeveloperPage()),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // ================= PENGATURAN =================
                  MenuCard(
                    primaryColor: primaryColor,
                    icon: Icons.logout,
                    label: "Logout",
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      final auth = Provider.of<AuthController>(context, listen: false);

                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          backgroundColor: Colors.transparent,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // ICON HIJAU
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF006C4E).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.logout,
                                    size: 36,
                                    color: Color(0xFF006C4E),
                                  ),
                                ),

                                const SizedBox(height: 18),

                                // JUDUL
                                const Text(
                                  "Keluar dari Akun?",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF006C4E),
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                const SizedBox(height: 8),

                                // DESKRIPSI
                                const Text(
                                  "Apakah kamu yakin ingin logout dari aplikasi?",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                const SizedBox(height: 24),

                                Row(
                                  children: [
                                    // BUTTON BATAL
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => Navigator.pop(context),
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(color: Colors.grey.withOpacity(0.4)),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                        child: const Text(
                                          "Batal",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    // BUTTON LOGOUT
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          auth.logout();
                                          Navigator.pushReplacementNamed(context, "/login");
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF006C4E),
                                          foregroundColor: Colors.white,
                                          shadowColor: Colors.black45,
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                        child: const Text(
                                          "Logout",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
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
                    },

                  ),

                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// =======================================================================
// =========================== MENU CARD =================================
// =======================================================================

class MenuCard extends StatelessWidget {
  final Color primaryColor;
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;

  const MenuCard({
    super.key,
    required this.primaryColor,
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryColor, width: 1.3),
        ),
        child: Row(
          children: [
            Icon(icon, color: primaryColor),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),
            trailing ?? const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
