import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';


class PremiumPage extends StatelessWidget {
  const PremiumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium Page'),
      ),
      body: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: ListView(
            children: [
              SizedBox(
                height: 250,
                child: Lottie.network(
                'https://lottie.host/0f9abe8b-0027-4fb5-9b83-d9c821f20398/OCUVj0Hz3k.json',
                ),
              ),
              Center(child: Text("Loading . . .",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),)),
              ElevatedButton(
                  onPressed: () {
                    print("Get Premium");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12.0), // มุมโค้งของปุ่ม
                    ),
                    padding: EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 8.0), // เพิ่ม padding
                    elevation: 5, // เพิ่มเงาให้กับปุ่ม
                  ),
                  child: Text(
                    'Get premium to unlock', // ข้อความในปุ่ม
                    style: TextStyle(
                      color: Colors.white, // สีของข้อความ
                      fontSize: 18, // ขนาดข้อความ
                      fontWeight: FontWeight.bold, // น้ำหนักของข้อความ
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}