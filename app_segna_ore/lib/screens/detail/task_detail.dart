import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/actiontype.dart';
import '../../providers/task.dart';
import '../../providers/tasks.dart';
import '../../providers/box.dart';
import '../../providers/material.dart' as carl;

import '../list/box_list_screen.dart';
import '../list/actiontype_list_screen.dart';
import '../../widgets/flat_button.dart';

enum tipologia { insert, update }

class TaskDetailScreen extends StatefulWidget {
  static const routeName = '/edit-task';

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
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
  // Inizializzo il valore iniziale del cliente
  var _cliente = Box(
    id: null,
    code: '',
    description: '',
    eqptType: '',
    statusCode: '',
  );
  // Inizializzo il valore iniziale della commessa
  var _commessa = carl.Material(
    id: null,
    code: '',
    description: '',
    eqptType: '',
    statusCode: '',
  );

  // Inizializzo il valore iniziale del WO sia nuovo che in modifica
  var _initTask = Task(
    id: null,
    code: '',
    description: '',
    statusCode: '',
    actionType: ActionType(
      id: null,
      code: '',
      description: '',
    ),
    cliente: Box(
      id: null,
      code: '',
      description: '',
      eqptType: '',
      statusCode: '',
    ),
    commessa: carl.Material(
      id: null,
      code: '',
      description: '',
      eqptType: '',
      statusCode: '',
    ),
    workflowTransitions: [],
  );
  var _editedTask = Task(
    id: null,
    code: '',
    description: '',
    statusCode: '',
    actionType: ActionType(
      id: null,
      code: '',
      description: '',
    ),
    cliente: Box(
      id: null,
      code: '',
      description: '',
      eqptType: '',
      statusCode: '',
    ),
    commessa: carl.Material(
      id: null,
      code: '',
      description: '',
      eqptType: '',
      statusCode: '',
    ),
    workflowTransitions: [],
  );

  // Inizializzo i valori iniziali dei textform
  var _initTaskValues = {
    'code': '',
    'description': '',
    'statusCode': '',
    'actionType': '',
  };

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final woId = ModalRoute.of(context).settings.arguments as String;
      if (woId != null) {
        _editedTask = Provider.of<Tasks>(context, listen: false).findById(woId);

        _initTask = Task(
          id: _editedTask.id,
          code: _editedTask.code,
          description: _editedTask.description,
          statusCode: _editedTask.statusCode,
          actionType: _editedTask.actionType,
          cliente: _editedTask.cliente,
          commessa: _editedTask.commessa,
        );

        print(_initTask.cliente.id);

        _initTaskValues = {
          'code': _editedTask.code,
          'description': _editedTask.description,
          'statusCode': _editedTask.statusCode,
        };

        _actionType = _editedTask.actionType;
        _cliente = _editedTask.cliente;
        _commessa = _editedTask.commessa;
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
        _cliente = Box(
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
        'WO: id: ${_initTask.id}, code: ${_initTask.code ?? ''}, description: ${_initTask.description ?? ''}, natura: ${_initTask.actionType.code ?? ''}, box: ${_initTask.cliente.code ?? ''}');

    _editedTask.actionType = _actionType;
    _editedTask.cliente = _cliente;
    _editedTask.cliente = _cliente;

    print(
        'WO: id: ${_editedTask.id}, code: ${_editedTask.code ?? ''}, description: ${_editedTask.description ?? ''}, natura: ${_editedTask.actionType.code ?? ''}, box: ${_editedTask.cliente.code ?? ''}');

    if (_editedTask.id != null) {
      try {
        //Per aggiornare un WO già esistente
        await Provider.of<Tasks>(context, listen: false)
            .updateTask(_editedTask.id, _initTask, _editedTask);
        _tipologia = tipologia.update;
      } catch (error) {
        print(error);
      }
    } else {
      try {
        // Per creare un WO
        await Provider.of<Tasks>(context, listen: false).addTask(_editedTask);
        _tipologia = tipologia.insert;
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
          content: Text('Task inserito!'),
          duration: const Duration(
            seconds: 2,
          ),
          action: SnackBarAction(label: 'Annulla', onPressed: () {}),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task aggiornato!'),
          duration: Duration(
            seconds: 2,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dettaglio del WO'),
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
                initialValue: _initTaskValues['code'],
                decoration: const InputDecoration(labelText: 'Codice'),
                textInputAction: TextInputAction.next,
                onSaved: (value) {
                  _editedTask = Task(
                    id: _editedTask.id,
                    code: value,
                    description: _editedTask.description,
                    statusCode: _editedTask.statusCode,
                    actionType: _editedTask.actionType,
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
                initialValue: _initTaskValues['description'],
                decoration: const InputDecoration(labelText: 'Titolo'),
                textInputAction: TextInputAction.next,
                onSaved: (value) {
                  _editedTask = Task(
                    id: _editedTask.id,
                    code: _editedTask.code,
                    description: value,
                    statusCode: _editedTask.statusCode,
                    actionType: _editedTask.actionType,
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
                initialValue: _initTaskValues['statusCode'],
                decoration: const InputDecoration(
                  labelText: 'Stato',
                ),
                textAlign: TextAlign.center,
                readOnly: true,
                textInputAction: TextInputAction.next,
                onSaved: (value) {
                  _editedTask = Task(
                    id: _editedTask.id,
                    code: _editedTask.code,
                    description: _editedTask.description,
                    statusCode: value,
                    actionType: _editedTask.actionType,
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
                  Text(_cliente.code ?? ''),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.access_alarm),
      ),
    );
  }
}
