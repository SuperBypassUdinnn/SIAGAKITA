import 'package:flutter/material.dart';

class PetaOperasionalPage extends StatelessWidget {
  const PetaOperasionalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Container(
            height: 46,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE7EBF3))),
            ),
            child: const Row(
              children: [
                Icon(Icons.map_outlined, size: 18),
                SizedBox(width: 8),
                Text('Peta Operasional (Mock)'),
              ],
            ),
          ),
          const Expanded(
            child: Center(
              child: Text('Map layer akan dihubungkan ke /api/map/nearby'),
            ),
          ),
        ],
      ),
    );
  }
}
