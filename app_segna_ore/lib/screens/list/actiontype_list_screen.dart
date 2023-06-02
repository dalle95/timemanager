import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/actiontypes.dart';

import '../../widgets/lists/actiontype_list.dart';
import '../../widgets/loading_indicator.dart';

class ActionTypeListScreen extends StatelessWidget {
  static const routeName = '/search-list';

  @override
  Widget build(BuildContext context) {
    Future<void> _refreshActionTypes(BuildContext context) async {
      await Provider.of<ActionTypes>(context, listen: false)
          .fetchAndSetActiontypes();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Elenco'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshActionTypes(context),
        child: FutureBuilder(
          future: Provider.of<ActionTypes>(context, listen: false)
              .fetchAndSetActiontypes(),
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
                return ActiontypeList();
              }
            }
          },
        ),
      ),
    );
  }
}
