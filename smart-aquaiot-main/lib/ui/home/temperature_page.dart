import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TemperaturePage extends StatefulWidget {
  @override
  _TemperaturePageState createState() => _TemperaturePageState();
}

class _TemperaturePageState extends State<TemperaturePage> {
  DatabaseReference _temperatureRef =
      FirebaseDatabase.instance.ref().child('Living Room/temperature');

  double? temperature;
  String timestamp =
      'Latest data received on (date), (time) \nNote: Time generated are 5 secs±';
  List<String> temperatureHistory = [];
  bool listenersActive = true; // Add a boolean flag

  void updateTimestamp() {
    final now = DateTime.now();
    final formattedDate = '${now.year}-${now.month}-${now.day}';
    final formattedTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    setState(() {
      timestamp =
          'Latest data received on $formattedDate, $formattedTime \nNote: Time generated is 5 secs±';
    });
  }

  @override
  void initState() {
    super.initState();
    loadTemperatureHistory(); // Load history data when the page initializes
    _temperatureRef.onValue.listen((event) {
      if (!listenersActive) return; // Check if listeners should be active
      final DataSnapshot snapshot = event.snapshot;
      final Map<dynamic, dynamic>? temperatureData =
          snapshot.value as Map<dynamic, dynamic>?;

      if (temperatureData != null) {
        final now = DateTime.now();
        final formattedTimestamp =
            '${now.year}-${now.month}-${now.day} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

        final temperatureReading =
            'Temperature: ${temperatureData['value']?.toDouble()?.toStringAsFixed(2) ?? 'N/A'}°C at $formattedTimestamp';

        if (!temperatureHistory.contains(temperatureReading)) {
          setState(() {
            temperature = temperatureData['value']?.toDouble();
            updateTimestamp();
            temperatureHistory.insert(0, temperatureReading);

            if (temperatureHistory.length > 15) {
              temperatureHistory.removeLast();
            }

            saveTemperatureHistory(); // Save updated history data
          });
        }
      }
    }, onError: (error) {
      print('Error fetching temperature: $error');
    });
  }

  Future<void> saveTemperatureHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('temperatureHistory', temperatureHistory);
  }

  Future<void> loadTemperatureHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final savedHistory = prefs.getStringList('temperatureHistory') ?? [];
    setState(() {
      temperatureHistory = savedHistory;
    });
  }

  @override
  void dispose() {
    listenersActive = false; // Set the flag to false when disposing the page
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Temperature Page'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 40), // Adjusted the height
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Temperature: ${temperature?.toStringAsFixed(2) ?? 'N/A'}°C',
                  style: TextStyle(fontSize: 24),
                ),
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
              SizedBox(height: 50), // Adjusted the height
              Container(
                height: 300, // Adjust the height as needed
                child: ListView.builder(
                  itemCount: temperatureHistory.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(temperatureHistory[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
