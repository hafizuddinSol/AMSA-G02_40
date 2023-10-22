import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class TemperaturePage extends StatefulWidget {
  @override
  _TemperaturePageState createState() => _TemperaturePageState();
}

class _TemperaturePageState extends State<TemperaturePage> {
  DatabaseReference _temperatureRef =
      FirebaseDatabase.instance.ref().child('Living Room/temperature');

  double? temperature;
  String timestamp = 'Latest data received on (date), (time) \nNote: Time generated are 5 secs±';
  List<String> temperatureHistory = [];
 
  void updateTimestamp() {
    final now = DateTime.now();
    final formattedDate = '${now.year}-${now.month}-${now.day}';
    final formattedTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    setState(() {
      timestamp =
          'Latest data received on $formattedDate, $formattedTime \nNote: Time generated is 5 secs±';
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
          temperature = temperatureData['value']?.toDouble();
          updateTimestamp(); // Update timestamp when new data is received

          // Format the timestamp
          final now = DateTime.now();
          final formattedTimestamp = '${now.year}-${now.month}-${now.day} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

          // Create a string that combines the temperature and timestamp
          final temperatureReading = 'Temperature: ${temperature?.toStringAsFixed(2) ?? 'N/A'}°C at $formattedTimestamp';

          // Add the new temperature reading to the history
          temperatureHistory.insert(0, temperatureReading);

          // Ensure the history list only contains a certain number of entries, e.g., 10
          if (temperatureHistory.length > 15) {
            temperatureHistory.removeLast();
          }
        });
      } else {
        setState(() {
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
            SizedBox(height: 250),
            Center(
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: 800, // Set the desired height for the temperature history
                      child: ListView.builder(
        itemCount: temperatureHistory.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(temperatureHistory[index]),
          );
        },
      ),
    ),
  ),
)

          ],
        ),
      ),
    );
  }
}
