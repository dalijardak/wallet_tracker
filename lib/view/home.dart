import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart'; // Package used to update Home Screen Widget
import 'package:pull_to_refresh/pull_to_refresh.dart'; // Pull to refresh data
import 'package:wallet_tracket/sizeConfig.dart';
import 'package:wallet_tracket/service/config.dart';
import 'package:wallet_tracket/service/fetchData.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  ///******************************  Declaring Variables ******************************///

  // Hash
  String _hash;

  // Currency
  String _currency;

  // Timer to update Data
  Timer updateData;

  // Timer for last update
  Timer updateTimer;

  DateTime lastUpdated = DateTime.now();

  DateTime now;

  // Store text data while typing it in TextFormField
  TextEditingController _hashController = new TextEditingController();

  // Future
  Future<dynamic> fetchData;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  ///******************************  Declaring Widgets ******************************///

  // Transaction card view
  Widget transaction({String time, String amount, String currency}) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(int.parse(time) * 1000);

    String formattedDate = DateFormat('dd-MM-yyyy – kk:mm').format(date);
    return Card(
      child: ListTile(
        title: Text(formattedDate),
        trailing: Text("$amount $currency"),
      ),
    );
  }

  // Settings Menu
  showSettingsMenu(BuildContext context) {
    // Create button
    Widget saveButton = TextButton(
      child: Text("Save"),
      onPressed: () {
        // Save data into SharedPreferences
        saveConfig(hash: _hashController.text, currency: _currency);

        // Reload Data
        setState(() {
          fetchData = getData();
        });

        // Update Home Screen Widget
        HomeWidget.updateWidget(
          name: 'ExampleAppWidgetProvider',
          androidName: 'ExampleAppWidgetProvider',
        );

        // Dissmiss the Pop up dialog (Settings menu)
        Navigator.of(context).pop();
      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Settings"),
      content: Container(
        height: getY(context) * 0.3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hash :"),

            // Data input
            TextFormField(
              controller: _hashController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: _hash,
                filled: true,
                fillColor: Colors.grey,
                contentPadding:
                    const EdgeInsets.only(left: 14.0, bottom: 6.0, top: 8.0),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            Text("Currency :"),
            DropdownButtonFormField(
              value: _currency,
              onChanged: (String newValue) {
                setState(() {
                  _currency = newValue;
                });
              },
              // Items to display (EUR and USD)
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
                contentPadding:
                    const EdgeInsets.only(left: 14.0, bottom: 6.0, top: 8.0),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        // Save Button
        saveButton,
      ],
    );

    // show the dialog (Settings Menu)
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  ///******************************  Initiating Variables ******************************///

  @override
  void initState() {
    super.initState();

    now = DateTime.now();

    loadHash().then((value) {
      setState(() {
        _hashController.text = value;
      });
    });

    loadCurrency().then((value) {
      setState(() {
        _currency = value;
      });
    });

    // Fetching data from server
    fetchData = getData();

    // Update current time every 1 minute
    updateTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      setState(() {
        now = DateTime.now();
      });
    });

    // Update Data and Home Screen Widget every 15 minutes
    updateData = Timer.periodic(Duration(minutes: 15), (Timer t) {
      // Update home Screen Widget
      HomeWidget.updateWidget(
        name: 'ExampleAppWidgetProvider',
        androidName: 'ExampleAppWidgetProvider',
      );

      // Update data and current Time
      setState(() {
        now = DateTime.now();
        fetchData = getData();
      });
    });
  }

  ///******************************  Dispose Variables ******************************///
  @override
  void dispose() {
    _refreshController.dispose();
    updateData?.cancel();
    updateTimer?.cancel();
    super.dispose();
  }

  ///******************************  Declaring Functions ******************************///

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    HomeWidget.updateWidget(
      name: 'ExampleAppWidgetProvider',
      androidName: 'ExampleAppWidgetProvider',
    );
    setState(() {
      lastUpdated = DateTime.now();
      fetchData = getData();
    });
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()

    _refreshController.loadComplete();
  }

  ///******************************  Main Widget ******************************///

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet Tracket'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => showSettingsMenu(context),
          )
        ],
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        physics: AlwaysScrollableScrollPhysics(),
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: FutureBuilder(
          future: fetchData,
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(
                child: Text("Loding ..."),
              );

            var balance = snapshot.data["balance"];
            var balance_24h = snapshot.data["balance_24h"];
            var coins = snapshot.data["coins"];
            var currency = snapshot.data["currency"];
            var transactions = snapshot.data["transactions"];

            //Calculating the profit :
            int v1 = int.parse(balance);
            int v2 = int.parse(balance_24h);
            var profit = ((v1 - v2) / v1.abs()) * 100;

            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image:
                      AssetImage("assets/background.png"), // Background Image
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "$coins  coins",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "$balance $currency",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 36.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                              height: 50,
                              child: Text(
                                profit > 0
                                    ? "+ ${profit.toInt()}%"
                                    : "- ${profit.toInt()}%",
                                style: TextStyle(
                                  color: profit > 0 ? Colors.green : Colors.red,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: EdgeInsets.only(right: 20),
                            child: Text(
                              "Last updated ${now.difference(lastUpdated).inMinutes} mins ago",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Transactions",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) => transaction(
                        time: transactions[index]["time"],
                        amount: transactions[index]["amount"],
                        currency: currency,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
