import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../../models/box.dart';
import '../../providers/boxes.dart';

enum tipologia { insert, update }

class BoxDetailScreen extends StatefulWidget {
  static const routeName = '/edit-box';

  @override
  State<BoxDetailScreen> createState() => _BoxDetailScreenState();
}

class _BoxDetailScreenState extends State<BoxDetailScreen> {
  final _form = GlobalKey<FormState>();
  var _isInit = true;
  // ignore: unused_field
  var _isLoading = false;
  var _tipologia;

  // Per gestire i log
  var logger = Logger();

  // Inizializzo il valore iniziale del box
  var _initBox = Box(
    id: null,
    code: '',
    description: '',
    eqptType: '',
    statusCode: '',
  );
  var _editedBox = Box(
    id: null,
    code: '',
    description: '',
    eqptType: '',
    statusCode: '',
  );

  // Inizializzo i valori iniziali dei textform
  var _initBoxValues = {
    'code': '',
    'description': '',
    'statusCode': 'VALIDATE',
    'eqptType': '',
  };

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final String? id = ModalRoute.of(context)!.settings.arguments as String;
      if (id != null) {
        _editedBox = Provider.of<Boxes>(context, listen: false).findById(id);

        _initBox = Box(
            id: _editedBox.id,
            code: _editedBox.code,
            description: _editedBox.description,
            statusCode: _editedBox.statusCode,
            eqptType: _editedBox.eqptType);

        _initBoxValues = {
          'code': _editedBox.code,
          'description': _editedBox.description,
          'statusCode': _editedBox.statusCode,
          'eqptType': _editedBox.eqptType!,
        };
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _saveForm() async {
    var isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }

    _form.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    logger.d(
        'Box: id: ${_initBox.id}, code: ${_initBox.code}, description: ${_initBox.description}');
    logger.d(
        'Box: id: ${_editedBox.id}, code: ${_editedBox.code}, description: ${_editedBox.description}');

    if (_editedBox.id != null) {
      try {
        //Per aggiornare un Box già esistente
        await Provider.of<Boxes>(context, listen: false)
            .updateBox(_editedBox.id!, _initBox, _editedBox);
        _tipologia = tipologia.update;
      } catch (error) {
        logger.d(error);
      }
    } else {
      try {
        // Per creare un WO
        await Provider.of<Boxes>(context, listen: false).addBox(_editedBox);
        _tipologia = tipologia.insert;
      } catch (error) {
        logger.d(error);
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Si è verificato un errore'),
            content: const Text('Qualcosa è andato storto.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Conferma'),
              )
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
          content: Text('Box inserito!'),
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
          content: Text('Box aggiornato!'),
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
        title: const Text('Dettaglio del Box'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: const Icon(Icons.save),
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
                initialValue: _initBoxValues['code'],
                decoration: const InputDecoration(labelText: 'Codice'),
                textInputAction: TextInputAction.next,
                onSaved: (value) {
                  _editedBox = Box(
                    id: _editedBox.id,
                    code: value!,
                    description: _editedBox.description,
                    statusCode: _editedBox.statusCode,
                    eqptType: _editedBox.eqptType,
                  );
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Inserisci il codice.';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _initBoxValues['description'],
                decoration: const InputDecoration(labelText: 'Titolo'),
                textInputAction: TextInputAction.next,
                onSaved: (value) {
                  _editedBox = Box(
                    id: _editedBox.id,
                    code: _editedBox.code,
                    description: value!,
                    statusCode: _editedBox.statusCode,
                    eqptType: _editedBox.eqptType,
                  );
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Inserisci un titolo.';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _initBoxValues['eqptType'],
                decoration: const InputDecoration(
                    labelText: 'Tipologia localizzazione'),
                textInputAction: TextInputAction.next,
                onSaved: (value) {
                  _editedBox = Box(
                    id: _editedBox.id,
                    code: _editedBox.code,
                    description: _editedBox.description,
                    statusCode: _editedBox.statusCode,
                    eqptType: value,
                  );
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Inserisci un eqptType.';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _initBoxValues['statusCode'],
                decoration: const InputDecoration(
                  labelText: 'Stato',
                ),
                textAlign: TextAlign.center,
                readOnly: true,
                textInputAction: TextInputAction.next,
                onSaved: (value) {
                  _editedBox = Box(
                    id: _editedBox.id,
                    code: _editedBox.code,
                    description: _editedBox.description,
                    statusCode: value!,
                    eqptType: _editedBox.eqptType,
                  );
                },
                onEditingComplete: () {
                  setState(() {});
                },
                onFieldSubmitted: (_) {
                  //_saveForm();
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Inserisci lo stato.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
