import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wallet_tracket/config.dart';
import 'package:wallet_tracket/service/config.dart';
import 'package:wallet_tracket/service/fetchData.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _hash = "123456";
  String _currency = "EUR";
  Timer timer;
  DateTime lastUpdated = DateTime.now();

  TextEditingController _hashController = new TextEditingController();

  Future<dynamic> fetchData;

  Widget transaction({String time, String amount, String currency}) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));

    String formattedDate = DateFormat('dd-MM-yyyy – kk:mm').format(date);
    return Card(
      child: ListTile(
        title: Text(formattedDate),
        trailing: Text("$amount $currency"),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadHash().then((value) => _hash = value);
    loadCurrency().then((value) => _currency = value);
    fetchData = getData(hash: _hash, currency: _currency);

    timer = Timer.periodic(Duration(minutes: 15), (Timer t) {
      print(t.tick);

      setState(() {
        lastUpdated = DateTime.now();
        fetchData = getData(hash: _hash, currency: _currency);
      });
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();

    timer?.cancel();
    super.dispose();
  }

  showAlertDialog(BuildContext context) {
    // Create button
    Widget saveButton = TextButton(
      child: Text("Save"),
      onPressed: () {
        saveConfig(hash: _hash, currency: _currency);
        setState(() {
          _hash = _hashController.text;
          fetchData = getData(hash: _hash, currency: _currency);
        });
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
    setState(() {
      fetchData = getData(hash: "123456", currency: "EUR");
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
        physics: BouncingScrollPhysics(),
        header: WaterDropHeader(),
        footer: ClassicFooter(
          loadStyle: LoadStyle.ShowWhenLoading,
          completeDuration: Duration(milliseconds: 500),
        ),
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
              padding: EdgeInsets.symmetric(horizontal: 20),
              height: getY(context),
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
                              "Last updated ${DateTime.now().difference(lastUpdated).inMinutes} mins ago",
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
