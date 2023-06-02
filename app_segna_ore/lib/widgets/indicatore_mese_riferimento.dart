import 'package:flutter/material.dart';

class IndicatoreMeseRiferimento extends StatefulWidget {
  const IndicatoreMeseRiferimento({
    super.key,
    required this.meseStringa,
    required this.modificaMese,
  });

  final String meseStringa;
  final void Function(String mese) modificaMese;

  @override
  State<IndicatoreMeseRiferimento> createState() =>
      _IndicatoreMeseRiferimentoState();
}

class _IndicatoreMeseRiferimentoState extends State<IndicatoreMeseRiferimento> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 100,
                child: IconButton(
                  onPressed: () => widget.modificaMese('meno'),
                  icon: Icon(
                    Icons.arrow_back,
                    size: 30,
                    color: Theme.of(context).colorScheme.background,
                  ),
                  color: Colors.transparent,
                ),
              ),
            ),
            Expanded(
              flex: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                ),
                child: Center(
                  child: Text(
                    widget.meseStringa,
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
                child: IconButton(
                  onPressed: () => widget.modificaMese('più'),
                  icon: Icon(
                    Icons.arrow_forward,
                    size: 30,
                    color: Theme.of(context).colorScheme.background,
                  ),
                  color: Colors.transparent,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
