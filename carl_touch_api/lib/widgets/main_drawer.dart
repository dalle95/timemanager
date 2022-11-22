import 'package:carl_touch_api/providers/auth.dart';
import 'package:carl_touch_api/screens/box_list_screen.dart';
import 'package:carl_touch_api/widgets/flat_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainDrawer extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    final actorName = Provider.of<Auth>(context, listen: false).actorName;

    return Drawer(
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            color: Theme.of(context).primaryColor,
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            height: 70,
            child: Text(
              'Better Touch',
              style: TextStyle(
                color: Theme.of(context).accentColor,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          buildListTile(
            Icons.account_circle_outlined,
            'Utente: $actorName',
            () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          const Divider(),
          buildListTile(
            Icons.work,
            'Attività',
            () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          const Divider(),
          buildListTile(
            Icons.location_searching,
            'Localizzazioni',
            () {
              Navigator.of(context).pushReplacementNamed(
                  BoxListScreen.routeName,
                  arguments: {'function': 'list'});
            },
          ),
          const Divider(),
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
