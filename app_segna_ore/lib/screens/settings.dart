import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../providers/auth.dart';

// ignore: must_be_immutable
class Settings extends StatelessWidget {
  // Definizione variabile per estrarre informazioni app
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );

  // Funzione per estrarre le informazioni app
  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    _packageInfo = info;
  }

  @override
  Widget build(BuildContext context) {
    Widget buildListTile(IconData icon, String text, Function tapHandler) {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: const BorderRadius.all(
            Radius.circular(5),
          ),
        ),
        child: ListTile(
          leading: Icon(
            icon,
            size: 25,
          ),
          title: Text(
            text,
            style: const TextStyle(
              //fontFamily: 'Lato',
              fontSize: 20,
              //fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () => tapHandler(),
        ),
      );
    }

    Future<void> _mostraMessaggioLogOut() async {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Logout'),
          content: const Text('Disconnettersi dall\'applicazione?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Provider.of<Auth>(context, listen: false).logoout();
              },
              child: const Text('Conferma'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annulla'),
            )
          ],
        ),
      );
    }

    Future<void> _mostraMessaggioInfoApp() async {
      TextStyle linkStyle = TextStyle(color: Colors.blue);

      await _initPackageInfo();

      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Informazioni'),
          content: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 20),
                  text:
                      "Versione ${_packageInfo.version} Build: ${_packageInfo.buildNumber}\n\n",
                ),
                const TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 15),
                  text: "Per maggiori informazioni visita il ",
                ),
                TextSpan(
                  style: linkStyle,
                  text: "sito ufficiale",
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      const url =
                          'https://sites.google.com/injenia.it/timemanager/versioni';
                      // Apertura link nel browser di default
                      await launchUrl(
                        Uri.parse(url),
                      );
                    },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Conferma'),
            ),
          ],
        ),
      );
    }

    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColorDark,
            // Color.fromRGBO(255, 121, 0, 1),
            // Colors.black,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0, 1],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: SizedBox(
          height: 200,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                // height: 100,
                child: Container(
                  alignment: Alignment.bottomLeft,
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                  ),
                  width: double.infinity,
                  child: Text(
                    'Altro',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.background,
                      fontSize: 30,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 8,
                child: ListView(padding: const EdgeInsets.all(20), children: [
                  buildListTile(
                    Icons.info,
                    'Informazioni App',
                    () {
                      _mostraMessaggioInfoApp();
                    },
                  ),
                  const SizedBox(height: 10),
                  buildListTile(
                    Icons.logout,
                    'Logout',
                    () {
                      _mostraMessaggioLogOut();
                    },
                  ),
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }
}
