import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WaterLevelPage extends StatefulWidget {
  @override
  _WaterLevelPageState createState() => _WaterLevelPageState();
}

class _WaterLevelPageState extends State<WaterLevelPage> {
  DatabaseReference _waterLevelRef =
      FirebaseDatabase.instance.reference().child('Living Room/waterlevel');

  double? value;
  List<String> waterLevelHistory = [];

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
    loadWaterLevelHistory(); // Load history data when the page initializes
    _waterLevelRef.onValue.listen((event) {
      final DataSnapshot snapshot = event.snapshot;
      final Map<dynamic, dynamic>? waterLevelData =
          snapshot.value as Map<dynamic, dynamic>?;

      if (waterLevelData != null) {
        setState(() {
          value = waterLevelData['value']?.toDouble();

          // Format the timestamp
          final now = DateTime.now();
          final formattedTimestamp =
              '${now.year}-${now.month}-${now.day} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

          // Create a string that combines the water level and timestamp
          final waterLevelReading =
              'Level: ${value?.toStringAsFixed(2) ?? 'N/A'} at $formattedTimestamp';

          // Add the new water level reading to the history
          waterLevelHistory.insert(0, waterLevelReading);

          // Ensure the history list only contains a certain number of entries, e.g., 10
          if (waterLevelHistory.length > 10) {
            waterLevelHistory.removeLast();
          }

          saveWaterLevelHistory(); // Save updated history data
        });
      } else {
        setState(() {
          value = null;
        });
      }
    }, onError: (error) {
      print('Error fetching water level: $error');
    });
  }

  Future<void> saveWaterLevelHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('waterLevelHistory', waterLevelHistory);
  }

  Future<void> loadWaterLevelHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final savedHistory = prefs.getStringList('waterLevelHistory') ?? [];
    setState(() {
      waterLevelHistory = savedHistory;
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
              waterLevelMessage,
              style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20), // Added some space here
            Expanded(
              child: Container(
                child: ListView.builder(
                  itemCount: waterLevelHistory.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        waterLevelHistory[index],
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
