import 'package:flutter/material.dart';

import 'detail/task_detail.dart';
import 'detail/worktime_detail.dart';

import 'list/task_list_screen.dart';
import 'list/worktime_list_screen.dart';

class Homepage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);

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
      child: Center(
        child: Container(
          alignment: Alignment.center,
          height: mediaQuery.size.height * 0.55, //430,
          width: mediaQuery.size.height * 0.4, //320,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                child: Icon(
                  Icons.access_time_filled_outlined,
                  size: mediaQuery.size.height * 0.09,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(height: mediaQuery.size.height * 0.03),
              Container(
                alignment: Alignment.center,
                child: SizedBox(
                  width: mediaQuery.size.height * 0.32,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        WorkTimeDetailScreen.routeName,
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        'Registra ore',
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: mediaQuery.size.height * 0.03),
              Container(
                alignment: Alignment.center,
                child: SizedBox(
                  width: mediaQuery.size.height * 0.32,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        TaskDetailScreen.routeName,
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        'Crea ticket',
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: mediaQuery.size.height * 0.03),
              Container(
                alignment: Alignment.center,
                child: SizedBox(
                  width: mediaQuery.size.height * 0.32,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        TaskListScreen.routeName,
                        arguments: {'function': 'list'},
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        'Ticket assegnati',
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: mediaQuery.size.height * 0.03),
              Container(
                alignment: Alignment.center,
                child: SizedBox(
                  width: mediaQuery.size.height * 0.32,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        WorkTimeListScreen.routeName,
                        arguments: {'function': 'list'},
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        'Ore caricate',
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
