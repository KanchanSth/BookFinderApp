import 'dart:convert';

import 'package:book_finder_app/core/configs/api_url.dart';
import 'package:http/http.dart' as http;

import 'dart:io';

class ApiService {
  Future<List<dynamic>> fetchBooks(
      {required String subject, int? maxResults = 10}) async {
    final url = Uri.parse("${ApiUrl.baseUrl}$subject&maxResults=$maxResults");
    print("Fetching books from URL: $url");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['items'] != null) {
          return data['items'];
        } else {
          throw Exception("No books found for '$subject'.");
        }
      } else {
        throw Exception("Failed to load books (Error ${response.statusCode})");
      }
    } on SocketException {
      throw Exception("No internet connection. Please check your network.");
    } on FormatException {
      throw Exception("Invalid response format from server.");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }
}
