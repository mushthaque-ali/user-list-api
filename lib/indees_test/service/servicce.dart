import 'package:http/http.dart' as http;
import '../model/user model.dart';

class ApiService {
  static const String _baseUrl = "https://fakestoreapi.com/users";

  Future<List<User>> fetchUsers() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      return userFromJson(response.body);
    } else {
      throw Exception("Failed to load users");
    }
  }
}