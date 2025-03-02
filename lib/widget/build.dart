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
  })  : _weather = weather;

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

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        // Temperature
        Text(
          "${widget._weather?.temperature?.celsius?.toStringAsFixed(0)}°",
          style: const TextStyle(
            fontSize: 80,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        // Weather condition
        Text(
          widget._weather?.weatherDescription ?? "",
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        // Location and date
        Text(
          "${DateFormat("HH:mm").format(widget._weather!.date!)} ",
          style: const TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "${DateFormat("EEEE, d MMMM yyyy").format(widget._weather!.date!)} ",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),

        const SizedBox(height: 20),

        // PM2.5 information
        if (widget.pm25 != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "PM2.5",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  " ${widget.pm25?.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: _getPM25Color(widget.pm25!),
                  ),
                ),
                const Text(
                  " µg/m³",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
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
}