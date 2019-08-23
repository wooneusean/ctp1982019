import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum snackBarMessages {
  EMPTYEMAILPASS,
  EMPTYEMAILPASSREPASS,
  EMAILPASSMISMATCH,
  PASSREPASSMISMATCH,
  SERVERDOWN,
  USERNOTVERIFIED,
  USEREXISTS,
  MAILERDOWN,
  REGISTERSUCCESS,
  SUCCESS,
  FAILURE,
}

void _showSnackBar(BuildContext context, snackBarMessages msg) {
  String message;
  switch (msg) {
    case snackBarMessages.EMPTYEMAILPASS:
      message = 'Email and password must not be empty!';
      break;
    case snackBarMessages.EMPTYEMAILPASSREPASS:
      message = 'Email, password and re-type password must not be empty!';
      break;
    case snackBarMessages.EMAILPASSMISMATCH:
      message = 'Wrong email and/or password!';
      break;
    case snackBarMessages.PASSREPASSMISMATCH:
      message = 'Password and re-type password not the same!';
      break;
    case snackBarMessages.SERVERDOWN:
      message = 'Server is down!';
      break;
    case snackBarMessages.USERNOTVERIFIED:
      message = 'Your account has not yet been verified!';
      break;
    case snackBarMessages.USEREXISTS:
      message = 'Account with that email already exists!';
      break;
    case snackBarMessages.MAILERDOWN:
      message = 'Our mailer is down!';
      break;
    case snackBarMessages.SUCCESS:
      message = 'Successfully carried our process!';
      break;
    case snackBarMessages.FAILURE:
      message = 'Process failed!';
      break;
    case snackBarMessages.REGISTERSUCCESS:
      message =
          'Successfully registered. Please verify your account from the email we sent you!';
      break;

    default:
      message = 'Unknown error occured!';
      break;
  }

  Scaffold.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
    ),
  );
}

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => LoginPage());
      case '/home':
        return MaterialPageRoute(
          builder: (_) => HomePage(
            token: args.toString(),
          ),
        );
      case '/register':
        return MaterialPageRoute(
          builder: (_) => RegisterPage(),
        );
      default:
        return MaterialPageRoute(builder: (_) => ErrorPage());
    }
  }
}

class ErrorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          child: Text('Error'),
          width: double.infinity,
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  RegisterPage({Key key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

void _sgd(BuildContext context) {
  showGeneralDialog(
    context: context,
    pageBuilder: (BuildContext buildContext, Animation<double> animation,
        Animation<double> secondaryAnimation) {
      return Scaffold(
        body: Center(
          child: Wrap(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  borderRadius: new BorderRadius.circular(10.0),
                  color: Colors.pink,
                ),
                width: 200.0,
                height: 200.0,
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Center(
                      child: new SizedBox(
                        height: 50,
                        width: 50,
                        child: new CircularProgressIndicator(
                          value: null,
                          strokeWidth: 7.0,
                        ),
                      ),
                    ),
                    new Container(
                      margin: const EdgeInsets.only(top: 25.0),
                      child: new Center(
                        child: new Text(
                          'Loading...',
                          style: new TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
    barrierDismissible: false,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Color(0x78808080),
    transitionDuration: const Duration(milliseconds: 200),
  );
}

class _RegisterPageState extends State<RegisterPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final rePassCtrl = TextEditingController();

  var res;

  Future sendRegisterRequest(String email, String password, String repass,
      BuildContext context) async {
    final url = 'http://10.0.2.2/ctp1982019/register.php';

    try {
      final response = await http.post(url, body: {
        'email': email,
        'password': password,
        'repass': repass,
      }).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        setState(() {
          res = jsonDecode(response.body);
          debugPrint(response.body);
          if (res.isNotEmpty) {
            switch (res['res']) {
              case '0':
                _showSnackBar(context, snackBarMessages.EMPTYEMAILPASSREPASS);
                break;
              case '1':
                _showSnackBar(context, snackBarMessages.PASSREPASSMISMATCH);
                break;
              case '2':
                _showSnackBar(context, snackBarMessages.USEREXISTS);
                break;
              case '3':
                _showSnackBar(context, snackBarMessages.MAILERDOWN);
                break;
              case '4':
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    // return object of type Dialog
                    return AlertDialog(
                      title: new Text('Success!'),
                      content: new Text(
                          'Registration Success! Please verify your account from the email we sent you.'),
                      actions: <Widget>[
                        // usually buttons at the bottom of the dialog
                        new FlatButton(
                          child: new Text("Close"),
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
                break;
              default:
                _showSnackBar(context, snackBarMessages.SERVERDOWN);
            }
          }
        });
      }
    } on TimeoutException catch (_) {
      _showSnackBar(context, snackBarMessages.SERVERDOWN);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Builder(
        builder: (context) => SafeArea(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            children: <Widget>[
              SizedBox(height: 120.0),
              TextField(
                controller: emailCtrl,
                decoration: InputDecoration(labelText: 'Email', filled: true),
              ),
              SizedBox(height: 12.0),
              TextField(
                controller: passCtrl,
                decoration:
                    InputDecoration(labelText: 'Password', filled: true),
                obscureText: true,
              ),
              SizedBox(height: 12.0),
              TextField(
                controller: rePassCtrl,
                decoration: InputDecoration(
                    labelText: 'Re-type Password', filled: true),
                obscureText: true,
              ),
              ButtonBar(
                children: <Widget>[
                  RaisedButton(
                    child: Text('Register'),
                    onPressed: () {
                      _sgd(context);
//                      if (emailCtrl.text.isNotEmpty &&
//                          passCtrl.text.isNotEmpty &&
//                          rePassCtrl.text.isNotEmpty) {
//                        if (passCtrl.text == rePassCtrl.text) {
//                          sendRegisterRequest(emailCtrl.text, passCtrl.text,
//                              rePassCtrl.text, context);
//                        } else {
//                          _showSnackBar(
//                              context, snackBarMessages.PASSREPASSMISMATCH);
//                        }
//                      } else {
//                        _showSnackBar(
//                            context, snackBarMessages.EMPTYEMAILPASSREPASS);
//                      }
                    },
                  ),
                  FlatButton(
                    child: Text('Back'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  var token;

  Future sendLoginRequest(
      String email, String password, BuildContext context) async {
    final url = 'http://10.0.2.2/ctp1982019/login.php';
    try {
      final response = await http.post(url, body: {
        'email': email,
        'password': password
      }).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        setState(() {
          // debugPrint(response.body);
          token = jsonDecode(response.body);
          if (token.isNotEmpty) {
            if (token['res'] == '0') {
              _showSnackBar(context, snackBarMessages.EMAILPASSMISMATCH);
            } else if (token['res'] == '1') {
              _showSnackBar(context, snackBarMessages.USERNOTVERIFIED);
            } else {
              Navigator.of(context)
                  .pushReplacementNamed('/home', arguments: token['res']);
            }
          }
        });
      }
    } on TimeoutException catch (_) {
      _showSnackBar(context, snackBarMessages.SERVERDOWN);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Builder(
        builder: (context) => SafeArea(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            children: <Widget>[
              SizedBox(height: 120.0),
              TextField(
                controller: emailCtrl,
                decoration: InputDecoration(labelText: 'Email', filled: true),
              ),
              SizedBox(height: 12.0),
              TextField(
                controller: passCtrl,
                decoration:
                    InputDecoration(labelText: 'Password', filled: true),
                obscureText: true,
              ),
              ButtonBar(
                children: <Widget>[
                  RaisedButton(
                    child: Text('Login'),
                    onPressed: () {
                      if (emailCtrl.text.isEmpty || passCtrl.text.isEmpty) {
                        _showSnackBar(context, snackBarMessages.EMPTYEMAILPASS);
                      } else {
                        sendLoginRequest(
                            emailCtrl.text, passCtrl.text, context);
                      }
                    },
                  ),
                  FlatButton(
                    child: Text('Register'),
                    onPressed: () {
                      Navigator.of(context).pushNamed('/register');
                    },
                  )
                ],
              ),
            ],
          ),
        ),
      ),

//      body: Center(
//        child: _buildUserData(context),
//      ),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.token}) : super(key: key);

  final String token;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var resp;

  Widget userData(var resp) {
    if (resp != null) {
      switch (resp['res']) {
        case '0':
          return Text('User Not Found!');
          break;
        case '1':
          return Text('Authentication Failed!');
          break;
        case '2':
          return ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Center(
                  child: Text(
                    'Welcome ' + resp['email'] + '!',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                },
                title: Text(
                  'Balance',
                  style: TextStyle(fontSize: 16),
                ),
                subtitle: Text(
                  resp['balance'],
                  style: TextStyle(fontSize: 18),
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushReplacementNamed('/');
                  resp = null;
                },
                title: Text(
                  'Log out',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          );
          break;
        default:
          return Text('Error.');
          break;
      }
    } else {
      return Text('Error.');
    }
  }

  Future getUserData(String token, BuildContext context) async {
    final url = 'http://10.0.2.2/ctp1982019/user.php';
    try {
      final response = await http
          .post(url, body: {'auth': token}).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        setState(() {
          resp = jsonDecode(response.body);
        });
        // debugPrint(response.body);
      }
    } on TimeoutException catch (_) {
      _showSnackBar(context, snackBarMessages.SERVERDOWN);
    }
  }

  @override
  void initState() {
    super.initState();
    getUserData(widget.token, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: ListView(
        children: <Widget>[],
      ),
      drawer: Builder(
        builder: (context) => Drawer(child: userData(resp)),
      ),
    );
  }
}
