import 'package:app_segna_ore/screens/detail/worktime_detail.dart';
import 'package:app_segna_ore/widgets/worktime_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/worktimes.dart';

import '../detail/task_detail.dart';

import '../../widgets/loading_indicator.dart';
import '../../widgets/badge.dart';
import '../../widgets/task_list.dart';

class WorkTimeListScreen extends StatelessWidget {
  static const routeName = '/worktime-list';

  @override
  Widget build(BuildContext context) {
    Future<void> _refreshProducts(BuildContext context) async {
      await Provider.of<WorkTimes>(context, listen: false)
          .fetchAndSetWorkTimes();
    }

    var functionData =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    var function = functionData['function'];

    return Scaffold(
      appBar: AppBar(
        // title: Consumer<Occupations>(
        //     builder: (_, occupation, ch) => Badge(
        //           child: ch,
        //           value: occupation.itemCount.toString(),
        //         ),
        //     child: const Text('')),
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
        onRefresh: () => _refreshProducts(context),
        child: FutureBuilder(
          future: Provider.of<WorkTimes>(context, listen: false)
              .fetchAndSetWorkTimes(),
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
