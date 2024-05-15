import 'dart:math';

import 'package:app_segna_ore/providers/worktimes.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class CaricoLavoroPerCommessa extends StatelessWidget {
  const CaricoLavoroPerCommessa({
    Key? key,
    required this.mediaQuery,
  }) : super(key: key);

  final MediaQueryData mediaQuery;

  @override
  Widget build(BuildContext context) {
    final List<Map> caricoXCommessa =
        Provider.of<WorkTimes>(context).calcolaCarichi();

    Logger().d(caricoXCommessa);

    return Container(
      alignment: Alignment.center,
      height: max(
        Provider.of<WorkTimes>(context).calcolaCarichi().length * 40.0 + 250.0,
        120,
      ),
      width: mediaQuery.size.width * 0.4,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 15,
          right: 15,
          top: 20,
        ),
        child: Column(
          children: [
            const Text(
              'Carico di lavoro per Commessa:',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (caricoXCommessa.length != 0)
              Expanded(
                child: GraficoATorta(caricoXCommessa: caricoXCommessa),
              ),
            if (caricoXCommessa.length == 0)
              Expanded(
                child: Center(
                  child: Text('Non ci sono fasce caricate'),
                ),
              )
          ],
        ),
      ),
    );
  }
}

class GraficoATorta extends StatefulWidget {
  GraficoATorta({
    Key? key,
    required this.caricoXCommessa,
  }) : super(key: key);

  final List<Map> caricoXCommessa;

  @override
  State<StatefulWidget> createState() => _PieChart2State();
}

class _PieChart2State extends State<GraficoATorta> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 250,
          child: AspectRatio(
            aspectRatio: 1,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                sectionsSpace: 0,
                centerSpaceRadius: 40,
                sections: showingSections(widget.caricoXCommessa),
              ),
            ),
          ),
        ),
        Expanded(
          child: Column(
            children: leggenda(widget.caricoXCommessa),
          ),
        ),
      ],
    );
  }

  List<Widget> leggenda(List<Map> caricoXCommessa) {
    // Genero la lista dei record come leggenda
    List<Widget> lista = caricoXCommessa.asMap().entries.map(
      (entry) {
        int index = entry.key;
        Map elemento = entry.value;

        String commessa = elemento['commessa'];
        String ore = elemento['oreRegistrate'].toString();
        double percentuale = elemento['caricoPercentuale'];
        Color colore = elemento['colore'];

        final isTouched = index == touchedIndex;
        final otherIsTouched = isTouched == false ? touchedIndex != -1 : false;
        final fontWeight = isTouched ? FontWeight.bold : FontWeight.normal;
        final textColor = otherIsTouched ? Colors.grey : Colors.black;

        return Container(
          height: 30,
          padding: EdgeInsets.symmetric(
            vertical: 5,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  commessa,
                  softWrap: true, // Abilita il wrapping del testo
                  overflow: TextOverflow
                      .clip, // Tronca il testo se va oltre il limite
                  style: TextStyle(
                    fontWeight: fontWeight,
                    color: textColor,
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Container(
                height: 20,
                width: 20,
                color: colore,
              ),
            ],
          ),
        );
      },
    ).toList();

    return lista;
  }

  // Creazione lista dati per il grafico
  List<PieChartSectionData> showingSections(List<Map> caricoXCommessa) {
    // Genero la lista dei record da visualizzare nel grafico
    List<PieChartSectionData> listaDati = caricoXCommessa.asMap().entries.map(
      (entry) {
        int index = entry.key;
        Map elemento = entry.value;

        String commessa = elemento['commessa'];
        String ore = elemento['oreRegistrate'].toString();
        double percentuale = elemento['caricoPercentuale'];
        Color colore = elemento['colore'];

        final isTouched = index == touchedIndex;
        final otherIsTouched = isTouched == false ? touchedIndex != -1 : false;
        final textColor = otherIsTouched ? Colors.grey : Colors.black;

        final fontSize = isTouched ? 25.0 : 16.0;
        final radius = isTouched ? 60.0 : 50.0;
        const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
        final fontWeight = isTouched ? FontWeight.bold : FontWeight.normal;

        return PieChartSectionData(
          color: colore,
          titlePositionPercentageOffset: isTouched ? 1.2 : 1,
          value: percentuale,
          title: '$percentuale%',
          radius: radius,
          titleStyle: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: fontWeight,
            shadows: shadows,
          ),
        );
      },
    ).toList();

    return listaDati;
  }
}
