import 'package:app_segna_ore/providers/auth.dart';
import 'package:app_segna_ore/widgets/flat_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget buildListTile(IconData icon, String text, Function tapHandler) {
      return ListTile(
        leading: Icon(
          icon,
          size: 25,
        ),
        title: Text(
          text,
          style: const TextStyle(
            //fontFamily: 'Lato',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: tapHandler,
      );
    }

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            alignment: Alignment.bottomLeft,
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            height: 120,
            child: Text(
              'Time Manager',
              style: TextStyle(
                color: Theme.of(context).accentColor,
                fontSize: 30,
                fontWeight: FontWeight.w900,
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
