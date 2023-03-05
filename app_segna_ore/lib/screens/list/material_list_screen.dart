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
    print('Costruzione lista');

    Future<void> _refreshMaterials(BuildContext context, String cliente) async {
      await Provider.of<Materials>(context, listen: false)
          .fetchAndSetMaterials(cliente);
    }

    var arguments =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    var function = arguments['function'];
    var cliente = arguments['cliente'];

    //var mediaQuery = MediaQuery.of(context);

    void mostraDialogoFiltro() {
      showDialog(
        context: context,
        builder: (_) {
          var filtroController = TextEditingController();
          return SizedBox(
            height: 100, //mediaQuery.size.height * 0.1,
            width: 100, //mediaQuery.size.width * 0.5,
            child: AlertDialog(
              title: const Text('Filtro'),
              content: SizedBox(
                height: 100, //mediaQuery.size.height * 0.1,
                width: 100, //mediaQuery.size.width * 0.5,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    TextFormField(
                      controller: filtroController,
                      decoration: const InputDecoration(hintText: 'Codice'),
                      onFieldSubmitted: (_) async {
                        cliente = filtroController.text;

                        Navigator.pop(context);
                        await _refreshMaterials(context, cliente);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annulla'),
                ),
                TextButton(
                  onPressed: () {
                    cliente = filtroController.text;

                    Navigator.pop(context);
                    _refreshMaterials(context, cliente);
                  },
                  child: const Text('Cerca'),
                ),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: mostraDialogoFiltro,
            icon: const Icon(Icons.search),
          )
        ],
        title: Consumer<Materials>(
            builder: (_, material, ch) => Badge(
                  child: ch,
                  value: material.itemCount.toString(),
                ),
            child: const Text('Commesse attive')),
        backgroundColor: Theme.of(context).colorScheme.primary,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.add),
        //     onPressed: () {
        //       Navigator.of(context).pushNamed(BoxDetailScreen.routeName);
        //     },
        //   ),
        // ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshMaterials(context, cliente),
        child: FutureBuilder(
          future: Provider.of<Materials>(context, listen: false)
              .fetchAndSetMaterials(cliente),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
                    'statusCode': '',
                    'responsabile': {'id': null, 'code': '', 'nome': ''}
                  },
                );
              })
          : null,
    );
  }
}
