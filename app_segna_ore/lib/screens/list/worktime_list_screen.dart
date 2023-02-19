import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/worktimes.dart';
import '../../screens/detail/worktime_detail.dart';
import '../../widgets/worktime_list.dart';
import '../../widgets/loading_indicator.dart';

class WorkTimeListScreen extends StatelessWidget {
  static const routeName = '/worktime-list';

  Future<void> _refreshWorkTimes(
      BuildContext context, Map<String, String> filtro) async {
    await Provider.of<WorkTimes>(context, listen: false)
        .fetchAndSetFilteredWorkTimes(filtro);
  }

  @override
  Widget build(BuildContext context) {
    var functionData =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    var function = functionData['function'];
    String woID;
    Map<String, String> filtro;

    if (functionData.containsKey("filter")) {
      if (functionData['filter'].containsKey("wo_id")) {
        woID = functionData['filter']['wo_id'];
        filtro = {'wo_id': woID};
      }
    } else {
      final DateTime mese = DateTime.now();
      final String periodoRiferimento = DateFormat("MM/yyyy").format(mese);
      filtro = {'periodoCompetenza': periodoRiferimento};
    }

    return Scaffold(
      appBar: AppBar(
        // title: Consumer<Occupations>(
        //     builder: (_, occupation, ch) => Badge(
        //           child: ch,
        //           value: occupation.itemCount.toString(),
        //         ),
        //     child: const Text('')),
        title: const Text('Ore caricate'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(
                WorkTimeDetailScreen.routeName,
                arguments: woID != null ? {'wo_id': woID} : null,
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshWorkTimes(context, filtro),
        child: FutureBuilder(
          future: _refreshWorkTimes(context, filtro),
          builder: (ctx, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return LoadingIndicator('In caricamento!');
            } else {
              if (dataSnapshot.error != null) {
                return const Center(
                  child: Text('Si è verificato un errore.'),
                );
                //Error
              } else {
                return WorkTimeList();
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
            arguments: woID != null ? {'wo_id': woID} : null,
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
