import 'package:flutter/material.dart';
import 'auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends StatefulWidget {
  final BaseAuth auth;
  final VoidCallback onSignedIn;

  LoginPage({this.auth, this.onSignedIn});

  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

enum FormType { login, register }

class _LoginPageState extends State<LoginPage> {
  static final formKey = new GlobalKey<FormState>();
  FormType _formType = FormType.login;

  String _email;
  String _password;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(title: new Text('ScanIt')),
        body: new Builder(
          builder: (context) => Container(
            padding: EdgeInsets.all(16.0),
            child: new Form(
              key: formKey,
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: buildInputs() + buildSubmitButtons(),
              ),
            ),
          ),
        ));
  }

  List<Widget> buildInputs() {
    return [
      new TextFormField(
        decoration: new InputDecoration(labelText: 'Email'),
        validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
        onSaved: (value) => _email = value,
      ),
      new TextFormField(
        decoration: new InputDecoration(labelText: 'Password'),
        validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
        obscureText: true,
        onSaved: (value) => _password = value,
      ),
    ];
  }

  List<Widget> buildSubmitButtons() {
    if (_formType == FormType.login) {
      return [
        new RaisedButton(
          child: new Text(
            'Login',
            style: new TextStyle(fontSize: 20.0),
          ),
          onPressed: () => validateAndSubmit(context),
        ),
        new FlatButton(
            onPressed: moveToRegister,
            child: new Text('Create an account',
                style: new TextStyle(fontSize: 20.0)))
      ];
    } else
      return [
        new RaisedButton(
          child: new Text(
            'Create an account',
            style: new TextStyle(fontSize: 20.0),
          ),
          onPressed: () => validateAndSubmit(context),
        ),
        new FlatButton(
            onPressed: moveToLogin,
            child: new Text('Already have an account',
                style: new TextStyle(fontSize: 20.0)))
      ];
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      print('Form is valid: Email $_email, Password $_password');
      return true;
    } else {
      print('Form is invalid: Email $_email, Password $_password');
      return false;
    }
  }

  Future<void> validateAndSubmit(BuildContext context) async {
    if (validateAndSave()) {
      try {
        if (_formType == FormType.login) {
          String userId =
              await widget.auth.signInWithEmailAndPassword(_email, _password);
          print('Signed in: $userId');
          Fluttertoast.showToast(
              msg: "Logged in",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIos: 1);
        } else {
          String userId = await widget.auth
              .createUserWithEmailAndPassword(_email, _password);
          print('Registered: $userId');
          Fluttertoast.showToast(
              msg: "Registered",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIos: 1);
        }
        widget.onSignedIn();
      } catch (e) {
        print('Error: $e');
        Fluttertoast.showToast(
            msg: "Invalid data",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIos: 1);
      }
    }
  }

  void moveToRegister() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.register;
    });
  }

  void moveToLogin() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.login;
    });
  }
}
