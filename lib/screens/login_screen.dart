import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:http/http.dart' as http;

import 'package:vehicles_app/components/loader_component.dart';
import 'package:vehicles_app/helpers/constans.dart';
import 'package:vehicles_app/models/token.dart';
import 'package:vehicles_app/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({ Key? key }) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _email = 'luis@yopmail.com';
  String _emailError = '';
  bool _emailShowError = false;
  
  String _password = '123456';
  String _passwordError = '';
  bool _passwordShowError = false;

  bool _rememberme = true;
  bool _passwordShow = false;

  bool _showLoader = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _showLogo(),
              SizedBox(height: 20,),
              _showEmail(),
              _showPassword(),
              _showRememberme(),
              _showButtons(),
            ], 
          ),
          _showLoader ? LoaderComponent(text: 'Por favor espere...',) : Container(),
        ],
      ),
    );
  }

  Widget _showLogo() {
    return Image(
      image: AssetImage('assets/Vehicles_logo.png'),
      width: 150,
    );
  }

  Widget _showEmail() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        autofocus: true,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: 'Ingresa tu email',
          labelText: 'Email',
          errorText: _emailShowError ? _emailError : null,
          prefixIcon: Icon(Icons.alternate_email),
          suffixIcon: Icon(Icons.email),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)
            ),
        ),
        onChanged: (value) {
          _email = value;
        },
      ),
    );
  }

  Widget _showPassword() {
     return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        obscureText: !_passwordShow,
        decoration: InputDecoration(
          hintText: 'Ingresa tu contrase??a',
          labelText: 'Contrase??a',
           errorText: _passwordShowError ? _passwordError : null,
          prefixIcon: Icon(Icons.lock),
          suffixIcon: IconButton(
            icon: _passwordShow ? Icon(Icons.visibility) : Icon(Icons.visibility_off),
             onPressed: () {
               setState(() {
                 _passwordShow = !_passwordShow;
               });
             } ,
            ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)
            ),
        ),
        onChanged: (value) {
          _password = value;
        },
      ),
    );
  }

  Widget _showRememberme() {
    return CheckboxListTile(
      title: Text('Recordarme'),
      value: _rememberme,
      onChanged: (value) { 
        setState(() {
         _rememberme = value!;  
        });
      },
    );
  }

  Widget _showButtons() {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: Row(
        
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Expanded( 
            child: ElevatedButton(
              child: Text('iniciar sesi??n'),
              style:  ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states){
                  return Color(0xFF03203C);
                }
                ),
              ),
              onPressed: () => _login(),
            ),
          ),
          SizedBox(width: 20,),
          Expanded(
            child: ElevatedButton(
              child: Text('Nuevo usuario'),
               style:  ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states){
                    return Color(0xFFE03B8B);
                }
                ),
              ),
              onPressed: (){},
            ),
          ),
        ],
      ),
    );
  }

  void _login() async {
    setState(() {
      _passwordShow = false;
    });

    if(!_validateFields()){
      return;
    }

     setState(() {
      _showLoader = true;
    });

    Map<String, dynamic> request ={
      'userName': _email,
      'password': _password,
    };

    var url = Uri.parse('${Constans.apiUrl}/api/Account/CreateToken');
    var response = await http.post(
      url,
      headers: {
        'content-type' : 'application/json',
        'accept' : 'application/json',
      },
      body: jsonEncode(request),
    );

     setState(() {
      _showLoader = false;
    });

    if (response.statusCode >= 400){
      setState(() {
        _passwordShowError = true;
        _passwordError = "Email o contrase??a incorrectos";
      });
      return;
    }

   var body = response.body;
   var decodedJson = jsonDecode(body);
   var  token = Token.fromJson(decodedJson);
   Navigator.pushReplacement(
     context, 
     MaterialPageRoute(
       builder: (context) => HomeScreen(token: token,)
       )
     );
  }

  bool _validateFields() {
    bool isValid = true; 

    if (_email.isEmpty){
      isValid = false;
      _emailShowError = true;
      _emailError = 'Debes ingresar tu email.';
    } else if (!EmailValidator.validate(_email)) {
      isValid = false;
      _emailShowError = true;
      _emailError = 'Debes ingresar un email valido.';

    } else {
       _emailShowError = false;
    }

     if (_password.isEmpty){
      isValid = false;
      _passwordShowError = true;
      _passwordError = 'Debes ingresar tu contrase??a.';
    } else if (_password.length < 6) {
      isValid = false;
       _passwordShowError = true;
      _passwordError = 'Debes ingresar una contrase??a de al menos 6 caracteres.';
    } else {
       _passwordShowError = false;
    }

    setState(() {    });
    return isValid;
  }
}