import 'package:flutter/material.dart';
import 'package:movie_discovery_app/models/movide.dart';
import 'package:movie_discovery_app/screens/movie_detail_screen.dart';

class GridViewComponent extends StatelessWidget {
  const GridViewComponent({
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
          final isFavorite = favoriteMovieIds.contains(movie.id);
          
          return GestureDetector(
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
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 2. Movie Poster (takes up most of the space)
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: movie.posterPath.isNotEmpty
                            ? Image.network(
                                '$imageBaseUrl${movie.posterPath}',
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
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white,
                      ),
                      onPressed: () => onToggleFavorite(movie),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

