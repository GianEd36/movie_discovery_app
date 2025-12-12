import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:movie_discovery_app/components/list_view_component.dart';
import 'package:movie_discovery_app/models/movide.dart';
import 'package:movie_discovery_app/services/api_service.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  late Future<List<Movie>> _popularMoviesFuture;
  final String _imageBaseUrl = dotenv.env['TMDB_IMAGE_BASE_URL']!;

  @override
  void initState() {
    super.initState();
    // 2. Start fetching data when the screen is initialized
    _popularMoviesFuture = ApiService().fetchPopularMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Popular Movies')),
      body: ListViewComponent(popularMoviesFuture: _popularMoviesFuture, imageBaseUrl: _imageBaseUrl),
    );
  }
}

