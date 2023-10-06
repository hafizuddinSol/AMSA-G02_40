import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminViewUserProfile extends StatefulWidget {
  @override
  _AdminViewUserProfileState createState() => _AdminViewUserProfileState();
}

class _AdminViewUserProfileState extends State<AdminViewUserProfile> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showProfilePicture(String? profilePicURL) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Profile Picture'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                profilePicURL != null
                    ? Image.network(profilePicURL)
                    : Text('User has not uploaded a profile picture'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profiles'),
      ),
      body: Center(
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('users')
              .where('roles', isEqualTo: 'user')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No user profiles available.'));
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: <DataColumn>[
                  DataColumn(
                    label: Text(' '),
                  ),
                  DataColumn(
                    label: Text('First Name'),
                  ),
                  DataColumn(
                    label: Text('Last Name'),
                  ),
                  DataColumn(
                    label: Text('Email'),
                  ),
                  DataColumn(
                    label: Text('Profile Picture'),
                  ),
                ],
                rows: snapshot.data!.docs.asMap().entries.map((entry) {
                  final int userCount = entry.key + 1;
                  final QueryDocumentSnapshot document = entry.value;
                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;

                  return DataRow(
                    cells: <DataCell>[
                      DataCell(Text(userCount.toString())),
                      DataCell(Text(data['firstName'] ?? '')),
                      DataCell(Text(data['lastName'] ?? '')),
                      DataCell(Text(data['email'] ?? '')),
                      DataCell(
                        ElevatedButton(
                          onPressed: () {
                            _showProfilePicture(data['profilePicURL']);
                          },
                          child: Text('View'),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}
