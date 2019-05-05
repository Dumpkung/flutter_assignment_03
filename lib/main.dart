import 'package:flutter/material.dart';
import 'package:flutter_assignment_03/todopage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      // home: MyHomePage(),
      initialRoute: "/",
      routes: {
        "/": (context) => Todostate(),
      },
    );
  }
}
