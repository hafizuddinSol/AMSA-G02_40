import 'dart:async';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class FeedNowPage extends StatefulWidget {
  @override
  _FeedNowPageState createState() => _FeedNowPageState();
}

class _FeedNowPageState extends State<FeedNowPage> {
  final DatabaseReference _feedFishReference;
  final DatabaseReference _timestampReference;

  bool _isButtonDisabled = false;
  List<String> _logMessages = [];

  _FeedNowPageState()
      : _feedFishReference = FirebaseDatabase.instance.ref().child('feedFish'),
        _timestampReference = FirebaseDatabase.instance
            .ref()
            .child('timestamp')
            .child('feedFishEngaged');

  @override
  void initState() {
    super.initState();

    // Add a listener to update log messages when data changes in the database
    _timestampReference.onChildAdded.listen((event) {
      DataSnapshot dataSnapshot = event.snapshot;
      Map<dynamic, dynamic> logData =
          (dataSnapshot.value as Map<dynamic, dynamic>);
      User? currentUser = FirebaseAuth.instance.currentUser;
      String userUID = currentUser?.uid ?? "N/A";

      // Only display/load timestamp for the current logged-in UserUID
      if (logData['userUID'] == userUID) {
        String logMessage =
            'Feed Fish Button Pressed - ${logData['timestamp']}';
        _addLogMessage(logMessage);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feed Now Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 100), // Adjust the height based on your preference
            ElevatedButton(
              onPressed: _isButtonDisabled ? null : _feedFish,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: Size(200, 100), // Adjust button size
              ),
              child: Text('Feed Now'),
            ),
            SizedBox(height: 50),
            // Display log messages using ListView.builder
            Expanded(
              child: ListView.builder(
                itemCount: _logMessages.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      _logMessages[index],
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _feedFish() async {
    if (!_isButtonDisabled) {
      // Disable the button to prevent spamming
      setState(() {
        _isButtonDisabled = true;
      });

      // Get current timestamp
      DateTime timestamp = DateTime.now();

      // Format timestamp to display only up to seconds
      String formattedTimestamp =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp);

      // Get current user UID
      User? currentUser = FirebaseAuth.instance.currentUser;
      String userUID = currentUser?.uid ?? "N/A";

      // Write "Now" to Firebase Realtime Database (feedfish node)
      _feedFishReference.set("Now");

      // Write "Not" to Firebase Realtime Database (after 3 seconds)
      Timer(Duration(seconds: 3), () {
        _feedFishReference.set("Not");

        // Enable the button after the cooldown period
        setState(() {
          _isButtonDisabled = false;
        });
      });

      // Write to Firebase Realtime Database (timestamp node)
      _timestampReference.child(formattedTimestamp).set({
        'timestamp': formattedTimestamp,
        'userUID': userUID,
      });
    } else {
      // Show a message indicating that the user is spamming
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Calm Down!'),
            content: Text('You are spamming the button too much!'),
          );
        },
      );
    }
  }

  void _addLogMessage(String message) {
    setState(() {
      _logMessages.add(message);
    });
  }
}
