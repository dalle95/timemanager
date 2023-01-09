import 'package:app_segna_ore/providers/worktimes.dart';
import 'package:app_segna_ore/widgets/flat_button.dart';
import 'package:app_segna_ore/widgets/loading_indicator.dart';
import 'package:app_segna_ore/widgets/statistics_grid.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Statistics extends StatefulWidget {
  @override
  State<Statistics> createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  DateTime _mese = DateTime.now();
  int _meseInt = DateTime(DateTime.now().year, DateTime.now().month, 1).month;
  int _annoInt = DateTime(DateTime.now().year, DateTime.now().month, 1).year;
  String _periodoRiferimento;
  String _meseStringa;

  String _nomeMese(int meseInt) {
    switch (meseInt) {
      case 1:
        return "Gennaio";
      case 2:
        return "Febbraio";
      case 3:
        return "Marzo";
      case 4:
        return "Aprile";
      case 5:
        return "Maggio";
      case 6:
        return "Giugno";
      case 7:
        return "Luglio";
      case 8:
        return "Agosto";
      case 9:
        return "Settembre";
      case 10:
        return "Ottobre";
      case 11:
        return "Novembre";
      default:
        return "Dicembre";
    }
  }

  @override
  void initState() {
    _meseStringa = "${_nomeMese(_meseInt)}, ${_annoInt.toString()}";
    _periodoRiferimento = DateFormat("MM/yyyy").format(_mese);
    super.initState();
  }

  void _modificaMese(String funzione) {
    if (funzione == "meno") {
      setState(() {
        _mese = DateTime(_mese.year, _mese.month - 1, 1);
        _meseInt = DateTime(_mese.year, _mese.month, 1).month;
        _annoInt = DateTime(_mese.year, _mese.month, 1).year;
        _meseStringa = "${_nomeMese(_meseInt)}, ${_annoInt.toString()}";
        _periodoRiferimento = DateFormat("MM/yyyy").format(_mese);
      });
    } else {
      setState(() {
        _mese = DateTime(_mese.year, _mese.month + 1, 1);
        _meseInt = DateTime(_mese.year, _mese.month, 1).month;
        _annoInt = DateTime(_mese.year, _mese.month, 1).year;
        _meseStringa = "${_nomeMese(_meseInt)}, ${_annoInt.toString()}";
        _periodoRiferimento = DateFormat("MM/yyyy").format(_mese);
      });
    }
  }

  Future<void> _refreshWorkTimes(
      BuildContext context, String periodoRiferimento) async {
    await Provider.of<WorkTimes>(context, listen: false)
        .fetchAndSetWorkTimes(periodoRiferimento);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColorDark,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0, 1],
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            alignment: Alignment.bottomLeft,
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            height: 120,
            child: Text(
              'Statistiche mensili',
              style: TextStyle(
                color: Theme.of(context).colorScheme.background,
                fontSize: 30,
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 10),
            width: 350,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: FlatButton(
                    () {
                      _modificaMese('meno');
                    },
                    Icon(
                      Icons.arrow_back,
                      size: 25,
                      color: Theme.of(context).colorScheme.background,
                    ),
                    Colors.transparent,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Container(
                  width: 220,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                  ),
                  child: Center(
                      child: Text(
                    '$_meseStringa',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.blueAccent,
                    ),
                  )),
                ),
                const SizedBox(
                  width: 10,
                ),
                SizedBox(
                  width: 50,
                  height: 50,
                  child: FlatButton(
                    () {
                      _modificaMese('più');
                    },
                    Icon(
                      Icons.arrow_forward,
                      size: 25,
                      color: Theme.of(context).colorScheme.background,
                    ),
                    Colors.transparent,
                  ),
                )
              ],
            ),
          ),
          Container(
            alignment: Alignment.center,
            //padding: const EdgeInsets.all(20),
            width: 350,
            height: 480,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: FutureBuilder(
              future: _refreshWorkTimes(context, _periodoRiferimento),
              builder: (ctx, dataSnapshot) {
                // if (dataSnapshot.connectionState == ConnectionState.waiting &&
                //     dataSnapshot.connectionState != ConnectionState.done) {
                //   return LoadingIndicator('In caricamento!');
                // } else {
                //   if (dataSnapshot.error != null) {
                //     return const Center(
                //       child: Text('Si è verificato un errore.'),
                //     );
                //     //Error
                //   } else {
                //     return StatisticsGrid(_mese);
                //   }
                // }
                if (dataSnapshot.connectionState == ConnectionState.done) {
                  if (dataSnapshot.connectionState == ConnectionState.done) {
                    return StatisticsGrid(_mese);
                  } else {
                    return const Center(
                      child: Text('Si è verificato un errore.'),
                    );
                  }
                } else {
                  return LoadingIndicator('In caricamento!');
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
