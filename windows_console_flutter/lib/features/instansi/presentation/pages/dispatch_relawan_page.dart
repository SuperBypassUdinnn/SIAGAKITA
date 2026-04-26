import 'package:flutter/material.dart';

class DispatchRelawanPage extends StatelessWidget {
  const DispatchRelawanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: const [
                ListTile(
                  leading: CircleAvatar(child: Icon(Icons.person)),
                  title: Text('Ahmad Fauzi'),
                  subtitle: Text('Medis & First Aid • 0.8 km'),
                  trailing: Chip(label: Text('Standby')),
                ),
                Divider(),
                ListTile(
                  leading: CircleAvatar(child: Icon(Icons.person)),
                  title: Text('Siti Rahmah'),
                  subtitle: Text('Evakuasi & SAR • 1.1 km'),
                  trailing: Chip(label: Text('On Duty')),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Panel Dispatch', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  const Text('Misi: Kecelakaan lalu lintas (SOS-9012)'),
                  const Text('Lokasi: Lhoknga'),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.send),
                    label: const Text('Assign ke Relawan Terpilih'),
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
