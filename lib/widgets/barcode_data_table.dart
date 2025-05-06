// data_table.dart
import 'package:flutter/material.dart';
import 'package:peshoo_scanner/providers/barcode_provider.dart';
import 'package:provider/provider.dart';

class BarcodeDataTable extends StatelessWidget {
  const BarcodeDataTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        flex: 3,
        child: SingleChildScrollView(
            child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5))
                    ]),
                margin: EdgeInsets.all(10),
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Consumer<BarcodeProvider>(
                        builder: (context, provider, child) {
                      return DataTable(
                          columns: const [
                            DataColumn(
                                label: Icon(Icons.qr_code_scanner_outlined,
                                    color: Colors.indigo)),
                            DataColumn(
                                label: Icon(Icons.auto_awesome_motion_outlined,
                                    color: Colors.indigo)),
                            DataColumn(
                                label: Icon(Icons.delete, color: Colors.red))
                          ],
                          rows: provider.scannedData.entries.map((entry) {
                            return DataRow(cells: [
                              DataCell(Text(entry.key)),
                              DataCell(Text(entry.value.count.toString())),
                              DataCell(GestureDetector(
                                  onTap: () => provider.removeBarcode(
                                      context, entry.key),
                                  onLongPress: () => provider.removeAllBarcodes(
                                      context, entry.key),
                                  child: const Icon(Icons.remove_circle,
                                      color: Colors.red)))
                            ]);
                          }).toList());
                    })))));
  }
}
