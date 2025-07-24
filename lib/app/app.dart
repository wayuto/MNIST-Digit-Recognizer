import 'package:flutter/material.dart';
import 'package:mnist/page/homePage.dart';
import 'package:provider/provider.dart';
import 'package:mnist/app/appState.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MyAppState(),
      child: MaterialApp(
        title: 'MNIST Digit Recognizer',
        theme: ThemeData.dark(),
        home: const MyHomePage(title: 'MNIST Digit Recognizer'),
      ),
    );
  }
}
