import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/worktimes.dart';

import '../widgets/calendario_di_lavoro.dart';
import '../widgets/carico_lavoro_commessa.dart';
import '../widgets/indicatore_mese_riferimento.dart';
import '../widgets/vista_statistiche_non_pronta.dart';

class Statistics extends StatefulWidget {
  @override
  State<Statistics> createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  DateTime _mese = DateTime.now();
  int _meseInt = DateTime(DateTime.now().year, DateTime.now().month, 1).month;
  int _annoInt = DateTime(DateTime.now().year, DateTime.now().month, 1).year;
  String? _periodoRiferimento;
  String? _meseStringa;

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
    _meseStringa = "${_nomeMese(_meseInt)} ${_annoInt.toString()}";
    _periodoRiferimento = DateFormat("yyyy-MM").format(_mese);
    super.initState();
  }

  void _modificaMese(String funzione) {
    if (funzione == "meno") {
      setState(() {
        _mese = DateTime(_mese.year, _mese.month - 1, 1);
        _meseInt = DateTime(_mese.year, _mese.month, 1).month;
        _annoInt = DateTime(_mese.year, _mese.month, 1).year;
        _meseStringa = "${_nomeMese(_meseInt)} ${_annoInt.toString()}";
        _periodoRiferimento = DateFormat("yyyy-MM").format(_mese);
      });
    } else {
      setState(() {
        _mese = DateTime(_mese.year, _mese.month + 1, 1);
        _meseInt = DateTime(_mese.year, _mese.month, 1).month;
        _annoInt = DateTime(_mese.year, _mese.month, 1).year;
        _meseStringa = "${_nomeMese(_meseInt)} ${_annoInt.toString()}";
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
    var mediaQuery = MediaQuery.of(context);

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
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
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
              IndicatoreMeseRiferimento(
                meseStringa: _meseStringa!,
                modificaMese: _modificaMese,
              ),
              FutureBuilder(
                future: _refreshWorkTimes(context, _periodoRiferimento!),
                builder: (ctx, dataSnapshot) {
                  if (dataSnapshot.connectionState == ConnectionState.waiting) {
                    return VistaStatisticheNonPronta(
                      mediaQuery: mediaQuery,
                      message: 'In caricamento',
                    );
                  } else {
                    if (dataSnapshot.error != null) {
                      return VistaStatisticheNonPronta(
                        mediaQuery: mediaQuery,
                        message: 'Si è verificato un errore',
                      );
                      //Error
                    } else {
                      return Expanded(
                        flex: 7,
                        child: RefreshIndicator(
                          onRefresh: () async {
                            await _refreshWorkTimes(
                                context, _periodoRiferimento!);
                            setState(() {});
                          },
                          child: Dismissible(
                            key: ValueKey(_meseStringa),
                            onDismissed: (direction) {
                              if (direction == DismissDirection.endToStart) {
                                _modificaMese('più');
                              } else {
                                _modificaMese('meno');
                              }
                            },
                            child: ListView(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              children: [
                                CalendarioDiLavoro(
                                    mediaQuery: mediaQuery, mese: _mese),
                                SizedBox(
                                  height: mediaQuery.size.height * 0.02,
                                ),
                                CaricoLavoroPerCommessa(mediaQuery: mediaQuery),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
