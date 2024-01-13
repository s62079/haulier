import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:haulier/util.dart';
import 'package:haulier/view_home.dart';

import 'data.dart';

// https://stackoverflow.com/questions/29628989
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, String> _body = {
    'username': '',
    'password': '',
    'passwordConfirm': '',
  };
  Map<String, dynamic> _response = {};
  bool register = false;
  String message = '';

  String? getErrorMessage(String key) {
    String? message;
    if (_response.containsKey('data')) {
      Map<String, dynamic> data = _response['data'];
      message = (data.containsKey(key)) ? data[key]!['message'] : null;
    }
    return message;
  }

  TextFormField createFormField(
    String saveKey, {
    required String? Function(String?)? validate,
    bool hideText = false,
    String? label,
  }) {
    return TextFormField(
      decoration: InputDecoration(labelText: label ?? saveKey.capitalize()),
      onSaved: (value) => _body[saveKey] = value!,
      validator: validate,
      obscureText: hideText,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (Data.isLoggedIn()) {
      // https://stackoverflow.com/questions/54846280
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await pb.collection('users').authRefresh();
        await Data.loadTrucks();
        await Data.loadSchedules();
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        }
      });
    }

    var formFields = [
      Text(
        (register) ? 'Create Account' : 'Sign In',
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      createFormField('username', validate: (value) {
        return (_body['username'] == '')
            ? 'Cannot be Blank.'
            : getErrorMessage((register) ? 'username' : 'identity');
      }),
      createFormField(
        'password',
        hideText: true,
        validate: (_) => getErrorMessage('password'),
      ),
      Visibility(
        visible: register,
        child: createFormField(
          'passwordConfirm',
          label: 'Confirm Password',
          hideText: true,
          validate: (_) =>
              (register) ? getErrorMessage('passwordConfirm') : null,
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Switch(
            value: register,
            onChanged: (value) => setState(() => register = !register),
          ),
          const SizedBox(width: 8),
          const Text('New User?'),
          const Spacer(),
          ElevatedButton(
            onPressed: () async {
              message = '';
              _formKey.currentState!.save();
              _response = (register)
                  ? await Data.addUser(_body)
                  : await Data.authUser(_body);
              if (_formKey.currentState!.validate()) {
                if (register) {
                  _formKey.currentState!.reset();
                  message = 'Successfully created account.';
                } else {
                  if (_response['code'] != 200 && _response.isNotEmpty) {
                    message = _response['message'];
                  }
                }
                if (kDebugMode) {
                  print('DEBUG : $message');
                }
              }
              setState(() {});
            },
            child: Text((register) ? 'Register' : 'Login'),
          ),
        ],
      ),
      Text(message),
    ];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        systemOverlayStyle: getNavOverlay(Theme.of(context).canvasColor),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Wrap(
            alignment: WrapAlignment.center,
            runSpacing: 16,
            children: formFields,
          ),
        ),
      ),
    );
  }
}
