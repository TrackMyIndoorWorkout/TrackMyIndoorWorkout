import 'package:flutter/material.dart';

class ActivitiesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.list_alt,
              size: 200.0,
              color: Colors.white54,
            ),
            Text(
              'Activities will come here',
            ),
          ],
        ),
      ),
    );
  }
}
