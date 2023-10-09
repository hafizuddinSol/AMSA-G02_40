import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class WaterLevelPage extends StatefulWidget {
  @override
  _WaterLevelPageState createState() => _WaterLevelPageState();
}

class _WaterLevelPageState extends State<WaterLevelPage> {
  DatabaseReference _waterLevelRef =
      FirebaseDatabase.instance.reference().child('Living Room/waterlevel');

  String? deviceUID = 'N/A';
  String? name = 'N/A';
  double? level;

  @override
  void initState() {
    super.initState();
    _waterLevelRef.onValue.listen((event) {
      final DataSnapshot snapshot = event.snapshot;
      final Map<dynamic, dynamic>? waterLevelData =
          snapshot.value as Map<dynamic, dynamic>?;

      if (waterLevelData != null) {
        setState(() {
          deviceUID = waterLevelData['DeviceUID'] ?? 'N/A';
          name = waterLevelData['Name'] ?? 'N/A';
          level = waterLevelData['Level']?.toDouble();
        });
      } else {
        setState(() {
          deviceUID = 'N/A';
          name = 'N/A';
          level = null;
        });
      }
    }, onError: (error) {
      print('Error fetching water level: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Water Level Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('This is the Water Level Page'),
            SizedBox(height: 20),
            Text(
              'Level: ${level?.toStringAsFixed(2) ?? 'N/A'}',
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
            ElevatedButton(
              onPressed: () {
                // Refresh the data by setting the state again
                setState(() {});
              },
              child: Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}
