import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/http_exception.dart';
import '../providers/auth.dart';
import '../widgets/flat_button.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/raise_button.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Color.fromARGB(255, 11, 50, 113),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Flexible(
                  //   child: Container(
                  //     width: deviceSize.width * 0.75,
                  //     margin: const EdgeInsets.all(10.0),
                  //     padding: const EdgeInsets.symmetric(
                  //         vertical: 8.0, horizontal: 50.0),
                  //     // transform: Matrix4.rotationZ(-8 * pi / 180)
                  //     //   ..translate(-10.0),
                  //     // ..translate(-10.0),
                  //     decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(10),
                  //       color: Theme.of(context).colorScheme.secondary,
                  //       boxShadow: const [
                  //         BoxShadow(
                  //           blurRadius: 8,
                  //           color: Colors.black26,
                  //           offset: Offset(0, 2),
                  //         )
                  //       ],
                  //     ),
                  //     child: const Text(
                  //       'Time Manager',
                  //       textAlign: TextAlign.center,
                  //       style: TextStyle(
                  //         color: Colors.white,
                  //         fontSize: 25,
                  //         //fontFamily: 'Anton',
                  //         fontWeight: FontWeight.bold,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: const AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  //AuthMode _authMode = AuthMode.Login;
  final Map<String, String> _authData = {
    'url': 'https://carl6.operosa.it/gmaoCS02',
    'username': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Si è verificato un errore'),
        content: Text(message),
        actions: [
          FlatButton(
            () {
              Navigator.of(context).pop();
            },
            const Text('Conferma'),
          )
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });

    try {
      // Log user in
      await Provider.of<Auth>(context, listen: false).login(
        _authData['url'],
        _authData['username'],
        _authData['password'],
      );
    } on HttpException catch (error) {
      // Errore durante il log in
      print(error.toString());
      _showErrorDialog(error.toString());
    } catch (error) {
      var errorMessage =
          'Non è possibile esesguire l\'autenticazione, prova più tardi.';
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: Container(
        height: 330,
        constraints: const BoxConstraints(minHeight: 230),
        width: deviceSize.width * 0.75,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const Text(
                  'TimeManager',
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  initialValue: 'https://ticketing.in-am.it/gmaoCS02',
                  decoration: const InputDecoration(
                      labelText: 'URL ambiente',
                      contentPadding: EdgeInsets.zero),
                  keyboardType: TextInputType.name,
                  textAlign: TextAlign.center,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'URL invalido!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['url'] = value;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Login', contentPadding: EdgeInsets.zero),
                  keyboardType: TextInputType.name,
                  textAlign: TextAlign.center,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Nome invalido!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['username'] = value;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                  obscureText: true,
                  textAlign: TextAlign.center,
                  controller: _passwordController,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'La password non può essere nulla!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['password'] = value;
                  },
                  onFieldSubmitted: (_) {
                    _submit();
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  LoadingIndicator('Caricamento')
                else
                  RaiseButton(
                    _submit,
                    const Text(
                      'Connessione',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    Theme.of(context).colorScheme.secondary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
