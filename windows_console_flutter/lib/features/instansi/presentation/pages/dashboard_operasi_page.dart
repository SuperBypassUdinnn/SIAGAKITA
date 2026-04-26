import 'package:flutter/material.dart';

class DashboardOperasiPage extends StatelessWidget {
  const DashboardOperasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Expanded(child: _KpiCard(title: 'SOS Aktif', value: '12')),
            SizedBox(width: 12),
            Expanded(child: _KpiCard(title: 'Laporan Baru', value: '37')),
            SizedBox(width: 12),
            Expanded(child: _KpiCard(title: 'Relawan Standby', value: '64')),
            SizedBox(width: 12),
            Expanded(child: _KpiCard(title: 'Avg Response', value: '04:32')),
          ],
        ),
        const SizedBox(height: 14),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Insiden Terbaru',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  const Expanded(
                    child: SingleChildScrollView(
                      child: DataTable(
                        columns: [
                          DataColumn(label: Text('ID')),
                          DataColumn(label: Text('Kategori')),
                          DataColumn(label: Text('Lokasi')),
                          DataColumn(label: Text('Urgensi')),
                          DataColumn(label: Text('Status')),
                        ],
                        rows: [
                          DataRow(cells: [
                            DataCell(Text('SOS-9012')),
                            DataCell(Text('Kecelakaan')),
                            DataCell(Text('Lhoknga')),
                            DataCell(Text('Kritis')),
                            DataCell(Text('Diproses')),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('RPT-1832')),
                            DataCell(Text('Kebakaran')),
                            DataCell(Text('Baitussalam')),
                            DataCell(Text('Sedang')),
                            DataCell(Text('Pending')),
                          ]),
                        ],
                      ),
                    ),
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

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}
