import 'dart:convert';
import 'package:intl/intl.dart';

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
            child: StreamBuilder(
              stream: supabase
                  .from("tickets")
                  .stream(primaryKey: ['id'])
                  .eq('user', supabase.auth.currentUser!.id)
                  .order("created_at"),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final res = snapshot.data as List<Map<String, dynamic>>;
                  final datas = res;
                  final results = <Widget>[];
                  final resultsNotifiers = <ValueNotifier<double?>>[];
                  for (var element in datas) {
                    final notifier = ValueNotifier<double?>(0);
                    resultsNotifiers.add(notifier);

                    final data = element['data'] as Map<String, dynamic>;
                    var items = jsonDecode(data['items']) as List;

                    results.add(
                      ValueListenableBuilder(
                        valueListenable: notifier,
                        builder: (context, value, child) => InkWell(
                          onTap: () {
                            for (var element in resultsNotifiers) {
                              element.value = 0;
                            }
                            notifier.value = value == 0 ? null : 0;
                          },
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  color: value == null
                                      ? Theme.of(context).primaryColor
                                      : Colors.transparent,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          "${DateFormat('E d MMMM yyyy, HH:mm').format(DateTime.parse(element['created_at']))}",
                                          style: TextStyle(
                                            fontSize: Theme.of(context)
                                                .textTheme
                                                .titleMedium!
                                                .fontSize,
                                            color: value == null
                                                ? Colors.white
                                                : Colors.black,
                                          )),
                                      Row(
                                        children: [
                                          Text(
                                            "${data['total']}€",
                                            style: TextStyle(
                                              color: value == null
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                          Icon(
                                            value == null
                                                ? Icons.expand_less
                                                : Icons.expand_more,
                                            color: value == null
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                AnimatedSize(
                                  clipBehavior: Clip.antiAlias,
                                  curve: Curves.ease,
                                  duration: const Duration(milliseconds: 300),
                                  child: Container(
                                    height: value,
                                    padding: EdgeInsets.all(8),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              "N° Commercant ${element['magasin']}€",
                                              style: TextStyle(
                                                fontSize: Theme.of(context)
                                                    .textTheme
                                                    .caption!
                                                    .fontSize,
                                              )),
                                          Text("N° Ticket ${element['id']}€",
                                              style: TextStyle(
                                                fontSize: Theme.of(context)
                                                    .textTheme
                                                    .caption!
                                                    .fontSize,
                                              )),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              children: [
                                                for (var item in items)
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 4.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                            "${item['quantity']} x ${item['name']}"),
                                                        Text(
                                                            "${item['price']}€"),
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text("Total ${data['total']}€",
                                                  style: TextStyle(
                                                    fontSize: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium!
                                                        .fontSize,
                                                  )),
                                            ],
                                          ),
                                        ]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) => results[index],
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
