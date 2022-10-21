import 'package:carl_touch_api/widgets/actiontype_list.dart';
import 'package:carl_touch_api/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/actiontype.dart';
import '../providers/actiontypes.dart';

class ActionTypeListScreen extends StatelessWidget {
  static const routeName = '/search-list';

  @override
  Widget build(BuildContext context) {
    Future<void> _refreshActionTypes(BuildContext context) async {
      await Provider.of<ActionTypes>(context, listen: false)
          .fetchAndSetActiontypes();
    }

    final actionTypeData = Provider.of<ActionTypes>(context, listen: false);
    final actiontypes = actionTypeData.actionTypes;

    return Scaffold(
      appBar: AppBar(
        title: Text('Elenco'),
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
