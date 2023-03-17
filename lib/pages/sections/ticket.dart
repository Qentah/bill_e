import 'dart:async';
import 'dart:convert';

import 'package:ai_barcode/ai_barcode.dart';
import 'package:bill_e/abstracts/navigation_page.dart';
import 'package:flutter/material.dart';

import '../../tools.dart';

class ObservableListMap {
  final _list = <Map>[];

  final _itemAddedStreamController = StreamController<Map>();

  final _listStreamController = StreamController<List<Map>>();

  Stream get itemAddedStream => _itemAddedStreamController.stream;

  Stream get listStream => _listStreamController.stream;

  void add(Map value) {
    _list.add(value);
    _itemAddedStreamController.add(value);
    _listStreamController.add(_list);
  }

  void remove(Map value) {
    _list.remove(value);
    _listStreamController.add(_list);
  }

  void clear() {
    print("clear");
    _list.clear();
    _listStreamController.add(_list);
  }

  void changeQuantity(Map value) {
    final index =
        _list.indexWhere((element) => element["name"] == value["name"]);
    if (index == -1) {
      add(value);
    } else {
      _list[index]["quantity"] = value["quantity"];
      print(_list[index]);
      _listStreamController.add(_list);
    }
  }

  void dispose() {
    _listStreamController.close();
    _itemAddedStreamController.close();
  }
}

class TicketPage extends NavigationPage {
  const TicketPage({super.key});

  @override
  Widget build(BuildContext context) {
    //List of items with price
    final items = <Map>[
      {"color": Colors.red, "name": "Tomate", "price": 1.0},
      {"color": Colors.green, "name": "Concombre", "price": 0.75},
      {"color": Colors.yellow, "name": "Asperge", "price": 0.10},
      {"color": Colors.white, "name": "Riz", "price": 1.5},
      {"color": Colors.amber, "name": "Pates", "price": 2.0},
    ];

    final ticket = ObservableListMap();

    void clearTicket() {
      ticket.clear();
      for (final item in items) {
        ticket.add(Map.from(item));
      }
    }

    clearTicket();

    var scanWaiting = false;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ticket"),
      ),
      body: StreamBuilder<List<Map>>(
        stream: ticket.listStream as Stream<List<Map>>,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final filtredList = snapshot.data
              ?.where((element) =>
                  element.containsKey("quantity") && element["quantity"] != 0)
              .toList();
          print(filtredList);
          final total = filtredList?.isEmpty ?? false
              ? 0
              : filtredList
                  ?.map((e) => (e["price"] * e["quantity"]))
                  .reduce((value, element) => value + element);
          return Column(
            children: [
              Flexible(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: CircleAvatar(
                            backgroundColor: items[index]["color"],
                          ),
                        ),
                      ),
                      title: Text(items[index]["name"]),
                      subtitle: Text("${items[index]["price"]}€"),
                      //trailing with buttons to add or remove items with a quantity indicator
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              if ((snapshot.data![index]["quantity"] ?? 0) >
                                  0) {
                                ticket.changeQuantity({
                                  "name": items[index]["name"],
                                  "price": items[index]["price"],
                                  "quantity":
                                      (snapshot.data![index]["quantity"] ?? 0) -
                                          1,
                                });
                              }
                            },
                            icon: const Icon(Icons.remove),
                          ),
                          Text("${snapshot.data![index]["quantity"] ?? 0.0}"),
                          IconButton(
                            onPressed: () {
                              ticket.changeQuantity({
                                "name": items[index]["name"],
                                "price": items[index]["price"],
                                "quantity":
                                    (snapshot.data![index]["quantity"] ?? 0.0) +
                                        1.0,
                              });
                            },
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text("Preview ticket de caisse"),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Container(
                          color: Colors.white,
                          child: Column(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  itemCount: filtredList?.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text(filtredList![index]["name"]),
                                      subtitle: Text(
                                          "${filtredList[index]["price"]}€ x ${filtredList[index]["quantity"]}"),
                                      trailing: Text(
                                          "${filtredList[index]["price"] * filtredList[index]["quantity"]}€"),
                                    );
                                  },
                                ),
                              ),
                              if (filtredList?.isNotEmpty ?? false)
                                ListTile(
                                  title: Text("Total"),
                                  trailing: Text("$total€"),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                        onPressed: filtredList?.isEmpty ?? false
                            ? null
                            : () async {
                                final scannerController = ScannerController(
                                  scannerResult: (result) async {
                                    if (scanWaiting) return;
                                    scanWaiting = true;
                                    Navigator.of(context).pop();
                                    await supabase.from('tickets').insert({
                                      "user": result,
                                      "data": {
                                        "total": total,
                                        "items":
                                            "${jsonEncode(filtredList?.map((e) => e..remove("color")).toList())}"
                                      },
                                    });
                                    clearTicket();
                                  },
                                );
                                scanWaiting = false;
                                scannerController.startCamera();
                                await showDialog(
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
                                          platformScannerController:
                                              scannerController,
                                        ),
                                      ),
                                    );
                                  },
                                );
                                scannerController.stopCamera();
                              },
                        child: const Text("Générer le ticket")),
                  )
                ],
              )
            ],
          );
        },
      ),
    );
  }

  @override
  // TODO: implement icon
  IconData get icon => Icons.receipt_long;

  @override
  // TODO: implement name
  String get name => 'Ticket';

  @override
  // TODO: implement route
  String get route => '/ticket';
}
