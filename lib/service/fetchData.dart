import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<dynamic> getData({String hash, String currency}) async {
  String path = "http://162.55.32.207/$hash/$currency/full.json";

  // Initiating SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Loading Offline Data
  var offlineData = jsonDecode(prefs.getString("data"));

  // Initiating Connectivity
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile) {
    // I am connected to a mobile network, make sure there is actually a net connection.
    if (await DataConnectionChecker().hasConnection) {
      // Mobile data detected & internet connection confirmed.
      var url = Uri.parse(path);

      var response = await http.get(url);
      var data = jsonDecode(utf8.decode(response.bodyBytes));
      await prefs.setString("data", jsonEncode(data));
      return data;
    } else {
      // Mobile data detected but no internet connection found.
      return offlineData;
    }
  } else if (connectivityResult == ConnectivityResult.wifi) {
    // I am connected to a WIFI network, make sure there is actually a net connection.
    if (await DataConnectionChecker().hasConnection) {
      // Wifi detected & internet connection confirmed.
      var url = Uri.parse(path);

      var response = await http.get(url);

      var data = jsonDecode(utf8.decode(response.bodyBytes));
      await prefs.setString("data", jsonEncode(data));
      return data;
    } else {
      // Wifi detected but no internet connection found.
      return offlineData;
    }
  } else {
    // Neither mobile data or WIFI detected, not internet connection found.
    return offlineData;
  }
}

Future<dynamic> getDataOffline() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  return prefs.get("data");
}

Future<bool> isInternet() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile) {
    // I am connected to a mobile network, make sure there is actually a net connection.
    if (await DataConnectionChecker().hasConnection) {
      // Mobile data detected & internet connection confirmed.
      return true;
    } else {
      // Mobile data detected but no internet connection found.
      return false;
    }
  } else if (connectivityResult == ConnectivityResult.wifi) {
    // I am connected to a WIFI network, make sure there is actually a net connection.
    if (await DataConnectionChecker().hasConnection) {
      // Wifi detected & internet connection confirmed.
      return true;
    } else {
      // Wifi detected but no internet connection found.
      return false;
    }
  } else {
    // Neither mobile data or WIFI detected, not internet connection found.
    return false;
  }
}
