import 'package:flutter/material.dart';

void feedFish(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      Future.delayed(Duration(seconds: 5), () {
        Navigator.of(context).pop();
      });
      return AlertDialog(
        title: Text('Feeding Complete'),
        content: Text('You just fed your fish! Very Good!'),
      );
    },
  );
}

class FeedNowPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feed Now'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            feedFish(context);
          },
          child: Text('Feed Now'),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: FeedNowPage(),
  ));
}
