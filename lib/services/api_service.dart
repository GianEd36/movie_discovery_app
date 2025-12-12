import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/movide.dart';


class ApiService {
  final String _apiKey = dotenv.env['TMDB_API_KEY']!;
  final String _baseUrl = dotenv.env['TMDB_BASE_URL']!;

  Future<List<Movie>> fetchPopularMovies() async {
    
    final String popularMoviesUrl = '${_baseUrl}movie/popular?language=en-US&page=1&api_key=$_apiKey';
    final response = await http.get(Uri.parse(popularMoviesUrl));

    if (response.statusCode == 200) {
      // Decode the JSON string into a Dart map
      final Map<String, dynamic> data = json.decode(response.body);
      
      // The movie list is nested under the 'results' key
      final List<dynamic> results = data['results']; 
      
      // Convert the list of JSON maps into a List<Movie> objects
      return results.map((json) => Movie.fromJson(json)).toList();
    } else {
      // Throw an exception to handle errors in the UI
      throw Exception('Failed to load popular movies: ${response.statusCode}');
    }
  }
}