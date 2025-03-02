import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';

class WeatherDisplay extends StatefulWidget {
  final bool isLoading;
  final String errorMessage;
  final Weather? _weather;
  final double? pm25;

  const WeatherDisplay({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required Weather? weather,
    required this.pm25,
  }) : _weather = weather;

  @override
  State<WeatherDisplay> createState() => _WeatherDisplayState();
}

class _WeatherDisplayState extends State<WeatherDisplay> {
  @override
  Widget build(BuildContext context) {
    return _buildMainWeatherDisplay();
  }

  Widget _buildMainWeatherDisplay() {
    if (widget.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (widget.errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          widget.errorMessage,
          style: const TextStyle(
              color: Colors.grey, fontSize: 50, fontWeight: FontWeight.bold),
        ),
      );
    } else if (widget._weather == null) {
      return const Center(
        child: Text("No weather data available"),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,  
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Location and date
          Text(
            "${DateFormat("EEEE, d MMMM yyyy").format(widget._weather!.date!)} ",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          // Location and date
          Text(
            "${DateFormat("HH:mm").format(widget._weather!.date!)} ",
            style: const TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          
          // PM 2.5
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "PM2.5",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    " ${widget.pm25?.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 75,
                      fontWeight: FontWeight.bold,
                      color: _getPM25Color(widget.pm25!),
                    ),
                  ),
                  const Text(
                    " µg/m³",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  // _getPM25Icon(widget.pm25!),
                ],
              ),
              const SizedBox(width: 20),
            ],
          ),
          const SizedBox(height: 10),
          // Temperature
          Text(
            "Temperature ${widget._weather?.temperature?.celsius?.toStringAsFixed(0)} °C",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
      
          // PM2.5 information
          if (widget.pm25 != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [],
              ),
            ),
        ],
      ),
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

  // Icon _getPM25Icon(double value) {
  //   if (value <= 12) {
  //     return Icon(Icons.sentiment_very_satisfied, color: Colors.green, size: 80); // สีเขียว
  //   } else if (value <= 35.4) {
  //     return Icon(Icons.mood, color: Colors.yellow, size: 120); // สีเหลือง
  //   } else if (value <= 55.4) {
  //     return Icon(Icons.sentiment_neutral, color: Colors.orange, size: 80); // สีส้ม
  //   } else if (value <= 150.4) {
  //     return Icon(Icons.sentiment_dissatisfied, color: Colors.red, size: 80); // สีแดง
  //   } else if (value <= 250.4) {
  //     return Icon(Icons.mood_bad, color: Colors.purple, size: 80); // สีม่วง
  //   } else {
  //     return Icon(Icons.sentiment_very_dissatisfied, color: Colors.brown, size: 80); // สีน้ำตาล
  //   }
  // }
}
