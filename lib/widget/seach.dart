import 'package:airtest/widget/build.dart';
import 'package:airtest/widget/wave.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:airtest/consts.dart';
import 'package:weather/weather.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final WeatherFactory _wf = WeatherFactory(openWeatherAPIKEY);
  Weather? _weather;
  double? pm25;
  bool isLoading = false;
  String errorMessage = '';
  String selectedCity = 'Nakhon Ratchasima';

  List<String> cities = [];
  TextEditingController cityController = TextEditingController();
  bool _isSearching = false;
  
  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    setState(() {
      isLoading = true;
    });

    try {
      final weather = await _wf.currentWeatherByCityName(selectedCity);
      setState(() {
        _weather = weather;
        isLoading = false;
      });
      _fetchPM25(weather.latitude!, weather.longitude!);
    } catch (e) {
      setState(() {
        errorMessage = 'Error: City Not Found. Try again';
        isLoading = false;
      });
    }
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Future<void> _fetchPM25(double lat, double lon) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final String url =
        'http://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$openWeatherAPIKEY';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          pm25 = data['list'][0]['components']['pm2_5'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Error: Unable to fetch data';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: Not a PM 2.5 Data';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: ClipRRect(
        borderRadius: BorderRadius.circular(0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _isSearching
                      ? Expanded(
                          child: TextField(
                            controller: cityController,
                            autofocus: true,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              hintText: 'Search city...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.search),
                                onPressed: () {
                                  setState(() {
                                    selectedCity = cityController.text;
                                    selectedCity =
                                        capitalizeFirstLetter(selectedCity);
                                    _isSearching = false;
                                  });
                                  _fetchWeather();
                                },
                              ),
                            ),
                            onSubmitted: (newCity) {
                              setState(() {
                                selectedCity = capitalizeFirstLetter(newCity);
                                cityController.text = selectedCity;
                                _isSearching = false;
                              });
                              _fetchWeather();
                            },
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            setState(() {
                              _isSearching = true;
                            });
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on),
                              const SizedBox(width: 8),
                              Text(
                                selectedCity,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.search),
                            ],
                          ),
                        ),
                ],
              ),
            ),
            // Main weather info section
            Expanded(
              child: WeatherDisplay(
                isLoading: isLoading,
                errorMessage: errorMessage,
                weather: _weather,
                pm25: pm25,
              ),
            ),
            CustomPaint(
              child: CustomPaint(
                size: Size(MediaQuery.of(context).size.width, 100),
                painter: WavePainter(),
              ),
            )
          ],
        ),
      ),
    );
  }
}