library app;

import 'dart:async';
import "dart:math";
import 'package:custom_widget/custom_widget.dart';
import 'package:flutter/material.dart';

part "main_view.dart";
part "main_view_model.dart";

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: MainView(),
      debugShowCheckedModeBanner: false,
    );
  }
}

