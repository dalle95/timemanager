import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/boxes.dart';

import '../../screens/detail/box_detail_screen.dart';

import '../../widgets/loading_indicator.dart';
import '../../widgets/badge.dart';
import '../../widgets/lists/box_list.dart';

class BoxListScreen extends StatelessWidget {
  static const routeName = '/box-list';

  @override
  Widget build(BuildContext context) {
    Future<void> _refreshProducts(BuildContext context) async {
      await Provider.of<Boxes>(context, listen: false).fetchAndSetBoxes();
    }

    var functionData =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    var function = functionData['function'];

    return Scaffold(
      appBar: AppBar(
        title: Consumer<Boxes>(
            builder: (_, box, ch) => BadgeWidget(
                  value: box.itemCount.toString(),
                  child: ch!,
                ),
            child: const Text('Punti di struttura')),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(BoxDetailScreen.routeName);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshProducts(context),
        child: FutureBuilder(
          future: Provider.of<Boxes>(context, listen: false).fetchAndSetBoxes(),
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
                return BoxList(function);
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
              },
            )
          : null,
    );
  }
}
