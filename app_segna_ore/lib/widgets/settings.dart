import 'package:app_segna_ore/providers/auth.dart';
import 'package:app_segna_ore/widgets/flat_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Settings extends StatelessWidget {
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
          onTap: tapHandler,
        ),
      );
    }

    return Container(
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
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            alignment: Alignment.bottomLeft,
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            height: 120,
            child: Text(
              'Altro',
              style: TextStyle(
                color: Theme.of(context).colorScheme.background,
                fontSize: 30,
              ),
            ),
          ),
          buildListTile(
            Icons.logout,
            'Logout',
            () async {
              await showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Disconnettersi dall\'applicazione?'),
                  actions: [
                    FlatButton(
                      () {
                        Navigator.of(context).pop();
                        Provider.of<Auth>(context, listen: false).logoout();
                      },
                      const Text('Conferma'),
                    ),
                    FlatButton(
                      () {
                        Navigator.of(context).pop();
                      },
                      const Text('Annulla'),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
