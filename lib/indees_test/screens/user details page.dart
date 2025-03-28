import 'package:flutter/material.dart';

class UserDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  UserDetailsScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${user["name"]["firstname"]} ${user["name"]["lastname"]}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${user["email"]}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Phone: ${user["phone"]}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Address: ${user["address"]["street"]}, ${user["address"]["city"]}', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}