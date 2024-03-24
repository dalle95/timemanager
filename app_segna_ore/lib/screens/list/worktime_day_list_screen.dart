import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/worktime.dart';

import '../../providers/worktimes.dart';

import '../../screens/detail/worktime_detail.dart';

import '../../widgets/lists/worktime_day_list.dart';
import '../../widgets/loading_indicator.dart';

class WorkTimeDayListScreen extends StatelessWidget {
  static const routeName = '/worktime-day-list';

  @override
  Widget build(BuildContext context) {
    var functionData =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    DateTime giorno = DateTime.now();

    List<WorkTime> workTimes = [];

    // Controllo cosa viene passato a questa pagina e definisco il filtro
    if (functionData.containsKey("periodoCompetenza")) {
      giorno = DateTime.parse(
        functionData['periodoCompetenza'],
      );
    }

    // Funzione per scaricare i risultati
    Future<void> _refreshWorkTimes(
      BuildContext context,
      DateTime giorno,
    ) async {
      workTimes = await Provider.of<WorkTimes>(context, listen: false)
          .workTimesDaily(giorno);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ore caricate'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(
                WorkTimeDetailScreen.routeName,
                arguments: {
                  'giornoCompetenza': DateFormat("yyyy-MM-dd").format(giorno)
                },
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshWorkTimes(context, giorno),
        child: FutureBuilder(
          future: _refreshWorkTimes(context, giorno),
          builder: (ctx, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return LoadingIndicator('In caricamento!');
            } else {
              if (dataSnapshot.error != null) {
                return RefreshIndicator(
                  onRefresh: () => _refreshWorkTimes(context, giorno),
                  child: Center(
                    child: Text('Si è verificato un errore.'),
                  ),
                );
              } else {
                return WorkTimeDayList(
                  workTimes: workTimes,
                );
              }
            }
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(
            WorkTimeDetailScreen.routeName,
            arguments: {
              'giornoCompetenza': DateFormat("yyyy-MM-dd").format(giorno)
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
