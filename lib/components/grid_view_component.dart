import 'package:flutter/material.dart';
import 'package:movie_discovery_app/models/movide.dart';

class GridViewComponent extends StatelessWidget {
  const GridViewComponent({
    super.key,
    required Future<List<Movie>> popularMoviesFuture,
    required String imageBaseUrl,
  }) : _popularMoviesFuture = popularMoviesFuture, _imageBaseUrl = imageBaseUrl;

  final Future<List<Movie>> _popularMoviesFuture;
  final String _imageBaseUrl;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Movie>>(
      future: _popularMoviesFuture,
      builder: (context, snapshot) {
        // --- Error and Loading Handling (Same as ListView) ---
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final movies = snapshot.data!;
          
          // --- The GridView Implementation ---
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              // 1. Define how the grid cells should be laid out
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 items per row
                childAspectRatio: 0.65, // Adjust item width/height ratio
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                
                return GestureDetector(
                  onTap: () {
                    // TODO: Navigate to the movie details screen
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 2. Movie Poster (takes up most of the space)
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: movie.posterPath.isNotEmpty
                              ? Image.network(
                                  '$_imageBaseUrl${movie.posterPath}',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => 
                                      const Center(child: Icon(Icons.movie_filter, size: 50)),
                                )
                              : const Center(child: Icon(Icons.movie)),
                        ),
                      ),
                      // 3. Movie Title (small text below the poster)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          movie.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        } else {
          return const Center(child: Text('No movies found.'));
        }
      },
    );
  }
}