import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserController extends GetxController {
  var users = [].obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    fetchUsers();
    super.onInit();
  }

  Future<void> fetchUsers() async {
    try {
      isLoading(true);
      errorMessage('');

      final response = await http.get(Uri.parse('https://fakestoreapi.com/users'));
      if (response.statusCode == 200) {
        users.value = json.decode(response.body);
      } else {
        errorMessage('Failed to load users');
      }
    } catch (e) {
      errorMessage('Network Error');
    } finally {
      isLoading(false);
    }
  }
}