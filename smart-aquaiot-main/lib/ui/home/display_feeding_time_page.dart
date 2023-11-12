import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class DisplayFeedingTimePage extends StatefulWidget {
  @override
  _DisplayFeedingTimePageState createState() =>
      _DisplayFeedingTimePageState();
}

class _DisplayFeedingTimePageState extends State<DisplayFeedingTimePage> {
  TextEditingController _feedingTimeController = TextEditingController();
  String _selectedUnit = 'seconds';
  String _currentFeedTime = 'N/A';
  String _currentTimestamp = 'N/A';

  @override
  void initState() {
    super.initState();
    _fetchCurrentFeedTime();
  }

  void _fetchCurrentFeedTime() async {
  DatabaseReference feedTimeReference =
      FirebaseDatabase.instance.reference().child('feedTime');
  DatabaseReference timestampReference =
      FirebaseDatabase.instance.reference().child('timestampFeedTime');

  try {
    DatabaseEvent feedTimeEvent = await feedTimeReference.once();
    DataSnapshot feedTimeSnapshot = feedTimeEvent.snapshot;

    DatabaseEvent timestampEvent = await timestampReference.once();
    DataSnapshot timestampSnapshot = timestampEvent.snapshot;

    // Check if feedTimeSnapshot has a value
    if (feedTimeSnapshot.value != null) {
      int feedTime = feedTimeSnapshot.value as int;

      setState(() {
        _currentFeedTime = '$feedTime milliseconds';
      });
    } else {
      print('Error: No value found at /feedTime');
    }

    // Check if timestampSnapshot has a value
    if (timestampSnapshot.value != null) {
      String timestamp = timestampSnapshot.value as String;

      setState(() {
        _currentTimestamp = timestamp;
      });
    } else {
      print('Error: No value found at /timestampFeedTime');
    }
  } catch (e) {
    print('Error fetching feed time: $e');
  }
}
  void _writeTimestampToDatabase(String timestamp) {
    // Your logic to write timestamp to Firebase Realtime Database
    DatabaseReference timestampReference =
        FirebaseDatabase.instance.reference().child('timestampFeedTime');
    timestampReference.set(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feeding Interval Time'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: _feedingTimeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Time',
                    ),
                  ),
                ),
                SizedBox(width: 20),
                DropdownButton<String>(
                  value: _selectedUnit,
                  items: ['seconds', 'minutes', 'hours']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      _selectedUnit = value ?? 'seconds';
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
  onPressed: () => _setFeedingTime(),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.lightBlue,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  child: Text('Set Feeding Time'),
),
            SizedBox(height: 20),
            Text(
              'Current set interval time is $_currentFeedTime at $_currentTimestamp',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  void _setFeedingTime() {
  // Get the entered feeding time
  int feedingTime;
  try {
    feedingTime = int.parse(_feedingTimeController.text);
  } catch (e) {
    // Handle invalid input
    print('Invalid input. Please enter a valid integer.');
    return;
  }

  // Convert the feeding time to milliseconds based on the selected unit
  if (_selectedUnit == 'minutes') {
    feedingTime *= 60 * 1000; // Convert to milliseconds
  } else if (_selectedUnit == 'hours') {
    feedingTime *= 3600 * 1000; // Convert to milliseconds
  } else {
    feedingTime *= 1000; // Convert to milliseconds (default: seconds)
  }

  // Show confirmation dialog before writing to the database
  _showConfirmationDialog(feedingTime);
}

  void _showConfirmationDialog(int feedingTime) {
    // Your confirmation dialog logic goes here
    // For example, you can use the showDialog method to display a dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text(
              'Are you sure to set feeding time to ${_feedingTimeController.text} $_selectedUnit?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Your logic to write to Firebase Realtime Database
                _writeToDatabase(feedingTime);

                // Optional: Reset the text field
                _feedingTimeController.clear();

                // Close the dialog
                Navigator.of(context).pop();
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                // Close the dialog
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

 void _writeToDatabase(int feedingTime) async {
  try {
    // Your logic to write to Firebase Realtime Database
    DatabaseReference feedTimeReference =
        FirebaseDatabase.instance.reference().child('feedTime');
    DatabaseReference timestampReference =
        FirebaseDatabase.instance.reference().child('timestampFeedTime');

    // Get the current timestamp as a string
    String timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    // Write feeding time and timestamp to their respective nodes
    await feedTimeReference.set(feedingTime);
    await timestampReference.set(timestamp);

    // Update current set interval time and timestamp
    _fetchCurrentFeedTime(); // Remove the 'await' here
  } catch (e) {
    print('Error writing to the database: $e');
  }
}
}
