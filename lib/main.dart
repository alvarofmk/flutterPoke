import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pruebaflutter/poke.dart';
import 'dart:convert';

import 'package:pruebaflutter/pokeDetails.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prueba de flutter',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'Flutter pokemon'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String img = "";
  late Future<PokemonResponse> pokemon;

  Future<PokemonResponse> getPokemon() async {
    final response =
        await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/'));
    if (response.statusCode == 200) {
      return PokemonResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load pokemon');
    }
  }

  @override
  Widget build(BuildContext context) {
    pokemon = getPokemon();

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: FutureBuilder<PokemonResponse>(
        future: pokemon,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            PokemonResponse response = snapshot.data!;
            return GridView.count(
              crossAxisCount: 2,
              children: List.generate(response.results!.length, (index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              details(poke: response.results![index])),
                    );
                  },
                  child: Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${response.results![index].name}',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('${response.results![index].url}',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              }),
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          // By default, show a loading spinner.
          return const CircularProgressIndicator();
        },
      )), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class details extends StatelessWidget {
  details({super.key, required this.poke});
  Results poke;
  late Future<PokemonDetails> pokemon;

  Future<PokemonDetails> getPokemon(url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return PokemonDetails.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load pokemon');
    }
  }

  @override
  Widget build(BuildContext context) {
    pokemon = getPokemon(poke.url);

    return FutureBuilder<PokemonDetails>(
        future: pokemon,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            PokemonDetails response = snapshot.data!;
            return Scaffold(
                appBar: AppBar(
                  title: Text(response.name!),
                  elevation: 0,
                ),
                body: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      color: Colors.red,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 200,
                            height: 200,
                            child: Image.network(
                              response.sprites!.frontDefault!,
                              width: 140,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                response.name!,
                                style: TextStyle(
                                    color: Color.fromARGB(66, 27, 27, 27),
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                  response.types!
                                      .map((e) => e.type!.name)
                                      .join(", "),
                                  style: TextStyle(
                                      color: Color.fromARGB(66, 31, 31, 31),
                                      fontSize: 23))
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                )));
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          return const CircularProgressIndicator();
        });
  }
}
