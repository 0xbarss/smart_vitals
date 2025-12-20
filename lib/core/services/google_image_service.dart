import 'dart:convert';
import 'package:http/http.dart' as http;

class GoogleImageService {
  final String apiKey = "AIzaSyBMAfAtmjmvh8IIQsZRPDTwv4GXEMOICWw";
  final String cx = "f4f0438cb374a449e";

  Future<String?> fetchRecipeImage(String title) async {
    final query = Uri.encodeComponent("$title dish");
    final url = "https://www.googleapis.com/customsearch/v1?key=$apiKey&cx=$cx&q=$query&searchType=image&num=1";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['items'] != null && data['items'].isNotEmpty) {
          return data['items'][0]['link'];
        }
      } else if (response.statusCode == 429) {
        print("Google API: Daily free limit of 100 requests reached.");
      }
    } catch (e) {
      print("Google Search Error: $e");
    }
    return null;
  }
}