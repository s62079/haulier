import 'package:flutter/material.dart';
import 'package:haulier/view_login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TaskApp());
}

class TaskApp extends StatelessWidget {
  const TaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'To Do',
      // darkTheme: ThemeData.dark(),
      home: LoginPage(),
    );
  }
}
