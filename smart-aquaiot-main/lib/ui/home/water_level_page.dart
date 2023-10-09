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
  double? value;

  String getWaterLevelMessage(double? waterLevel) {
    if (waterLevel == null) {
      return 'N/A';
    } else if (waterLevel == 0.0) {
      return 'STATUS: Below half, please check your water level';
    } else if (waterLevel == 1.0) {
      return 'STATUS: Upper half, you are in good condition!';
    } else {
      return 'Unknown water level';
    }
  }

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
          value = waterLevelData['value']?.toDouble();
        });
      } else {
        setState(() {
          deviceUID = 'N/A';
          name = 'N/A';
          value = null;
        });
      }
    }, onError: (error) {
      print('Error fetching water level: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    String waterLevelMessage = getWaterLevelMessage(value);

    return Scaffold(
      appBar: AppBar(
        title: Text('Water Level Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(
              'Level: ${value?.toStringAsFixed(2) ?? 'N/A'}',
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
            Text(
              waterLevelMessage,
              style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
