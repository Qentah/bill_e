import 'package:ai_barcode/ai_barcode.dart';
import 'package:bill_e/abstracts/navigation_page.dart';
import 'package:bill_e/tools.dart';
import 'package:flutter/material.dart';

class ClientPage extends NavigationPage {
  const ClientPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Client"),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  titlePadding: const EdgeInsets.symmetric(horizontal: 16.0),
                  title: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Flexible(
                          child: Text(
                            'Votre QR Code',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(8.0),
                  content: SizedBox(
                    width: 300,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: PlatformAiBarcodeCreatorWidget(
                        creatorController: CreatorController(),
                        initialValue: supabase.auth.currentUser!.id,
                      ),
                    ),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.qr_code_scanner),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: const [
                Flexible(child: Text('Visualisez vos tickets de caisse :')),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: FutureBuilder(
              future: supabase
                  .from('tickets')
                  .select()
                  .eq('user', supabase.auth.currentUser!.id),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      final result = snapshot.data[index];
                      return ListTile(
                        title: Text(result['data'].toString()),
                      );
                    },
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  String get name => "Client";

  @override
  String get route => "/client";

  @override
  IconData get icon => Icons.person;
}
