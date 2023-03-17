import 'package:bill_e/abstracts/navigation_page.dart';
import 'package:bill_e/pages/sections/client.dart';
import 'package:bill_e/pages/sections/commercant.dart';
import 'package:bill_e/pages/sections/ticket.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    //Page basic avec un bottom navigation bar pour naviguer entre client et commercant

    const pages = <NavigationPage>[
      ClientPage(),
      CommercantPage(),
      TicketPage(),
    ];

    final pageNotifier = ValueNotifier(0);

    return ValueListenableBuilder(
      valueListenable: pageNotifier,
      builder: (context, value, child) => Scaffold(
          body: pages[value],
          bottomNavigationBar: BottomNavigationBar(
            onTap: (index) => pageNotifier.value = index,
            currentIndex: value,
            items: pages
                .map(
                  (e) => BottomNavigationBarItem(
                    icon: Icon(e.icon),
                    label: e.name,
                  ),
                )
                .toList(),
          )),
    );
  }
}
