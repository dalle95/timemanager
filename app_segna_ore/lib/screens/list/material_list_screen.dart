import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/materials.dart';
import '../../widgets/material_list.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/badge.dart';
import '../../widgets/main_drawer.dart';

class MaterialListScreen extends StatelessWidget {
  static const routeName = '/material-list';

  @override
  Widget build(BuildContext context) {
    Future<void> _refreshMaterials(BuildContext context) async {
      await Provider.of<Materials>(context, listen: false)
          .fetchAndSetMaterials();
    }

    var functionData =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    var function = functionData['function'];

    return Scaffold(
      appBar: AppBar(
        title: Consumer<Materials>(
            builder: (_, material, ch) => Badge(
                  child: ch,
                  value: material.itemCount.toString(),
                ),
            child: const Text('Commesse attive')),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.add),
        //     onPressed: () {
        //       Navigator.of(context).pushNamed(BoxDetailScreen.routeName);
        //     },
        //   ),
        // ],
      ),
      drawer: function == 'list' ? MainDrawer() : null,
      body: RefreshIndicator(
        onRefresh: () => _refreshMaterials(context),
        child: FutureBuilder(
          future: Provider.of<Materials>(context, listen: false)
              .fetchAndSetMaterials(),
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
                return MaterialList(function);
              }
            }
          },
        ),
      ),
      floatingActionButton: function == 'search'
          ? FloatingActionButton(
              child: const Icon(Icons.disabled_by_default_rounded),
              onPressed: () {
                Navigator.of(context).pop(
                  {
                    'id': null,
                    'code': '',
                    'description': '',
                    'eqptType': '',
                    'statusCode': ''
                  },
                );
              })
          : null,
    );
  }
}
