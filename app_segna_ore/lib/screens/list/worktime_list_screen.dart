import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/worktimes.dart';
import '../../screens/detail/worktime_detail.dart';
import '../../widgets/worktime_list.dart';
import '../../widgets/loading_indicator.dart';

class WorkTimeListScreen extends StatelessWidget {
  static const routeName = '/worktime-list';

  @override
  Widget build(BuildContext context) {
    Future<void> _refresWorktimes(
        BuildContext context, String periodoRiferimento) async {
      await Provider.of<WorkTimes>(context, listen: false)
          .fetchAndSetWorkTimes(periodoRiferimento);
    }

    var functionData =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    var function = functionData['function'];

    final DateTime _mese = DateTime.now();
    final String _periodoRiferimento = DateFormat("MM/yyyy").format(_mese);

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
              Navigator.of(context).pushNamed(WorkTimeDetailScreen.routeName);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refresWorktimes(context, _periodoRiferimento),
        child: FutureBuilder(
          future: Provider.of<WorkTimes>(context, listen: false)
              .fetchAndSetWorkTimes(_periodoRiferimento),
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
          Navigator.of(context).pushNamed(WorkTimeDetailScreen.routeName);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
