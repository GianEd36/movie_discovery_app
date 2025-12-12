import 'package:flutter/material.dart';
import 'package:movie_discovery_app/models/movide.dart';

class ListViewComponent extends StatelessWidget {
  const ListViewComponent({
    super.key,
    required Future<List<Movie>> popularMoviesFuture,
    required String imageBaseUrl,
  }) : _popularMoviesFuture = popularMoviesFuture, _imageBaseUrl = imageBaseUrl;

  final Future<List<Movie>> _popularMoviesFuture;
  final String _imageBaseUrl;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Movie>>(
      // 3. Provide the Future to the builder
      future: _popularMoviesFuture,
      builder: (context, snapshot) {
        // A. Handle Loading State
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } 
        // B. Handle Error State
        else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } 
        // C. Handle Success State
        else if (snapshot.hasData) {
          final movies = snapshot.data!;
          
          // Use ListView.builder for efficient display of long lists
          return ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              
              return ListTile(
                // Leading image (movie poster)
                leading: movie.posterPath.isNotEmpty
                    ? Image.network(
                        '$_imageBaseUrl${movie.posterPath}',
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
                
                // Action when the user taps the movie
                onTap: () {
                  // TODO: Navigate to the movie details screen
                },
              );
            },
          );
        } 
        // D. Handle No Data State
        else {
          return const Center(child: Text('No movies found.'));
        }
      },
    );
  }
}