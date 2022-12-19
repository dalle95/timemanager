import 'package:app_segna_ore/screens/detail/worktime_detail.dart';
import 'package:app_segna_ore/screens/list/worktime_list_screen.dart';
import 'package:flutter/material.dart';

import '../screens/detail/task_detail.dart';
import '../screens/list/task_list_screen.dart';

import '../widgets/raise_button.dart';

class Homepage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Color.fromARGB(255, 11, 50, 113),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0, 1],
        ),
      ),
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 50.0),
              child: Text(
                'Time Manager',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 50),
          Container(
            alignment: Alignment.center,
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
              Theme.of(context).accentColor,
            ),
          ),
          const SizedBox(height: 50),
          Container(
            alignment: Alignment.center,
            child: RaiseButton(
              () {
                Navigator.of(context).pushNamed(
                  TaskListScreen.routeName,
                  arguments: {'function': 'search'},
                );
              },
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  'Task assegnati',
                  style: TextStyle(fontSize: 25),
                ),
              ),
              Theme.of(context).accentColor,
            ),
          ),
          const SizedBox(height: 50),
          Container(
            alignment: Alignment.center,
            child: RaiseButton(
              () {
                Navigator.of(context).pushNamed(
                  WorkTimeListScreen.routeName,
                  arguments: {'function': 'search'},
                );
              },
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  'Ore caricate',
                  style: TextStyle(fontSize: 25),
                ),
              ),
              Theme.of(context).accentColor,
            ),
          ),
        ],
      ),
    );
  }
}
