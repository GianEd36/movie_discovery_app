import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gap/gap.dart';
import 'package:movie_discovery_app/components/grid_view_component.dart';
import 'package:movie_discovery_app/components/list_view_component.dart';
import 'package:movie_discovery_app/models/movide.dart';
import 'package:movie_discovery_app/services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  bool layoutIsToggled = false;

  late Future<List<Movie>> _popularMoviesFuture;
  final String _imageBaseUrl = dotenv.env['TMDB_IMAGE_BASE_URL']!;

  @override
  void initState() {
    super.initState();
    // 2. Start fetching data when the screen is initialized
    _popularMoviesFuture = ApiService().fetchPopularMovies();
  }

  void toggleLayout(){
    setState(() {
      layoutIsToggled =! layoutIsToggled ;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.lightBlue.shade400,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(50),
            ListTile(
              title: Text('Movie Discovery App'),
              textColor: Colors.white,
            ),
            Gap(50),
            ListTile(
              title: Text('Login'),
            ),
            ListTile(
              title: Text('Search'),
            ),
            ListTile(
              title: Text('Favorite Movies'),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('Movie Discovery App'),
        backgroundColor: Colors.green.shade300,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: toggleLayout, 
            icon: Icon(layoutIsToggled ? Icons.window : Icons.view_list)
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Search a movie',
                  labelText: 'Search'
                ),                
              ),
            )
          ),
          //Listview and gridview layout
          if(!layoutIsToggled)
          Expanded(
            flex: 6,
            child: ListViewComponent(popularMoviesFuture: _popularMoviesFuture, imageBaseUrl: _imageBaseUrl),
          )
          else
          Expanded(
            flex: 6,
            child: GridViewComponent(popularMoviesFuture: _popularMoviesFuture, imageBaseUrl: _imageBaseUrl),
          )
          ,
        ],
      ),
    );
  }
}