import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'edit_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<Map<String, dynamic>?> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot snapshot =
      await FirebaseFirestore.instance.collection("users").doc(user.uid).get();
      return snapshot.data() as Map<String, dynamic>?;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> _fetchBuyedPlants() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('buyed_plants')
          .get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[900],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(  // User data fetch
        future: _fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Failed to load profile data"));
          }

          final userData = snapshot.data!;
          String username = userData["username"]?.toString() ?? "Unknown";
          String email = userData["email"]?.toString() ?? "Unknown";

          return FutureBuilder<List<Map<String, dynamic>>>(  // Purchased plants fetch
            future: _fetchBuyedPlants(),
            builder: (context, buyedSnapshot) {
              if (buyedSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (buyedSnapshot.hasError || !buyedSnapshot.hasData) {
                return const Center(child: Text("Failed to load purchased plants"));
              }

              final buyedPlants = buyedSnapshot.data!;

              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Person Icon
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.green.withOpacity(0.2),
                        child: const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // User Information
                      Text(
                        username,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      const SizedBox(height: 16),
                      // Edit Button
                      ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfilePage(
                                currentUsername: username,
                                currentEmail: email,
                              ),
                            ),
                          );
                          // If changes were made, refresh the profile page
                          if (result == true) {
                            setState(() {});
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[900],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Edit Profile',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Purchased Plants List
                      const Text(
                        'Purchased Plants:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      // Check if buyedPlants list is empty and show a message if so
                       buyedPlants.isEmpty
                          ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text("No purchased plants available."),
                      )
                          : Expanded(
                        child: ListView.builder(
                          itemCount: buyedPlants.length,
                          itemBuilder: (context, index) {
                            final plant = buyedPlants[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      plant['image'] ?? 'assets/default_image',
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            plant['plant']?.toString() ?? 'Unknown Plant',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '\$${plant['price']?.toString() ?? '0.00'}',
                                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
