import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:movie_discovery_app/models/movide.dart';
import 'package:movie_discovery_app/services/api_service.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MovieDetailScreen extends StatefulWidget {
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
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final ApiService _apiService = ApiService();
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _fetchTrailer();
  }

  Future<void> _fetchTrailer() async {
    try {
      final key = await _apiService.fetchMovieTrailer(widget.movie.id);
      if (mounted && key != null) {
        setState(() {
          _controller = YoutubePlayerController(
            initialVideoId: key,
            flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
          );
        });
      }
    } catch (e) {
      debugPrint('Error fetching trailer: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie.title),
        backgroundColor: Colors.green.shade300,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              widget.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: widget.isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: () => widget.onToggleFavorite(widget.movie),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.movie.posterPath.isNotEmpty)
              SizedBox(
                width: double.infinity,
                height: 300,
                child: Image.network(
                  '${widget.imageBaseUrl}${widget.movie.posterPath}',
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
                    widget.movie.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(8),
                  Wrap(
                    spacing: 8,
                    children: widget.movie.genres
                        .map((genre) => Chip(label: Text(genre)))
                        .toList(),
                  ),
                  if (_controller != null) ...[
                    const Gap(16),
                    Text(
                      'Trailer',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(8),
                    YoutubePlayer(
                      controller: _controller!,
                      showVideoProgressIndicator: true,
                      progressIndicatorColor: Colors.green.shade300,
                      progressColors: ProgressBarColors(
                        playedColor: Colors.green.shade300,
                        handleColor: Colors.green.shade300,
                      ),
                    ),
                  ],
                  const Gap(16),
                  Text(
                    'Overview',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    widget.movie.overview,
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
