import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class DisplayFeedingTimePage extends StatefulWidget {
  @override
  _DisplayFeedingTimePageState createState() => _DisplayFeedingTimePageState();
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
          if (_selectedUnit == 'seconds') {
            _currentFeedTime = '${feedTime ~/ 1000} seconds'; // Convert to seconds
          } else if (_selectedUnit == 'minutes') {
            _currentFeedTime = '${feedTime ~/ 60000} minutes'; // Convert to minutes
          } else if (_selectedUnit == 'hours') {
            _currentFeedTime = '${feedTime ~/ 3600000} hours'; // Convert to hours
          }
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
    DatabaseReference timestampReference =
        FirebaseDatabase.instance.reference().child('timestampFeedTime');
    timestampReference.set(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feeding Time'),
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
              'Current set feeding time is $_currentFeedTime',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  void _setFeedingTime() {
    int feedingTime;
    try {
      feedingTime = int.parse(_feedingTimeController.text);
    } catch (e) {
      print('Invalid input. Please enter a valid integer.');
      return;
    }

    if (_selectedUnit == 'minutes') {
      feedingTime *= 60; // Convert to seconds
    } else if (_selectedUnit == 'hours') {
      feedingTime *= 3600; // Convert to seconds
    }

    _showConfirmationDialog(feedingTime);
  }

  void _showConfirmationDialog(int feedingTime) {
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
                _writeToDatabase(feedingTime);
                _feedingTimeController.clear();
                Navigator.of(context).pop();
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
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
      DatabaseReference feedTimeReference =
          FirebaseDatabase.instance.reference().child('feedTime');
      DatabaseReference timestampReference =
          FirebaseDatabase.instance.reference().child('timestampFeedTime');

      String timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      int feedingTimeInMilliseconds = feedingTime * 1000;

      await feedTimeReference.set(feedingTimeInMilliseconds);
      await timestampReference.set(timestamp);

      _fetchCurrentFeedTime();
    } catch (e) {
      print('Error writing to the database: $e');
    }
  }
}
