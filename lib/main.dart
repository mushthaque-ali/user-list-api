import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plants_app/ui/onboarding_screen.dart';

void main(){
  runApp(MaterialApp(home: MyApp(),));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) :super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Onboarding Screen',
      debugShowCheckedModeBanner: false,
    );
  }
}
