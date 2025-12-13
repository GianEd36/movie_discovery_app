import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:movie_discovery_app/models/movide.dart';

class MovieDetailScreen extends StatelessWidget {
  final Movie movie;
  final String imageBaseUrl;
  final bool isFavorite;
  final Function(Movie) onToggleFavorite;

  const MovieDetailScreen({
    super.key,
    required this.movie,
    required this.imageBaseUrl,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movie.title),
        backgroundColor: Colors.green.shade300,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: () => onToggleFavorite(movie),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (movie.posterPath.isNotEmpty)
              SizedBox(
                width: double.infinity,
                height: 300,
                child: Image.network(
                  '$imageBaseUrl${movie.posterPath}',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Center(child: Icon(Icons.movie, size: 100)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Gap(8),
                  Wrap(
                    spacing: 8,
                    children: movie.genres
                        .map((genre) => Chip(label: Text(genre)))
                        .toList(),
                  ),
                  const Gap(16),
                  Text(
                    'Overview',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Gap(8),
                  Text(
                    movie.overview,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
