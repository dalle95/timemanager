import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/work_orders.dart';
import '../providers/work_order.dart';

import '../screens/wo_detail_screen.dart';

import '../widgets/flat_button.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/badge.dart';
import '../widgets/main_drawer.dart';
import '../widgets/wo_list.dart';

class WOListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future<void> _refreshProducts(BuildContext context) async {
      await Provider.of<WorkOrders>(context, listen: false)
          .fetchAndSetWorkOrders();
    }

    return Scaffold(
      appBar: AppBar(
        title: Consumer<WorkOrders>(
            builder: (_, wo, ch) => Badge(
                  child: ch,
                  value: wo.itemCount.toString(),
                ),
            child: Text('Attività')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(WoDetailScreen.routeName);
            },
          ),
        ],
      ),
      drawer: MainDrawer(),
      body: RefreshIndicator(
        onRefresh: () => _refreshProducts(context),
        child: FutureBuilder(
          future: Provider.of<WorkOrders>(context, listen: false)
              .fetchAndSetWorkOrders(),
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
                return WOList();
              }
            }
          },
        ),
      ),
    );
  }
}
