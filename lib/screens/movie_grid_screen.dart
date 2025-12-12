import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:movie_discovery_app/components/grid_view_component.dart';
import 'package:movie_discovery_app/models/movide.dart';
import 'package:movie_discovery_app/services/api_service.dart'; // Needed for image base URL

class MovieGridScreen extends StatefulWidget {
  const MovieGridScreen({super.key});

  @override
  State<MovieGridScreen> createState() => _MovieGridScreenState();
}

class _MovieGridScreenState extends State<MovieGridScreen> {
  late Future<List<Movie>> _popularMoviesFuture;
  final String _imageBaseUrl = dotenv.env['TMDB_IMAGE_BASE_URL']!;

  @override
  void initState() {
    super.initState();
    _popularMoviesFuture = ApiService().fetchPopularMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Popular Movies (Grid)')),
      body: GridViewComponent(popularMoviesFuture: _popularMoviesFuture, imageBaseUrl: _imageBaseUrl),
    );
  }
}
