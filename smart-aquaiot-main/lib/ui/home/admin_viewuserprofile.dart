import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminViewUserProfile extends StatefulWidget {
  @override
  _AdminViewUserProfileState createState() => _AdminViewUserProfileState();
}

class _AdminViewUserProfileState extends State<AdminViewUserProfile> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profiles'),
      ),
      body: Center(
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('users').where('roles', isEqualTo: 'user').snapshots(),
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
                ],
                rows: snapshot.data!.docs.asMap().entries.map((entry) {
                  final int userCount = entry.key + 1; // Calculate user count
                  final QueryDocumentSnapshot document = entry.value;
                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;

                  return DataRow(
                    cells: <DataCell>[
                      DataCell(Text(userCount.toString())), 
                      DataCell(Text(data['firstName'] ?? '')),
                      DataCell(Text(data['lastName'] ?? '')),
                      DataCell(Text(data['email'] ?? '')),
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
