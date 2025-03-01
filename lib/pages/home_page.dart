import 'dart:convert';
import 'package:airtest/consts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();

  // เอาไว้ปรับใน appbar
  // @override
  // Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _HomePageState extends State<HomePage> {
  final WeatherFactory _wf = WeatherFactory(openWeatherAPIKEY);
  Weather? _weather;
  double? pm25; // เก็บค่าฝุ่น PM2.5
  bool isLoading = false;
  String errorMessage = '';
  String selectedCity = 'Nakhon Ratchasima'; // จังหวัดเริ่มต้น

  List<String> cities = [];
  TextEditingController cityController =
      TextEditingController(); // Controller สำหรับ TextField
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchCities(String text) async {
    final String url =
        'http://api.openweathermap.org/data/2.5/find?q=bangkok&appid=$openWeatherAPIKEY';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          // ตัวอย่างการดึงชื่อเมืองจากผลลัพธ์
          cities = List<String>.from(data['list'].map((city) => city['name']));
        });
      } else {
        // หากเกิดข้อผิดพลาดในการดึงข้อมูล
        print('Error: Unable to fetch cities');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // ดึงข้อมูลสภาพอากาศ
  Future<void> _fetchWeather() async {
    try {
      final weather = await _wf.currentWeatherByCityName(selectedCity);
      setState(() {
        _weather = weather;
      });
      _fetchPM25(weather.latitude!, weather.longitude!);
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
      });
    }
  }

  // ดึงข้อมูลค่าฝุ่น PM2.5
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
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.orange[100],
    appBar: AppBar(
      titleTextStyle: TextStyle(
        fontSize: 24,
        color: Colors.white, // สีข้อความใน title
        fontWeight: FontWeight.bold,
      ),
      title: Center(
        child: _isSearching
            ? TextField(
                controller: cityController,
                autofocus: true,
                style: TextStyle(color: Colors.orange[800],fontSize: 24), // สีข้อความใน TextField
                decoration: InputDecoration(
                  hintText: 'ค้นหาชื่อเมือง...',
                  hintStyle: TextStyle(
                    color: Colors.orange[800], // สีของ hint
                    fontWeight: FontWeight.bold,
                  ),
                  border: InputBorder.none,
                ),
                onSubmitted: (newCity) {
                  setState(() {
                    selectedCity = newCity; // อัพเดทชื่อเมืองเมื่อกด Enter
                    _isSearching = false; // ปิด TextField
                  });
                },
              )
            : Row(
                children: [
                  Icon(Icons.pin_drop_outlined),
                  SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isSearching = true; // เปลี่ยนเป็น TextField เมื่อคลิกที่ชื่อ
                      });
                    },
                    child: selectedCity.isEmpty
                        ? _locationHeader()
                        : Text(
                            selectedCity,
                            style: TextStyle(color: Colors.orange[800]), // สีข้อความในชื่อเมือง
                          ),
                  ),
                  SizedBox(width: 5),
                  IconButton(
                    icon: Icon(Icons.search, color: Colors.orange[800]), // สีไอคอนค้นหา
                    onPressed: () {
                      setState(() {
                        _isSearching = true; // เปิด TextField เมื่อกดปุ่มค้นหา
                      });
                      _fetchCities(cityController.text); // ดึงข้อมูลเมืองเมื่อกดปุ่มค้นหา
                    },
                  ),
                ],
              ),
      ),
      backgroundColor: Colors.orange[100], // สีพื้นหลังของ AppBar
      iconTheme: IconThemeData(color: Colors.orange[800]), // สีไอคอนทั้งหมดใน AppBar
    ),
    body: SingleChildScrollView(
      child: Column(
        children: [
          _buildUI(),
          ListView.builder(
            shrinkWrap: true,
            itemCount: cities.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(cities[index]),
                onTap: () {
                  setState(() {
                    selectedCity = cities[index]; // ตั้งค่าเมื่อเลือกเมือง
                  });
                },
              );
            },
          ),
        ],
      ),
    ),
  );
}


  // ignore: unused_element
  Widget _buildUI() {
    if (_weather == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Center(
      child: SizedBox(
        child: Column(
          children: [
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.05),
            _weatherIcon(),
            _currentTemp(),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),
            _dateTimeinfo(),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.05),
            _pm25Widget(), // เพิ่ม Widget แสดงค่าฝุ่น PM2.5
          ],
        ),
      ),
    );
  }

  Widget _locationHeader() {
    return Text(
      _weather?.areaName ?? "",
      style: TextStyle(
          fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange[800]),
    );
  }

  Widget _dateTimeinfo() {
    DateTime now = _weather!.date!;
    return Column(
      children: [
        Text(
          DateFormat("h:mm a").format(now),
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.orange[800]),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              DateFormat("EEEE,  ").format(now),
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[800]),
            ),
            Text(
              DateFormat.yMMMMd('en_US').format(now),
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[800]),
            )
          ],
        )
      ],
    );
  }

  Widget _weatherIcon() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: MediaQuery.sizeOf(context).height * 0.2,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                  "http://openweathermap.org/img/wn/${_weather?.weatherIcon}@4x.png"),
            ),
          ),
        ),
        Text(_weather?.weatherDescription ?? "",
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.orange)),
      ],
    );
  }

  Widget _currentTemp() {
    return Text(
      "${_weather?.temperature?.celsius?.toStringAsFixed(0)}° C",
      style: TextStyle(
          fontSize: 48, fontWeight: FontWeight.bold, color: Colors.orange[800]),
    );
  }

  // Widget สำหรับแสดงค่าฝุ่น PM2.5
  Widget _pm25Widget() {
    if (isLoading) {
      return CircularProgressIndicator();
    } else if (errorMessage.isNotEmpty) {
      return Text(errorMessage,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.red, fontSize: 16));
    } else if (pm25 != null) {
      return SizedBox(
        child: Column(
            children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Text(
                "PM2.5 : ",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w200,
                  color: Colors.orange),
              ),
              Text(
                "$pm25",
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[500]),
              ),
              Text(
                " µg/m³",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w200,
                  color: Colors.orange),
              ),
              ],
            ),
            ],
          
        ),
      );
    } else {
      return Text("ไม่มีข้อมูลค่าฝุ่น",
          style: TextStyle(fontSize: 16, color: Colors.grey));
    }
  }
}
