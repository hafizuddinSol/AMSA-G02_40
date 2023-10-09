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
  String timestamp = 'Latest data received on (date), (time) \nNote: Time generated are 5 secs±';

  void updateTimestamp() {
    final now = DateTime.now();
    final formattedDate = '${now.year}-${now.month}-${now.day}';
    final formattedTime = '${now.hour}:${now.minute}:${now.second}';
    setState(() {
      timestamp =
          'Latest data received on $formattedDate, $formattedTime \nNote: Time generated are 5 secs±';
    });
  }

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
          updateTimestamp(); // Update timestamp when new data is received
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
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: timestamp,
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
