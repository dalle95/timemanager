import 'package:carl_touch_api/providers/work_order.dart';
import 'package:carl_touch_api/providers/work_orders.dart';
import 'package:carl_touch_api/widgets/flat_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WoDetailScreen extends StatefulWidget {
  static const routeName = '/edit-wo';

  @override
  State<WoDetailScreen> createState() => _WoDetailScreenState();
}

class _WoDetailScreenState extends State<WoDetailScreen> {
  final _form = GlobalKey<FormState>();
  var _isInit = true;
  var _isLoading = false;

  var _editedWO = WorkOrder(
    id: null,
    codice: '',
    descrizione: '',
    statusCode: '',
  );

  var _initWOValues = {
    'code': '',
    'description': '',
    'statusCode': 'REQUEST',
    'actionType': '',
  };

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final woId = ModalRoute.of(context).settings.arguments as String;
      if (woId != null) {
        _editedWO =
            Provider.of<WorkOrders>(context, listen: false).findById(woId);

        _initWOValues = {
          'code': _editedWO.codice,
          'description': _editedWO.descrizione,
          'statusCode': _editedWO.statusCode,
          'actionType': _editedWO.actionType,
        };
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _saveForm() async {
    var isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }

    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });

    if (_editedWO.id != null) {
      //Per aggiornare un WO già esistente
      await Provider.of<WorkOrders>(context, listen: false)
          .updateWorkOrder(_editedWO.id, _editedWO);
    } else {
      try {
        // Per creare un WO
        await Provider.of<WorkOrders>(context, listen: false)
            .addWorkOrder(_editedWO);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Si è verificato un errore'),
            content: const Text('Qualcosa è andato storto.'),
            actions: [
              FlatButton(
                () {
                  Navigator.of(context).pop();
                },
                const Text('Conferma'),
              ),
            ],
          ),
        );
      }
    }
    ;
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('WorkOrder inserito!'),
        duration: const Duration(
          seconds: 2,
        ),
        action: SnackBarAction(label: 'Annulla', onPressed: () {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edita il WO'),
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: Icon(Icons.save),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _initWOValues['code'],
                decoration: InputDecoration(labelText: 'Codice'),
                textInputAction: TextInputAction.next,
                onSaved: (value) {
                  _editedWO = WorkOrder(
                    id: _editedWO.id,
                    codice: value,
                    descrizione: _editedWO.descrizione,
                    statusCode: _editedWO.statusCode,
                    actionType: _editedWO.actionType,
                  );
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Inserisci il codice.';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _initWOValues['description'],
                decoration: InputDecoration(labelText: 'Titolo'),
                textInputAction: TextInputAction.next,
                onSaved: (value) {
                  _editedWO = WorkOrder(
                    id: _editedWO.id,
                    codice: _editedWO.codice,
                    descrizione: value,
                    statusCode: _editedWO.statusCode,
                    actionType: _editedWO.actionType,
                  );
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Inserisci un titolo.';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _initWOValues['statusCode'],
                decoration: InputDecoration(labelText: 'Stato'),
                textInputAction: TextInputAction.next,
                onSaved: (value) {
                  _editedWO = WorkOrder(
                    id: _editedWO.id,
                    codice: _editedWO.codice,
                    descrizione: _editedWO.descrizione,
                    statusCode: value,
                    actionType: _editedWO.actionType,
                  );
                },
                onEditingComplete: () {
                  setState(() {});
                },
                onFieldSubmitted: (_) {
                  _saveForm();
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Inserisci lo stato.';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _initWOValues['actionType'],
                decoration: InputDecoration(labelText: 'Natura'),
                textInputAction: TextInputAction.done,
                onSaved: (value) {
                  _editedWO = WorkOrder(
                    id: _editedWO.id,
                    codice: _editedWO.codice,
                    descrizione: _editedWO.descrizione,
                    statusCode: _editedWO.statusCode,
                    actionType: value,
                  );
                },
                onEditingComplete: () {
                  setState(() {});
                },
                onFieldSubmitted: (_) {
                  _saveForm();
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Inserisci la natura.';
                  }
                  return null;
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
