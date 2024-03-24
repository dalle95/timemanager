import 'dart:math';

import 'package:app_segna_ore/providers/worktimes.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class FatturazioneMensile extends StatelessWidget {
  const FatturazioneMensile({
    Key? key,
    required this.mediaQuery,
  }) : super(key: key);

  final MediaQueryData mediaQuery;

  @override
  Widget build(BuildContext context) {
    final List<Map> datiFatturazione =
        Provider.of<WorkTimes>(context).calcolaPercentualeFatturazione();

    Logger().d(datiFatturazione);

    return Container(
      alignment: Alignment.center,
      height: 300,
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
              'Percentuale Fatturazione:',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (datiFatturazione.length != 0)
              Expanded(
                child: GraficoFatturazioneMensile(
                    datiFatturazione: datiFatturazione),
              ),
            if (datiFatturazione.length == 0)
              Expanded(
                child: Center(
                  child: Text('Non ci sono fasce caricate'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class GraficoFatturazioneMensile extends StatefulWidget {
  GraficoFatturazioneMensile({
    Key? key,
    required this.datiFatturazione,
  }) : super(key: key);

  final List<Map> datiFatturazione;

  @override
  State<StatefulWidget> createState() => _GraficoFatturazioneMensile();
}

class _GraficoFatturazioneMensile extends State<GraficoFatturazioneMensile> {
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
                sections: showingSections(widget.datiFatturazione),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Creazione lista dati per il grafico
  List<PieChartSectionData> showingSections(List<Map> datiFatturazione) {
    // Genero la lista dei record da visualizzare nel grafico
    List<PieChartSectionData> listaDati = datiFatturazione.asMap().entries.map(
      (entry) {
        int index = entry.key;
        Map elemento = entry.value;

        String titolo = elemento['titolo'];
        String ore = elemento['ore'].toString();
        double percentuale = elemento['percentuale'];
        Color colore = elemento['colore'];

        final isTouched = index == touchedIndex;
        final fontSize = isTouched ? 25.0 : 16.0;
        final radius = isTouched ? 60.0 : 50.0;
        const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

        return PieChartSectionData(
          color: colore,
          //titlePositionPercentageOffset: 1.2,
          value: percentuale,
          title: '$percentuale%\n$ore Ore',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            shadows: shadows,
          ),
        );
      },
    ).toList();

    return listaDati;
  }
}
