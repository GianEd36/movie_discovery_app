import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  bool layoutIsToggled = false;

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
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (BuildContext context, int index) {
                return Card(child: ListTile(title: Text('This is a listview layout'),));
              },
            ),
          )
          else
          Expanded(
            flex: 6,
            child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemCount: 10,
            itemBuilder: (BuildContext context, int index) {
              return Card(child: GridTile(child: Text('This is a gridview layout')));
            },
          ),)
          ,
        ],
      ),
    );
  }
}