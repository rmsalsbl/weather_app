import 'dart:convert';
import 'dart:html';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //membuat var untuk data dummy
  int? temp;

  String location = 'Jonggol';

  String weather = 'heavyrain';

  //buat var untuk kode kotanya
  int woied = 44418;
  String errorMessage = '';

  //var unutk mengampung gambar iconnya
  String abbreviation = '';

  //membuat var list untuk menampung data list minum dan maksimal temp dan juga iconnya selama 7 hari
  var minTemperatureForecast = List.filled(7, 0);
  var maxTemperatureForecast = List.filled(7, 0);
  var abbreviationForecast = List.filled(7, ' ');

  //masukan link url api untuk search
  String searchApiUrl =
      'https://www.metaweather.com/api/location/search/?query=';

  //masukan link url api untuk data location
  String searchLocation = 'https://www.metaweather.com/api/location/';

  @override
  void initState() {
    getLocation();
    getSevenDays();
    super.initState();
  }

  Future<void> getLocation() async {
    var locationAPiresult =
        await http.get(Uri.parse(searchLocation + woied.toString()));
    var result = jsonDecode(locationAPiresult.body);
    var consolidatedWeather = result["consolidated_weather"];
    var data = consolidatedWeather[0];

    setState(() {
      temp = data['the_temp'].round();
      weather = data['weather_state_name'].replaceAll(' ', '').toLowerCase();
      abbreviation = data['weather_state_abbr'];
    });
  }

  Future<void> getSearch(String input) async {
    try {
      var searchResult = await http.get(Uri.parse(searchApiUrl + input));
      var result = jsonDecode(searchResult.body)[0];
      setState(() {
        location = result['title'];
        woied = result['woeid'];
        errorMessage = '';
      });
    } catch (error) {
      setState(() {
        errorMessage =
            'Maaf kota yang anda cari tidak ada karena anda belum mempunyai ayang:( kaceiann dechh';
      });
    }
  }

  Future<void> getSevenDays() async {
    var today = DateTime.now();
    for(var i = 0; 1 < 7 ; i++ ){
      var sevenDaysResult = await http.get(Uri.parse(searchLocation + woied.toString() + '/' + DateFormat('y/M/d').format(today.add(Duration(days: i + 1))).toString()));
      var result = jsonDecode(sevenDaysResult.body);
      var data = result[0];

      setState(() {
        minTemperatureForecast[i] = data['min_temp'].round();
        maxTemperatureForecast[i] = data['max_temp'].round();
        abbreviationForecast[i] = data['weather_state_abbr'];
      });
    }
  }

  //buat function unutk menerima inputan di search bar
  Future<void> onTextFielSubmitted(String input) async {
    await getLocation();
    await getSearch(input);
    await getSevenDays();
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('asset/$weather.png'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.6), BlendMode.dstATop))),
      child: temp == null
          ? Center(child: CircularProgressIndicator())
          : Scaffold(
              backgroundColor: Colors.transparent,
              body: SingleChildScrollView(
                padding: EdgeInsets.only(top: 100),
                child: Column(
                  children: [
                    //untuk menampilkan icon, temp, dan location
                    Column(
                      children: [
                        Center(
                          child: Image.network(
                            'https://www.metaweather.com/static/img/weather/png/' +
                                abbreviation +
                                '.png',
                            width: 100,
                          ),
                        ),
                        Center(
                          child: Text(
                            temp.toString() + ' °C',
                            style: TextStyle(color: Colors.white, fontSize: 60),
                          ),
                        ),
                        Center(
                          child: Text(
                            location,
                            style: TextStyle(color: Colors.white, fontSize: 40),
                          ),
                        ),
                      ],
                    ),
                    //untuk menampilkan widget selama 7 hari
                    Padding(
                      padding:EdgeInsets.only(top: 50),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for(var i = 0 ; i < 7 ; i++)
                              forecastElement(
                                  i + 1,
                                  abbreviationForecast[i],
                                  maxTemperatureForecast[i],
                                  minTemperatureForecast[i])
                          ],
                        )
                      ),
                    ),
                    //membuat search bar
                    Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 300,
                            child: TextField(
                              onSubmitted: (String input) {
                                onTextFielSubmitted(input);
                              },
                              style:
                                  TextStyle(color: Colors.white, fontSize: 25),
                              decoration: InputDecoration(
                                  hintText: 'Search a location...',
                                  hintStyle: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Colors.white,
                                  )),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              errorMessage,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.red, fontSize: 15),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Widget forecastElement(daysFromNow, abbreviation, maxTemp, minTemp){
    var now = DateTime.now();
    var oneDayFromNow = now.add(Duration(days: daysFromNow));
    return Padding(
      padding: EdgeInsets.only(left: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(205, 212, 228, 0.2),
              borderRadius: BorderRadius.circular(10)
        ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(DateFormat.E().format(oneDayFromNow),
              style: TextStyle(color: Colors.white, fontSize: 25),),
            Text(DateFormat.MMMd().format(oneDayFromNow),
              style: TextStyle(color: Colors.white, fontSize: 20),),
            Padding(padding: EdgeInsets.symmetric(vertical: 16),
            child: Image.network(
              'https://www.metaweather.com/static/img/weather/png/' +
                  abbreviation +
                  '.png',
              width: 50,
            ),
            ),
            Text('High ' + maxTemp.toString() + '°C',
            style: TextStyle(color: Colors.white, fontSize: 20),),
            Text('Low ' + minTemp.toString() + '°C',
              style: TextStyle(color: Colors.white, fontSize: 20),),
          ],
        ),
      ),
      ),
    );
  }
}
