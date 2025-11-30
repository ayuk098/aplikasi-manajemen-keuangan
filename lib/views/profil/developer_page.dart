import 'package:flutter/material.dart';

class DeveloperPage extends StatelessWidget {
  DeveloperPage({super.key});

  final Color primaryColor = const Color(0xFF006C4E);

  final List<Map<String, String>> developers = [
    {
      "name": "Zeva Mila Sabrina",
      "nim": "124230043",
      "photo": "assets/images/zeva.jpg",
    },
    {
      "name": "Wahyu Ramadhani Manurung",
      "nim": "124230041",
      "photo": "assets/images/ayu.jpeg", 
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Developer"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: developers.length,
        itemBuilder: (context, index) {
          final dev = developers[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: primaryColor, width: 1.3),
            ),
            child: Row(
              children: [
                // FOTO
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.grey[300],
                  backgroundImage:
                      dev["photo"]!.isNotEmpty ? AssetImage(dev["photo"]!) : null,
                  child: dev["photo"]!.isEmpty
                      ? const Icon(Icons.person, size: 35, color: Colors.white)
                      : null,
                ),

                const SizedBox(width: 16),

                // NAMA + NIM
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dev["name"]!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dev["nim"]!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
