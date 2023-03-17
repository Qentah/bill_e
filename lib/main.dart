import 'package:bill_e/pages/home.dart';
import 'package:bill_e/pages/sections/client.dart';
import 'package:bill_e/pages/sections/commercant.dart';
import 'package:bill_e/pages/sections/ticket.dart';
import 'package:bill_e/tools.dart';
import 'package:flutter/foundation.dart';
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
    url: url,
    anonKey: anonKey,
  );
  Supabase.instance.client.removeAllChannels();
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
      home: SignPage(),
    );
  }
}

class SignPage extends StatelessWidget {
  const SignPage({super.key});

  @override
  Widget build(BuildContext context) {
    //array de tickets de caisse
    const tickets = [
      {},
      {},
      {},
    ];

    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Connexion/Inscription",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            SizedBox(
              width: 300,
              child: Form(
                child: Column(
                  children: [
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: "Email",
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: "Password",
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        if (kDebugMode) {
                          await supabase.auth.signInWithPassword(
                              email: "client@test.fr", password: "testtest");
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const HomePage(),
                            ),
                          );
                          print("Sigin with email and password");
                          return;
                        }

                        print(
                          "${emailController.text}:${passwordController.text}",
                        );

                        //Try to signin with email and password if it fails try to signup
                        //exemple client@test.fr:testtest , commercant@test.fr:testtest

                        try {
                          await supabase.auth.signInWithPassword(
                            email: emailController.text,
                            password: passwordController.text,
                          );
                        } on AuthException catch (e) {
                          if (e.statusCode != "400") {
                            print(e);
                            return;
                          }
                          try {
                            await supabase.auth.signUp(
                              email: emailController.text,
                              password: passwordController.text,
                            );
                          } on AuthException catch (e) {
                            print(e);
                            return;
                          }
                          //Show dialog with title "Etes vous commercants ou clients ?" and 2 buttons "Commercant" and "Client"
                          await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text("Etes vous commercant ou client?"),
                              actions: [
                                TextButton(
                                  onPressed: () async {
                                    await supabase.from("users").upsert({
                                      "id": supabase.auth.currentUser?.id,
                                      "type": "commercant",
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Commercant"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await supabase.from("users").upsert({
                                      "id": supabase.auth.currentUser?.id,
                                      "type": "client",
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Client"),
                                ),
                              ],
                            ),
                          );
                        }

                        //Redirect user to the page depending on his type
                        final userInfo = await supabase
                            .from("users")
                            .select()
                            .eq("id", supabase.auth.currentUser?.id)
                            .single();

                        final user = User.fromJson(userInfo);
                        print(user.type);

                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => user.type == "client"
                                ? const ClientPage()
                                : const TicketPage(),
                          ),
                        );
                      },
                      child: const Text("Confirmer"),
                    ),
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

//Class for user
//Json of the user {id: 575468ce-33c3-47f1-b43d-cc9f71762478, type: client}
class User {
  final String id;
  final String type;

  User({
    required this.id,
    required this.type,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"],
      type: json["type"],
    );
  }
}
