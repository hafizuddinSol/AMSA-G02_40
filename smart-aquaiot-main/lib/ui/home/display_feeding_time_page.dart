import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DisplayFeedingTimePage extends StatefulWidget {
  @override
  _DisplayFeedingTimePageState createState() =>
      _DisplayFeedingTimePageState();
}

class _DisplayFeedingTimePageState extends State<DisplayFeedingTimePage> {
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isButtonDisabled = false;
  int _setTimeCount = 0; // Counter to track the number of times the user has set the time
  final DatabaseReference _setTimeReference =
      FirebaseDatabase.instance.reference().child('setTime');

  @override
  void initState() {
    super.initState();

    // Get current user UID
    User? currentUser = FirebaseAuth.instance.currentUser;
    String userUID = currentUser?.uid ?? "N/A";

    // Listen for changes in the /setTime node for the current user
    _setTimeReference.child(userUID).onValue.listen((event) {
      DataSnapshot dataSnapshot = event.snapshot;
      Map<dynamic, dynamic> setTimeData =
          (dataSnapshot.value as Map<dynamic, dynamic>);

      // Update the counter based on the number of entries for the user
      _setTimeCount = setTimeData.length;

      // Check if the user has set the time three times
      if (_setTimeCount >= 3) {
        setState(() {
          _isButtonDisabled = true;
        });
      } else {
        setState(() {
          _isButtonDisabled = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Display Feeding Time Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _isButtonDisabled ? null : _setFeedingTime,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Set Feeding Time'),
            ),
            if (_isButtonDisabled)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'You have already set feeding time three times. To set a new time, please remove any existing times.',
                  style: TextStyle(
                    color: Colors.red,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            SizedBox(height: 20),
            StreamBuilder(
              stream: Stream.periodic(Duration(seconds: 1), (i) => i),
              builder: (context, snapshot) {
                return Text(
                  'Current Time: ${DateFormat('HH:mm:ss').format(DateTime.now())}',
                  style: TextStyle(fontSize: 18),
                );
              },
            ),
            SizedBox(height: 20),
            Text(
              'Feeding Times:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Display list of feeding times
            Expanded(
              child: FutureBuilder(
                future: _getFeedingTimes(),
                builder: (context, AsyncSnapshot<List<String>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    List<String> feedingTimes = snapshot.data ?? [];
                    if (feedingTimes.contains("No time has been selected")) {
                      // Display a message when no time has been selected
                      return Center(
                        child: Text("No time has been selected"),
                      );
                    } else {
                      // Display the list of feeding times with edit and delete buttons
                      return ListView.builder(
                        itemCount: feedingTimes.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(feedingTimes[index]),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () => _editFeedingTime(index),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => _deleteFeedingTime(index),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }



 Future<List<String>> _getFeedingTimes() async {
  User? currentUser = FirebaseAuth.instance.currentUser;
  String userUID = currentUser?.uid ?? "N/A";

  DataSnapshot dataSnapshot = (await _setTimeReference.child(userUID).once()).snapshot;

  Map<dynamic, dynamic>? setTimeData = dataSnapshot.value as Map<dynamic, dynamic>?;

  List<String> feedingTimes = [];

  if (setTimeData != null && setTimeData.isNotEmpty) {
    setTimeData.forEach((key, value) {
      feedingTimes.add(value['selectedTime']);
    });
  } else {
    // If no data is available, return a list with a placeholder text
    feedingTimes = ["No time has been selected"];
  }

  return feedingTimes;
}

  Future<void> _setFeedingTime() async {
  TimeOfDay? pickedTime = await showTimePicker(
    context: context,
    initialTime: _selectedTime,
  );

  if (pickedTime != null) {
    setState(() {
      _selectedTime = pickedTime;
      _isButtonDisabled = true;
    });

    // Get current user UID
    User? currentUser = FirebaseAuth.instance.currentUser;
    String userUID = currentUser?.uid ?? "N/A";

    // Format the selected time with leading zeros
    String formattedTime =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

    // Write selected time and user UID to Firebase Realtime Database (setTime node)
    _setTimeReference.child(userUID).push().set({
      'selectedTime': formattedTime,
      'userUID': userUID,
    });
  }
}

void _editFeedingTime(int index) async {
  User? currentUser = FirebaseAuth.instance.currentUser;
  String userUID = currentUser?.uid ?? "N/A";

  // Fetch the feeding times
  List<String> feedingTimes = await _getFeedingTimes();

  // Display a dialog to allow the user to edit the selected time
  TimeOfDay? editedTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay(
      hour: int.parse(feedingTimes[index].split(':')[0]),
      minute: int.parse(feedingTimes[index].split(':')[1]),
    ),
  );

  if (editedTime != null) {
    // Format the edited time with leading zeros
    String formattedEditedTime =
        '${editedTime.hour.toString().padLeft(2, '0')}:${editedTime.minute.toString().padLeft(2, '0')}';

    // Update the feeding time in the database
    _setTimeReference
        .child(userUID)
        .orderByChild('selectedTime')
        .equalTo(feedingTimes[index])
        .onValue
        .listen((event) {
      Map<dynamic, dynamic>? values = (event.snapshot.value as Map<dynamic, dynamic>?) ?? {};
      String key = values.keys.first ?? "";

      _setTimeReference.child(userUID).child(key).update({
        'selectedTime': formattedEditedTime,
      });
    });
  }
}


void _deleteFeedingTime(int index) async {
  User? currentUser = FirebaseAuth.instance.currentUser;
  String userUID = currentUser?.uid ?? "N/A";

  // Fetch the feeding times
  List<String> feedingTimes = await _getFeedingTimes();

  // Find the corresponding key in the database
  _setTimeReference
      .child(userUID)
      .orderByChild('selectedTime')
      .equalTo(feedingTimes[index])
      .onValue
      .listen((event) {
    Map<dynamic, dynamic>? values = (event.snapshot.value as Map<dynamic, dynamic>?) ?? {};
    String key = values.keys.first ?? "";

    // Delete the feeding time from the database
    _setTimeReference.child(userUID).child(key).remove();
  });
}


}