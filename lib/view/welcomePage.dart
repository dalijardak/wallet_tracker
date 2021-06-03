import 'package:flutter/material.dart';
import 'package:wallet_tracket/sizeConfig.dart';
import 'package:wallet_tracket/service/config.dart';
import 'package:wallet_tracket/view/home.dart';
import 'animations/slideAnimation.dart';

class Welcome extends StatefulWidget {
  Welcome({Key key}) : super(key: key);

  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  ///******************************  Declaring Variables ******************************///

  // Store text data while typing it in TextFormField
  TextEditingController _hashController = new TextEditingController();

  // Form Key
  final _formKey = GlobalKey<FormState>();

  // Currency
  String _currency = "EUR";

  ///******************************  Declaring Functions ******************************///

  void _validate() {
    if (_formKey.currentState.validate()) {
      saveConfig(hash: _hashController.text, currency: _currency).then(
        (value) => Navigator.pushReplacement(
          context,
          SlideRightRoute(
            page: Home(),
          ),
        ),
      );
    }
  }

  ///******************************  Main Widget ******************************///

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/logo.png",
                  height: getY(context) * 0.4,
                  width: getX(context) * 0.4,
                ),
                Text(
                  "Wallet Tracker",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  width: getX(context) * 0.7,
                  child: TextFormField(
                    controller: _hashController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Hash',
                      filled: true,
                      fillColor: Colors.grey,
                      contentPadding: const EdgeInsets.only(
                          left: 14.0, bottom: 6.0, top: 8.0),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    validator: (value) {
                      if (value.isEmpty) return "Please enter a valid HASH";
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  width: getX(context) * 0.7,
                  child: DropdownButtonFormField(
                    value: _currency,
                    hint: Text("Currency"),
                    onChanged: (String newValue) {
                      setState(() {
                        _currency = newValue;
                      });
                    },
                    items: <String>[
                      'EUR',
                      'USD',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      filled: true,
                      fillColor: Colors.grey,
                      contentPadding: const EdgeInsets.only(
                          left: 14.0, bottom: 6.0, top: 8.0),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    validator: (value) {
                      if (value.isEmpty) return "Please select a currency";
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  height: 70,
                ),
                ElevatedButton(onPressed: _validate, child: Text("Rgister")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
