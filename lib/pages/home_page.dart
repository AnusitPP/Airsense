import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';
import 'package:http/http.dart' as http;
import 'package:airtest/consts.dart';
import 'package:airtest/forecast_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
        errorMessage = 'Error: City Not Found Try agin';
        isLoading = false;
      });
    }
  }

//ฟังชันการเปลี่ยนตัวอักษรพิมพ์แรกเป็นตัวพิมพ์ใหญ่อัตโนมัติ
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
        borderRadius: BorderRadius.circular(0), // ลบการกำหนดขอบมุม
        child: Column(
          children: [
            // Search bar at top
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
                                    selectedCity = capitalizeFirstLetter(selectedCity);
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
              child: _buildMainWeatherDisplay(),
            ),

            // Forecast section
            Container(
              height: 140,
              color: Colors.white,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(vertical: 10),
                // children: forecastData.map((data) {
                //   return _buildDayForecast(
                //       data['day'],
                //       data['precipitation'],
                //       data['highTemp'],
                //       data['lowTemp'],
                //       data['isSelected'] ? Colors.cyan : Colors.cyan.shade100,
                //       data['isSelected']);
                // }).toList(),
              ),
            ),

            // Bottom wave decoration
            Container(
              height: 60,
              child: CustomPaint(
                size: const Size(double.infinity, 60),
                painter: WavePainter(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainWeatherDisplay() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          errorMessage,
          style: const TextStyle(
              color: Colors.grey, fontSize: 50, fontWeight: FontWeight.bold),
        ),
      );
    } else if (_weather == null) {
      return const Center(
        child: Text("No weather data available"),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        // Temperature
        Text(
          "${_weather?.temperature?.celsius?.toStringAsFixed(0)}°",
          style: const TextStyle(
            fontSize: 80,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        // Weather condition
        Text(
          _weather?.weatherDescription ?? "",
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        // Location and date
        Text(
          "${DateFormat("HH:mm").format(_weather!.date!)} ",
          style: const TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "${DateFormat("EEEE, d MMMM yyyy").format(_weather!.date!)} ",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),

        const SizedBox(height: 20),

        // PM2.5 information
        if (pm25 != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                const Text(
                  "PM2.5",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      " ${pm25?.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _getPM25Color(pm25!),
                      ),
                    ),
                    const Text(
                      " µg/m³",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Color _getPM25Color(double value) {
    if (value <= 12) {
      return Colors.green;
    } else if (value <= 35.4) {
      return Colors.yellow;
    } else if (value <= 55.4) {
      return Colors.orange;
    } else if (value <= 150.4) {
      return Colors.red;
    } else if (value <= 250.4) {
      return Colors.purple;
    } else {
      return Colors.brown;
    }
  }

  Widget _buildDayForecast(String day, String precipitation, String highTemp,
      String lowTemp, Color color, bool isSelected) {
    return Container(
      width: 80,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isSelected ? color : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey,
          width: isSelected ? 0 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 5),
          Icon(
            _getWeatherIcon(precipitation),
            color: isSelected ? Colors.white : Colors.black,
            size: 30,
          ),
          const SizedBox(height: 5),
          Text(
            precipitation,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '$highTemp $lowTemp',
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(String precipitation) {
    double precip = double.tryParse(precipitation.replaceAll('%', '')) ?? 0;
    if (precip >= 60) {
      return Icons.thunderstorm;
    } else if (precip >= 40) {
      return Icons.grain;
    } else if (precip >= 20) {
      return Icons.cloud;
    } else {
      return Icons.wb_sunny;
    }
  }
}

// Custom painter for cloud with rain
class CloudRainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint cloudPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final Path cloudPath = Path();
    // Draw a simple cloud shape
    cloudPath.moveTo(size.width * 0.25, size.height * 0.5);
    cloudPath.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.35,
      size.width * 0.35,
      size.height * 0.35,
    );
    cloudPath.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.2,
      size.width * 0.5,
      size.height * 0.25,
    );
    cloudPath.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.15,
      size.width * 0.65,
      size.height * 0.3,
    );
    cloudPath.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.25,
      size.width * 0.75,
      size.height * 0.5,
    );
    cloudPath.close();

    canvas.drawPath(cloudPath, cloudPaint);

    // Draw rain drops
    final Paint rainPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Draw several rain drops
    for (int i = 0; i < 7; i++) {
      final double startX = size.width * (0.3 + i * 0.07);
      final double startY = size.height * 0.6;
      canvas.drawLine(
        Offset(startX, startY),
        Offset(startX + 5, startY + 15),
        rainPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Custom painter for waves at bottom
class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF20CCED),
          const Color(0xFF20CCED),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final Path path = Path();
    path.moveTo(0, size.height);

    // First wave
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height - 20,
      size.width * 0.5,
      size.height - 10,
    );

    // Second wave
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height,
      size.width,
      size.height - 15,
    );

    // Complete the path
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
