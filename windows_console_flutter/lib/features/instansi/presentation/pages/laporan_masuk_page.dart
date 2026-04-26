import 'package:flutter/material.dart';

class LaporanMasukPage extends StatelessWidget {
  const LaporanMasukPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Antrian Laporan Masyarakat', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
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
                      DataCell(Text('RPT-2001')),
                      DataCell(Text('Kebakaran')),
                      DataCell(Text('Kuta Alam')),
                      DataCell(Text('Kritis')),
                      DataCell(Text('Pending')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('RPT-2000')),
                      DataCell(Text('Bencana Alam')),
                      DataCell(Text('Ulee Lheue')),
                      DataCell(Text('Sedang')),
                      DataCell(Text('Diproses')),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
