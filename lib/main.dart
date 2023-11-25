import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_enrico_api/screen/score_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ScoreListPage(),
    );
  }
}
