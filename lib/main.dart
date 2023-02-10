import 'package:bill_e/pages/home.dart';
import 'package:bill_e/tools.dart';
import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

/*
Pitch :
Projet Bill-e (solutions de dématérialisation de ticket de caisse et gestions des achats)
Rassembler tous vos tickets de caisses au même endroit ?
En plus de vos Cartes de fidélités, Bons d'achats, Cartes Cadeaux, Garanties et Catalogues.
Pouvoir Suivre et Analyser en quelques clics l'intégralité de vos dépenses.
Et faites des économies en retrouvant vos produits habituels aux meilleurs prix
*/

/*
Base de données : Supabase
*/

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    debug: false,
    url: "https://nhwbvtaboiaxcthybswr.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5od2J2dGFib2lheGN0aHlic3dyIiwicm9sZSI6ImFub24iLCJpYXQiOjE2NzQyMjk4MTMsImV4cCI6MTk4OTgwNTgxM30.Ui3NuTipZHU8W88uLn1Fh5QrR6fdDyvDRfXn_saXbR0",
  );
  await supabase.auth
      .signInWithPassword(email: "user@bill-e.fr", password: "password");

  runApp(const Main());
}

//Application avec 2 modes : Client et Commercant
//Client : Visualise ses tickets de caisses en temps réel depuis la base de données
//Commercant : Scan le QrCode de l'ulisateur et envoie le ticket de caisse dans la base de données en l'associant à l'utilisateur
class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
