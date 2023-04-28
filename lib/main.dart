import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';
import 'package:meteo/my_flutter_app_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoder_location/geocoder.dart';
import 'package:geocoder_location/model.dart';
import 'package:geocoder_location/services/base.dart';
import 'package:geocoder_location/services/distant_google.dart';
import 'package:geocoder_location/services/local.dart';
import 'package:country_code/country_code.dart';
import 'dart:convert';
import 'dart:async';
import 'temps.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  locate location = locate();
  location._determinePosition();
  Position position = await location._determinePosition();
  final latitude = position.latitude;
  final longitude = position.longitude;
  final coordinates = new Coordinates(latitude, longitude);
  print(coordinates);

  List<Placemark> ville = await placemarkFromCoordinates(latitude, longitude);

  runApp(MaterialApp(
    home: Menu(ville.first.country.toString(), title: "Meteo"),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
    );
  }
}

class Menu extends StatefulWidget {
  Menu(String ville, {Key? key, required this.title}) : super(key: key) {
    this.villeUtilisateur = ville;
  }
  String villeUtilisateur = '';
  final String title;
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  List<String> villes = [];
  late String villeChoisie = 'Bamako';
  String key = "villes";
  late Temps tempsActuell = Temps();

  final String url = "";
  String DATA = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
    obtenir();
    CallApi();
  }

  Future fetchData() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: (tempsActuell == null)
            ? Center(
                child: Text((villeChoisie == null)
                    ? widget.villeUtilisateur
                    : villeChoisie),
              )
            : Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(assetName()),
                    fit: BoxFit.cover,
                  ),
                ),
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    texteAvecStyle(tempsActuell.name, fontSize: 30.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        texteAvecStyle("${tempsActuell.temp.toInt()} °C",
                            fontSize: 50.0),
                        Image.asset(tempsActuell.icon)
                      ],
                    ),
                    texteAvecStyle(tempsActuell.main, fontSize: 30.0),
                    texteAvecStyle(tempsActuell.description, fontSize: 25.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Icon(
                              MyFlutterApp.temperature_high,
                              color: Colors.white,
                              size: 30.0,
                            ),
                            texteAvecStyle("${tempsActuell.pressure}",
                                fontSize: 20.0),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Icon(
                              MyFlutterApp.water_drop,
                              color: Colors.white,
                              size: 30.0,
                            ),
                            texteAvecStyle("${tempsActuell.humidity}",
                                fontSize: 20.0),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Icon(
                              MyFlutterApp.arrow_up,
                              color: Colors.white,
                              size: 30.0,
                            ),
                            texteAvecStyle("${tempsActuell.temp_max}",
                                fontSize: 20.0),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Icon(
                              MyFlutterApp.down,
                              color: Colors.white,
                              size: 30.0,
                            ),
                            texteAvecStyle("${tempsActuell.temp_min}",
                                fontSize: 20.0),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
        drawer: Drawer(
          child: Container(
            child: ListView.builder(
                itemCount: villes.length + 2,
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return DrawerHeader(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        texteAvecStyle("Mes villes", fontSize: 22.0),
                        ElevatedButton(
                          onPressed: () {
                            ajoutVille();
                          },
                          child: texteAvecStyle("Ajouter une ville",
                              color: Colors.white),
                        )
                      ],
                    ));
                  } else if (i == 1) {
                    return ListTile(
                      title: texteAvecStyle(widget.villeUtilisateur),
                      onTap: () {
                        setState(() {
                          villeChoisie = '';
                          CallApi();
                          Navigator.pop(context);
                        });
                      },
                    );
                  } else {
                    String ville = villes[i - 2];
                    return ListTile(
                      title: texteAvecStyle(ville),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: (() => supprimer(ville)),
                      ),
                      onTap: () {
                        setState(() {
                          villeChoisie = ville;
                          CallApi();
                          Navigator.pop(context);
                        });
                      },
                    );
                  }
                }),
          ),
        ));
  }

  String assetName() {
    if (tempsActuell.icon.contains("d")) {
      return "asset_store/n.jpg";
    } else if (tempsActuell.icon.contains("01") ||
        tempsActuell.icon.contains("02") ||
        tempsActuell.icon.contains("03")) {
      return "asset_store/jour2.png";
    } else {
      return "asset_store/jour2.png";
    }
  }

  Text texteAvecStyle(String data,
      {color = Colors.black,
      fontSize = 17.0,
      FontStyle = FontStyle.italic,
      textAlign = TextAlign.center}) {
    return Text(
      data,
      textAlign: textAlign,
      style: TextStyle(color: color, fontStyle: FontStyle, fontSize: fontSize),
    );
  }

  Future<void> ajoutVille() async {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext buildcontext) {
          return SimpleDialog(
            contentPadding: const EdgeInsets.all(20.0),
            title: texteAvecStyle('Ajoutez une ville',
                fontSize: 22.0, color: Colors.blue),
            children: <Widget>[
              TextField(
                decoration: const InputDecoration(labelText: 'ville :'),
                onSubmitted: (String str) {
                  ajouter(str);
                  Navigator.pop(buildcontext);
                },
              )
            ],
          );
        });
  }

  void obtenir() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final List<String>? liste = sharedPreferences.getStringList(key);
    if (liste != null) {
      setState(() {
        villes = liste;
      });
    }
  }

  void ajouter(String str) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    villes.add(str);
    await sharedPreferences.setStringList(key, villes);
    obtenir();
  }

  void supprimer(String str) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    villes.remove(str);
    await sharedPreferences.setStringList(key, villes);
    obtenir();
  }

  /*oid coordonnees() async {
    String str = '';
    if (villeChoisie == null) {
      str = widget.villeUtilisateur;
    } else {
      str = villeChoisie;
    }

    List<Location> coord = await locationFromAddress(str);
    if (coord != null) {
      coord.forEach((Location) {
        print(Location.toString());
      });
    }
  }
  */

  void CallApi() async {
    String str = '';
    if (villeChoisie == 'Bamako') {
      str = widget.villeUtilisateur;
    } else {
      str = villeChoisie;
    }
    print(str);
    List<Location> coord = await locationFromAddress(str);
    if (coord != null) {
      final lat = coord.first.latitude;
      final lon = coord.first.longitude;
      String lang = Localizations.localeOf(context).languageCode;
      final key1 = "a5c46763f9695e9f0a36f4450246c476";

      String ApiUrl =
          "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&lang=$lang&appid=$key1";
      final reponse = await http.get(Uri.parse(ApiUrl));
      if (reponse.statusCode == 200) {
        print(reponse.body);
        Temps temps = new Temps();
        Map map = json.decode(reponse.body);
        temps.fromJSON(map);
        setState(() {
          tempsActuell = temps;
        });
      }
    }
  }
}

class locate {
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }
}
