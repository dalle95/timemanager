import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/actiontype.dart';
import '../providers/work_order.dart';
import '../providers/work_orders.dart';
import '../providers/box.dart';

import '../screens/box_list_screen.dart';
import '../screens/actiontype_list_screen.dart';
import '../widgets/flat_button.dart';

enum tipologia { insert, update }

class WoDetailScreen extends StatefulWidget {
  static const routeName = '/edit-wo';

  @override
  State<WoDetailScreen> createState() => _WoDetailScreenState();
}

class _WoDetailScreenState extends State<WoDetailScreen> {
  final _form = GlobalKey<FormState>();
  var _isInit = true;
  var _isLoading = false;
  var _tipologia;

  // Inizializzo il valore iniziale della natura
  var _actionType = ActionType(
    id: null,
    code: '',
    description: '',
  );
  // Inizializzo il valore iniziale del box
  var _box = Box(
    id: null,
    code: '',
    description: '',
    eqptType: '',
    statusCode: '',
  );
  // Inizializzo il valore iniziale del WO sia nuovo che in modifica
  var _initWO = WorkOrder(
    id: null,
    codice: '',
    descrizione: '',
    statusCode: '',
    actionType: ActionType(
      id: null,
      code: '',
      description: '',
    ),
    box: Box(
      id: null,
      code: '',
      description: '',
      eqptType: '',
      statusCode: '',
    ),
  );
  var _editedWO = WorkOrder(
    id: null,
    codice: '',
    descrizione: '',
    statusCode: '',
    actionType: ActionType(
      id: null,
      code: '',
      description: '',
    ),
    box: Box(
      id: null,
      code: '',
      description: '',
      eqptType: '',
      statusCode: '',
    ),
  );

  // Inizializzo i valori iniziali dei textform
  var _initWOValues = {
    'code': '',
    'description': '',
    'statusCode': 'AWAITINGREAL',
    'actionType': '',
  };

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final woId = ModalRoute.of(context).settings.arguments as String;
      if (woId != null) {
        _editedWO =
            Provider.of<WorkOrders>(context, listen: false).findById(woId);

        _initWO = WorkOrder(
          id: _editedWO.id,
          codice: _editedWO.codice,
          descrizione: _editedWO.descrizione,
          statusCode: _editedWO.statusCode,
          actionType: _editedWO.actionType,
          box: _editedWO.box,
        );

        print(_initWO.box.id);

        _initWOValues = {
          'code': _editedWO.codice,
          'description': _editedWO.descrizione,
          'statusCode': _editedWO.statusCode,
        };

        _actionType = _editedWO.actionType;
        _box = _editedWO.box;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _searchListActiontype() async {
    final result = await Navigator.of(context)
        .pushNamed(ActionTypeListScreen.routeName) as Map<String, dynamic>;

    if (result != null) {
      setState(() {
        _actionType = ActionType(
          id: result['id'],
          code: result['code'] ?? '',
          description: result['description'] ?? '',
        );
      });
    }
  }

  Future<void> _searchListBox() async {
    final result = await Navigator.of(context).pushNamed(
      BoxListScreen.routeName,
      arguments: {
        'function': 'search',
      },
    ) as Map<String, dynamic>;

    if (result != null) {
      setState(() {
        _box = Box(
          id: result['id'],
          code: result['code'],
          description: result['description'] ?? '',
          eqptType: result['eqptType'] ?? '',
          statusCode: result['statusCode'],
        );
      });
    }
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

    print(
        'WO: id: ${_initWO.id}, code: ${_initWO.codice ?? ''}, description: ${_initWO.descrizione ?? ''}, natura: ${_initWO.actionType.code ?? ''}, box: ${_initWO.box.code ?? ''}');

    _editedWO.actionType = _actionType;
    _editedWO.box = _box;

    print(
        'WO: id: ${_editedWO.id}, code: ${_editedWO.codice ?? ''}, description: ${_editedWO.descrizione ?? ''}, natura: ${_editedWO.actionType.code ?? ''}, box: ${_editedWO.box.code ?? ''}');

    if (_editedWO.id != null) {
      try {
        //Per aggiornare un WO già esistente
        await Provider.of<WorkOrders>(context, listen: false)
            .updateWorkOrder(_editedWO.id, _initWO, _editedWO);
        _tipologia = tipologia.update;
      } catch (error) {
        print(error);
      }
    } else {
      try {
        // Per creare un WO
        await Provider.of<WorkOrders>(context, listen: false)
            .addWorkOrder(_editedWO);
        _tipologia = tipologia.update;
      } catch (error) {
        print(error);
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

    if (_tipologia == tipologia.insert) {
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
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('WorkOrder aggiornato!'),
          duration: const Duration(
            seconds: 2,
          ),
          action: SnackBarAction(label: 'Annulla', onPressed: () {}),
        ),
      );
    }
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
              // Container(
              //   decoration: BoxDecoration(
              //     color: Theme.of(context).accentColor,
              //   ),
              //   width: double.infinity,
              //   height: 30,
              // ),
              TextFormField(
                initialValue: _initWOValues['code'],
                decoration: const InputDecoration(labelText: 'Codice'),
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
                decoration: const InputDecoration(labelText: 'Titolo'),
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
                decoration: const InputDecoration(
                  labelText: 'Stato',
                ),
                textAlign: TextAlign.center,
                readOnly: true,
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
              const SizedBox(height: 10),
              const Text(
                'Natura',
                style: TextStyle(
                  color: Color.fromARGB(255, 117, 117, 117),
                  fontSize: 11,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FlatButton(
                  _searchListActiontype,
                  Text(_actionType.code),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Punto di struttura',
                style: TextStyle(
                  color: Color.fromARGB(255, 117, 117, 117),
                  fontSize: 11,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FlatButton(
                  _searchListBox,
                  Text(_box.code ?? ''),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
