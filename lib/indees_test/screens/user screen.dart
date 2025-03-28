import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plants_app/indees_test/screens/user%20details%20page.dart';
import '../controller/user controller.dart';

class UsersListScreen extends StatelessWidget {
  final UserController userController = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 2,
      ),
      body: Obx(() {
        if (userController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (userController.errorMessage.isNotEmpty) {
          return Center(
            child: Text(
              userController.errorMessage.value,
              style: const TextStyle(fontSize: 16, color: Colors.redAccent),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: userController.fetchUsers,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            itemCount: userController.users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              var user = userController.users[index];
              return GestureDetector(
                onTap: () {
                  Get.to(() => UserDetailsScreen(user: user));
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.teal.shade100,
                          child: Text(
                            user["name"]["firstname"][0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${user["name"]["firstname"]} ${user["name"]["lastname"]}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user["email"],
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
