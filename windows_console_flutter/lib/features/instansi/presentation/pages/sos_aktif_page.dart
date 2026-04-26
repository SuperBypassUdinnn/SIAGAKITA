import 'package:flutter/material.dart';

class SosAktifPage extends StatelessWidget {
  const SosAktifPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Card(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: const [
                ListTile(
                  leading: Icon(Icons.warning_amber_rounded, color: Colors.red),
                  title: Text('SOS-9012 • Kecelakaan'),
                  subtitle: Text('Lhoknga • 2 menit lalu'),
                  trailing: Chip(label: Text('Kritis')),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.warning_amber_rounded, color: Colors.orange),
                  title: Text('SOS-9011 • Medis'),
                  subtitle: Text('Banda Aceh • 6 menit lalu'),
                  trailing: Chip(label: Text('Sedang')),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 4,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Detail SOS', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  const Text('ID: SOS-9012'),
                  const Text('Lokasi: Lhoknga, Aceh'),
                  const Text('Waktu: 09:21 WIB'),
                  const Text('Status: Diproses'),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 8,
                    children: const [
                      FilledButton(onPressed: null, child: Text('Set Pending')),
                      FilledButton(onPressed: null, child: Text('Set Diproses')),
                      FilledButton(onPressed: null, child: Text('Set Selesai')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
