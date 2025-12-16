import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final List<String> filterBy = <String>['Popular', 'Top-Rated', 'Upcoming', 'Favorites'];
  String _selectedFilter = 'Popular';

  List<Movie> _movies = [];
  List<Movie> _filteredMovies = [];
  final Set<int> _favoriteMovieIds = {};
  final List<Movie> _favoriteMovies = []; // Store full objects for favorites view

  bool _isLoading = false;
  String? _errorMessage;
  Timer? _debounce;
  
  final TextEditingController _searchController = TextEditingController();
  final String _imageBaseUrl = dotenv.env['TMDB_IMAGE_BASE_URL']!;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;

  @override
  void initState() {
    super.initState();
    _fetchMovies();
    _searchController.addListener(_filterMovies);
    
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      setState(() {
        _user = user;
      });
      if (user != null) {
        _fetchFavoritesFromFirestore();
      } else {
        // Clear favorites on logout
        setState(() {
          _favoriteMovieIds.clear();
          _favoriteMovies.clear();
          if (_selectedFilter == 'Favorites') {
            _movies = [];
            _filterMovies();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchFavoritesFromFirestore() async {
    if (_user == null) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_user!.uid)
          .collection('favorites')
          .get();

      final favoriteMovies = snapshot.docs.map((doc) {
        final data = doc.data();
        // Reconstruct Movie object from Firestore data
        // Note: We need to make sure we store all necessary fields
        return Movie(
          id: data['id'],
          title: data['title'],
          overview: data['overview'],
          posterPath: data['posterPath'],
          genreIds: List<int>.from(data['genreIds'] ?? []),
        );
      }).toList();

      setState(() {
        _favoriteMovies.clear();
        _favoriteMovies.addAll(favoriteMovies);
        _favoriteMovieIds.clear();
        _favoriteMovieIds.addAll(favoriteMovies.map((m) => m.id));
        
        if (_selectedFilter == 'Favorites') {
          _movies = _favoriteMovies;
          _filterMovies();
        }
      });
    } catch (e) {
      print('Error fetching favorites: $e');
    }
  }

  Future<void> _toggleFavorite(Movie movie) async {
    final isFavorite = _favoriteMovieIds.contains(movie.id);

    setState(() {
      if (isFavorite) {
        _favoriteMovieIds.remove(movie.id);
        _favoriteMovies.removeWhere((m) => m.id == movie.id);
      } else {
        _favoriteMovieIds.add(movie.id);
        _favoriteMovies.add(movie);
      }
      // If we are currently viewing favorites, we need to update the list immediately
      if (_selectedFilter == 'Favorites') {
        _movies = _favoriteMovies;
        _filterMovies();
      }
    });

    if (_user != null) {
      try {
        final userDocRef = _firestore.collection('users').doc(_user!.uid);
        final userFavoritesRef = userDocRef.collection('favorites');

        if (isFavorite) {
          // Remove from Firestore
          await userFavoritesRef.doc(movie.id.toString()).delete();
        } else {
          // Ensure the user document exists so it doesn't appear as a "ghost" (italics) in Console
          await userDocRef.set({
            'email': _user!.email,
            'lastActive': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          // Add to Firestore
          await userFavoritesRef.doc(movie.id.toString()).set({
            'id': movie.id,
            'title': movie.title,
            'overview': movie.overview,
            'posterPath': movie.posterPath,
            'genreIds': movie.genreIds,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      } catch (e) {
        print('Error updating favorite in Firestore: $e');
        // Optionally revert local state on error
      }
    }
  }

  Future<void> _login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Navigator.pop(context); // Close drawer or dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged in successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    }
  }

  Future<void> _register(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      
      // Create the user document explicitly
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      Navigator.pop(context); // Close drawer or dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registered and logged in successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pop(context); // Close drawer
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out')),
    );
  }

  void _showLoginDialog() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    bool isRegistering = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isRegistering ? 'Register' : 'Login'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isRegistering = !isRegistering;
                      });
                    },
                    child: Text(isRegistering
                        ? 'Already have an account? Login'
                        : 'Don\'t have an account? Register'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final email = emailController.text.trim();
                    final password = passwordController.text.trim();
                    if (email.isNotEmpty && password.isNotEmpty) {
                      if (isRegistering) {
                        _register(email, password);
                      } else {
                        _login(email, password);
                      }
                      Navigator.pop(context); // Close dialog
                    }
                  },
                  child: Text(isRegistering ? 'Register' : 'Login'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _fetchMovies() async {

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      List<Movie> movies;
      if (_selectedFilter == 'Favorites') {
        movies = _favoriteMovies;
      } else {
        final apiService = ApiService();
        switch (_selectedFilter) {
          case 'Top-Rated':
            movies = await apiService.fetchTopRatedMovies();
            break;
          case 'Upcoming':
            movies = await apiService.fetchUpcomingMovies();
            break;
          case 'Popular':
          default:
            movies = await apiService.fetchPopularMovies();
            break;
        }
      }

      setState(() {
        _movies = movies;
        _isLoading = false;
        _filterMovies(); // Apply any existing search query
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _filterMovies() {
    final query = _searchController.text.toLowerCase();
    
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.isEmpty) {
      setState(() {
        _filteredMovies = _movies;
      });
      return;
    }

    if (_selectedFilter == 'Favorites') {
      setState(() {
        _filteredMovies = _movies.where((movie) {
          final titleMatch = movie.title.toLowerCase().contains(query);
          final genreMatch = movie.genres.any((genre) => genre.toLowerCase().contains(query));
          return titleMatch || genreMatch;
        }).toList();
      });
    } else {
      _debounce = Timer(const Duration(milliseconds: 500), () async {
        setState(() {
          _isLoading = true;
        });

        try {
          final apiService = ApiService();
          final searchResults = await apiService.searchMovies(query);
          
          if (mounted) {
            setState(() {
              _filteredMovies = searchResults;
              _isLoading = false;
            });
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _errorMessage = e.toString();
            });
          }
        }
      });
    }
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
        backgroundColor: Colors.green.shade200,
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
            if (_user == null)
              ListTile(
                title: Text('Login'),
                onTap: _showLoginDialog,
              )
            else
              ListTile(
                title: Text('Logout (${_user!.email})'),
                onTap: _logout,
              ),
            ListTile(
              title: Text('Search'),
              onTap: () {
                Navigator.pop(context);
                // Focus on search field? Or just close drawer
              },
            ),
            ListTile(
              title: Text('Favorite Movies'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                setState(() {
                  _selectedFilter = 'Favorites';
                  _fetchMovies();
                });
              },
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
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Search by name or genre',
                      labelText: 'Search',
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                // _filterMovies is called by listener
                              },
                            )
                          : null,
                    ),                
                  ),
                )
              ),
              Expanded(
                flex: 2, // Increased flex to fit the dropdown text
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: DropdownButtonFormField<String>(
                    value: _selectedFilter,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    ),
                    items: filterBy.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedFilter = newValue;
                          _fetchMovies();
                        });
                      }
                    },
                  ),
                ),
              )
            ],
          ),
          //Listview and gridview layout
          Expanded(
            flex: 6,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text('Error: $_errorMessage'))
                    : !layoutIsToggled
                        ? ListViewComponent(
                            movies: _filteredMovies,
                            imageBaseUrl: _imageBaseUrl,
                            favoriteMovieIds: _favoriteMovieIds,
                            onToggleFavorite: _toggleFavorite,
                          )
                        : GridViewComponent(
                            movies: _filteredMovies,
                            imageBaseUrl: _imageBaseUrl,
                            favoriteMovieIds: _favoriteMovieIds,
                            onToggleFavorite: _toggleFavorite,
                          ),
          ),
        ],
      ),
    );
  }
}
