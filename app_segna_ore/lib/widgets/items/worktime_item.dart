import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../errors/http_exception.dart';

import '../../../providers/worktimes.dart';

import '../../../models/worktime.dart';

import '../../../screens/detail/worktime_detail.dart';

class WorkTimeItem extends StatefulWidget {
  final WorkTime workTime;

  WorkTimeItem(
    this.workTime,
  );

  @override
  State<WorkTimeItem> createState() => _WorkTimeItemState();
}

format(Duration d) =>
    d.toString().split('.').first.padLeft(8, "0").substring(0, 5);

class _WorkTimeItemState extends State<WorkTimeItem> {
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Si è verificato un errore'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Conferma'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showConfirmDialog() async {
    var scaffold = ScaffoldMessenger.of(context);
    return await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Attenzione'),
        content: const Text('Procedere con la rimozione dell\'occupazione?'),
        actions: [
          TextButton(
            onPressed: () {
              scaffold.hideCurrentSnackBar();
              scaffold.showSnackBar(
                const SnackBar(
                  content: Text('WorkTime rimosso'),
                  duration: Duration(
                    seconds: 2,
                  ),
                ),
              );
              Navigator.of(ctx).pop(true);
            },
            child: const Text('Conferma'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(false);
            },
            child: const Text('Annulla'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          WorkTimeDetailScreen.routeName,
          arguments: {'worktime_id': widget.workTime.id},
        );
      },
      child: Dismissible(
        key: ValueKey(widget.workTime.id),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          try {
            Provider.of<WorkTimes>(context, listen: false)
                .deleteWorkTime(widget.workTime.id!);
          } on HttpException catch (error) {
            // Errore con messaggio
            _showErrorDialog(error.toString());
          } catch (error) {
            // Errore generico
            print(error);
            _showErrorDialog(
                'Qualcosa è andato storto.. Anche ai migliori capita di sbagliare.');
          }
        },
        confirmDismiss: (direction) => _showConfirmDialog(),
        background: Container(
          color: Theme.of(context).colorScheme.error,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(
            right: 20,
          ),
          child: const Icon(
            Icons.cancel,
            color: Colors.white,
            size: 30,
          ),
        ),
        child: Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: ListTile(
              leading: Icon(
                Icons.alarm,
                color: Theme.of(context).colorScheme.secondary,
                size: 40,
              ),
              title: Text(
                DateFormat('dd/MM/yyyy').format(widget.workTime.data),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.workTime.commessa.description,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.workTime.note,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // Container(
                //   child: Column(
                //     children: [
                //       Text(
                //         'Lavorato',
                //         style: TextStyle(
                //             color: Theme.of(context).colorScheme.secondary,
                //             fontWeight: FontWeight.bold),
                //       ),
                //       Text(
                //         format(widget.workTime.tempoLavorato),
                //         style: const TextStyle(
                //           color: Colors.black,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
              ),
              trailing: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Lavorato',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      format(widget.workTime.tempoFatturato),
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
