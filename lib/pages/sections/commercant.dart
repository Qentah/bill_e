import 'package:bill_e/abstracts/navigation_page.dart';
import 'package:bill_e/tools.dart';
import 'package:flutter/material.dart';

import 'package:ai_barcode/ai_barcode.dart';

class CommercantPage extends NavigationPage {
  const CommercantPage({super.key});

  @override
  Widget build(BuildContext context) {
    final resultNotifier = ValueNotifier<String>('');

    final scannerController = ScannerController(
      scannerResult: (String result) {
        resultNotifier.value = result;
      },
    );

    resultNotifier.addListener(() async {
      await supabase.from('tickets').insert({
        "user": resultNotifier.value,
        "data": {"value": DateTime.now().toString()},
      });
      await scannerController.stopCamera();
      Navigator.of(context).pop();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Commercant"),
      ),
      body: Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
              onPressed: () {
                scannerController.startCamera();
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      contentPadding: const EdgeInsets.all(4),
                      content: Container(
                        height: 300,
                        width: 300,
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(),
                        child: PlatformAiBarcodeScannerWidget(
                          platformScannerController: scannerController,
                        ),
                      ),
                    );
                  },
                );
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scanner le client')),
        ],
      )),
    );
  }

  @override
  String get name => "Commercant";

  @override
  String get route => "/commercant";

  @override
  IconData get icon => Icons.shopping_basket;
}
