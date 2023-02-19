import 'package:app_segna_ore/screens/list/task_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_segna_ore/providers/auth.dart';
import 'package:app_segna_ore/widgets/flat_button.dart';

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
    final actorName = Provider.of<Auth>(context, listen: false).user.nome;

    return Drawer(
      child: Column(
        children: [
          Container(
            alignment: Alignment.bottomLeft,
            color: Theme.of(context).primaryColor,
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            height: 120,
            child: Text(
              'Better Touch',
              style: TextStyle(
                color: Theme.of(context).accentColor,
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          buildListTile(
            Icons.work,
            'Ore inserite',
            () {
              Navigator.of(context).pushNamed(
                TaskListScreen.routeName,
                arguments: {'function': 'search'},
              );
            },
          ),
          const Divider(),
          buildListTile(
            Icons.auto_graph,
            'Statistiche',
            () {
              Navigator.of(context).pushNamed(
                TaskListScreen.routeName,
                arguments: {'function': 'search'},
              );
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
