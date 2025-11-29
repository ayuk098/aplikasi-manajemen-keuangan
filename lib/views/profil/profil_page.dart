import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import 'developer_page.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final Color primaryColor = const Color(0xFF006C4E);
  final ImagePicker _picker = ImagePicker();

  File? _localImage; // untuk preview cepat

  Future<void> _pickImage(ImageSource source) async {
    final authC = Provider.of<AuthController>(context, listen: false);

    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (picked == null) return;

    setState(() {
      _localImage = File(picked.path);
    });

    // SIMPAN PERMANEN KE HIVE  
    authC.updatePhoto(picked.path);
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
              padding: EdgeInsets.fromLTRB(
                20,
                topPadding + 16,
                20,
                24,
              ),
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
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      children: [
                        // FOTO PROFIL + BUTTON KAMERA
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 55,
                              backgroundColor: const Color(0xFFE0E0E0),
                              backgroundImage:
                                  profileImageFile != null ? FileImage(profileImageFile) : null,
                              child: profileImageFile == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 70,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),

                            // ICON KAMERA (fix hilang)
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
                                    boxShadow: [
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

                        // NAMA
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
                  MenuCard(
                    primaryColor: primaryColor,
                    icon: Icons.attach_money,
                    label: "Konversi Mata Uang",
                    trailing: const Icon(Icons.keyboard_arrow_down),
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),

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

                  MenuCard(
                    primaryColor: primaryColor,
                    icon: Icons.settings,
                    label: "Pengaturan",
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
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
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 15),
              ),
            ),
            trailing ?? const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
