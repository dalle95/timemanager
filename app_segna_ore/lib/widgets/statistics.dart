import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/worktimes.dart';

import '../widgets/flat_button.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/statistics_grid.dart';

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
    _periodoRiferimento = DateFormat("yyyy-MM").format(_mese);
    super.initState();
  }

  void _modificaMese(String funzione) {
    if (funzione == "meno") {
      setState(() {
        _mese = DateTime(_mese.year, _mese.month - 1, 1);
        _meseInt = DateTime(_mese.year, _mese.month, 1).month;
        _annoInt = DateTime(_mese.year, _mese.month, 1).year;
        _meseStringa = "${_nomeMese(_meseInt)}, ${_annoInt.toString()}";
        _periodoRiferimento = DateFormat("yyyy-MM").format(_mese);
      });
    } else {
      setState(() {
        _mese = DateTime(_mese.year, _mese.month + 1, 1);
        _meseInt = DateTime(_mese.year, _mese.month, 1).month;
        _annoInt = DateTime(_mese.year, _mese.month, 1).year;
        _meseStringa = "${_nomeMese(_meseInt)}, ${_annoInt.toString()}";
        _periodoRiferimento = DateFormat("yyyy-MM").format(_mese);
      });
    }
  }

  Future<void> _refreshWorkTimes(
      BuildContext context, String periodoRiferimento) async {
    print(periodoRiferimento);
    Map<String, String> filtro = {'periodoCompetenza': periodoRiferimento};
    await Provider.of<WorkTimes>(context, listen: false)
        .fetchAndSetFilteredWorkTimes(filtro);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColorDark,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0, 1],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: SizedBox(
          height: 200,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                // height: 100,
                child: Container(
                  alignment: Alignment.bottomLeft,
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                  ),
                  width: double.infinity,
                  child: Text(
                    'Statistiche mensili',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.background,
                      fontSize: 30,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                //height: 100,
                child: Container(
                  alignment: Alignment.center,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 100,
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
                      ),
                      Expanded(
                        flex: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.background,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5)),
                          ),
                          child: Center(
                            child: Text(
                              _meseStringa,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 100,
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
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 7,
                //height: 500,
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  //shrinkWrap: true,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      //padding: const EdgeInsets.all(20),
                      width: 350,
                      height: 520,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 15,
                              right: 15,
                              top: 10,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: const [
                                Text(
                                  'Lu',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Ma',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Me',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Gi',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Ve',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 460,
                            child: FutureBuilder(
                              future: _refreshWorkTimes(
                                  context, _periodoRiferimento),
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
                                if (dataSnapshot.connectionState ==
                                    ConnectionState.done) {
                                  if (dataSnapshot.connectionState ==
                                      ConnectionState.done) {
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
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
