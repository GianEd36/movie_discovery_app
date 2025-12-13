import 'package:flutter/material.dart';
import 'package:movie_discovery_app/models/movide.dart';
import 'package:movie_discovery_app/screens/movie_detail_screen.dart';

class ListViewComponent extends StatelessWidget {
  const ListViewComponent({
    super.key,
    required this.movies,
    required this.imageBaseUrl,
    required this.favoriteMovieIds,
    required this.onToggleFavorite,
  });

  final List<Movie> movies;
  final String imageBaseUrl;
  final Set<int> favoriteMovieIds;
  final Function(Movie) onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return const Center(child: Text('No movies found.'));
    }
    
    // Use ListView.builder for efficient display of long lists
    return ListView.builder(
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        final isFavorite = favoriteMovieIds.contains(movie.id);
        
        return ListTile(
          // Leading image (movie poster)
          leading: movie.posterPath.isNotEmpty
              ? Image.network(
                  '$imageBaseUrl${movie.posterPath}',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.movie),
                )
              : const Icon(Icons.movie),
              
          // Movie Title
          title: Text(movie.title),
          
          // Movie Overview Snippet
          subtitle: Text(
            movie.overview,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          trailing: IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
            onPressed: () => onToggleFavorite(movie),
          ),

          // Action when the user taps the movie
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MovieDetailScreen(
                  movie: movie,
                  imageBaseUrl: imageBaseUrl,
                  isFavorite: isFavorite,
                  onToggleFavorite: onToggleFavorite,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

