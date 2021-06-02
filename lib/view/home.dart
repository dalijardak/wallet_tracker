import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
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

  // Transaction card
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

  // Functions loaded on  widget
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

    fetchData = getData();

    updateTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      setState(() {
        now = DateTime.now();
      });
    });
    updateData = Timer.periodic(Duration(minutes: 15), (Timer t) {
      HomeWidget.updateWidget(
        name: 'ExampleAppWidgetProvider',
        androidName: 'ExampleAppWidgetProvider',
      );
      setState(() {
        now = DateTime.now();
        fetchData = getData();
      });
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();

    updateData?.cancel();
    updateTimer?.cancel();
    super.dispose();
  }

  showAlertDialog(BuildContext context) {
    // Create button
    Widget saveButton = TextButton(
      child: Text("Save"),
      onPressed: () {
        saveConfig(hash: _hashController.text, currency: _currency);
        setState(() {
          fetchData = getData();
        });
        HomeWidget.updateWidget(
          name: 'ExampleAppWidgetProvider',
          androidName: 'ExampleAppWidgetProvider',
        );

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
                hintText: 'Hash',
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
        saveButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

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
            onPressed: () => showAlertDialog(context),
          )
        ],
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        physics: AlwaysScrollableScrollPhysics(),
        //header: WaterDropHeader(),
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
                  image: AssetImage("assets/background.png"),
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
