import 'package:flutter/material.dart';
import 'package:movie_discovery_app/screens/home_screen.dart';

void main(){
  runApp(MovieDiscoveryApp());
}

class MovieDiscoveryApp extends StatelessWidget {
  const MovieDiscoveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomeScreen(),);
  }
}