/// Redirect the user based on his registration
/// If he is registered, he's directed to Home.
/// If he is not, he's redirected to Welcome page.

import 'package:flutter/material.dart';
import 'package:wallet_tracket/service/fetchData.dart';
import 'package:wallet_tracket/view/home.dart';
import 'package:wallet_tracket/view/welcomePage.dart';

class Authentication extends StatelessWidget {
  const Authentication({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: isRegistered(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(
              child: CircularProgressIndicator(),
            );
          if (snapshot.data == true) return Home();
          return Welcome();
        },
      ),
    );
  }
}
