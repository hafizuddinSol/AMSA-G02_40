import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class TemperaturePage extends StatefulWidget {
  @override
  _TemperaturePageState createState() => _TemperaturePageState();
}

class _TemperaturePageState extends State<TemperaturePage> {
  DatabaseReference _temperatureRef =
      FirebaseDatabase.instance.reference().child('Living Room/temperature');

  String? deviceUID = 'N/A';
  String? name = 'N/A';
  double? temperature;

  @override
  void initState() {
    super.initState();
    _temperatureRef.onValue.listen((event) {
      final DataSnapshot snapshot = event.snapshot;
      final Map<dynamic, dynamic>? temperatureData =
          snapshot.value as Map<dynamic, dynamic>?;

      if (temperatureData != null) {
        setState(() {
          deviceUID = temperatureData['DeviceUID'] ?? 'N/A';
          name = temperatureData['Name'] ?? 'N/A';
          temperature = temperatureData['value']?.toDouble();
        });
      } else {
        setState(() {
          deviceUID = 'N/A';
          name = 'N/A';
          temperature = null;
        });
      }
    }, onError: (error) {
      print('Error fetching temperature: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Temperature Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Temperature: ${temperature?.toStringAsFixed(2) ?? 'N/A'}°C',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              'Name: $name',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              'Device UID: $deviceUID',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
