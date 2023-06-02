import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../urlAmbiente.dart';

import '../errors/http_exception.dart';
import '../providers/auth.dart';
import '../widgets/loading_indicator.dart';

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
                  const Color.fromARGB(255, 11, 50, 113),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: SizedBox(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
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
    Key? key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  //AuthMode _authMode = AuthMode.Login;
  final Map<String, String> _authData = {
    'url': url.urlAmbiente,
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      // Log user in
      await Provider.of<Auth>(context, listen: false).login(
        url.urlAmbiente,
        _authData['username']!,
        _authData['password']!,
      );
    } on HttpException catch (error) {
      // Errore durante il log in
      _showErrorDialog(error.toString());
    } catch (error) {
      var errorMessage =
          'Non è possibile esesguire l\'autenticazione, prova più tardi.';
      _showErrorDialog(error.toString());
      throw errorMessage;
    }
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
        height: 300,
        constraints: const BoxConstraints(minHeight: 230),
        width: deviceSize.width * 0.75,
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Text(
                    'TimeManager',
                    style: TextStyle(
                      fontSize: 30,
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: 'Login', contentPadding: EdgeInsets.zero),
                    keyboardType: TextInputType.name,
                    textAlign: TextAlign.center,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Nome invalido!';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _authData['username'] = value!;
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
                      if (value!.isEmpty) {
                        return 'La password non può essere nulla!';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _authData['password'] = value!;
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
                    ElevatedButton(
                      onPressed: _submit,
                      child: const Text(
                        'Connessione',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
