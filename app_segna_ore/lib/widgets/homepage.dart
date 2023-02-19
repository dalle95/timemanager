import 'package:app_segna_ore/screens/detail/task_detail.dart';
import 'package:flutter/material.dart';

import '../screens/list/task_list_screen.dart';
import '../screens/detail/worktime_detail.dart';
import '../screens/list/worktime_list_screen.dart';

import '../widgets/raise_button.dart';

class Homepage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColorDark,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0, 1],
        ),
      ),
      alignment: Alignment.center,
      child: Stack(children: [
        Center(
          child: Container(
            alignment: Alignment.center,
            height: 430,
            width: 320,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              color: Theme.of(context).colorScheme.background,
              //shape: BoxShape.circle,
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              child: Icon(
                Icons.access_time_filled_outlined,
                size: 60,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              alignment: Alignment.center,
              child: SizedBox(
                width: 250,
                child: RaiseButton(
                  () {
                    Navigator.of(context).pushNamed(
                      WorkTimeDetailScreen.routeName,
                    );
                  },
                  const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'Registra ore',
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                  Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              alignment: Alignment.center,
              child: SizedBox(
                width: 250,
                child: RaiseButton(
                  () {
                    Navigator.of(context).pushNamed(
                      TaskDetailScreen.routeName,
                    );
                  },
                  const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'Crea ticket',
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                  Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              alignment: Alignment.center,
              child: SizedBox(
                width: 250,
                child: RaiseButton(
                  () {
                    Navigator.of(context).pushNamed(
                      TaskListScreen.routeName,
                      arguments: {'function': 'list'},
                    );
                  },
                  const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'Ticket assegnati',
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                  Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              alignment: Alignment.center,
              child: SizedBox(
                width: 250,
                child: RaiseButton(
                  () {
                    Navigator.of(context).pushNamed(
                      WorkTimeListScreen.routeName,
                      arguments: {'function': 'list'},
                    );
                  },
                  const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'Ore caricate',
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                  Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ],
        ),
      ]),
    );
  }
}
