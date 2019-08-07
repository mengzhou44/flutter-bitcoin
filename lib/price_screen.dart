import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'coin_data.dart';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'dart:convert';

class PriceScreen extends StatefulWidget {
  @override
  _PriceScreenState createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
  String selectedCurrency = 'USD';
  String result = '';

  CupertinoPicker iosPicker() {
    List<Text> list = [];
    for (String currency in currenciesList) {
      list.add(
        Text(currency),
      );
    }
    return CupertinoPicker(
        backgroundColor: Colors.lightBlue,
        itemExtent: 32,
        onSelectedItemChanged: (index) {
          this.setState(() {
            displayCurrencyBitCoinValue(currenciesList[index]);
          });
        },
        children: list);
  }

  DropdownButton androidDropdown() {
    List<DropdownMenuItem<String>> items = [];
    for (String currency in currenciesList) {
      items.add(DropdownMenuItem(value: currency, child: Text(currency)));
    }

    return DropdownButton<String>(
        items: items,
        value: selectedCurrency,
        onChanged: (value) {
          this.setState(() {
            displayCurrencyBitCoinValue(value);
          });
        });
  }

  void getBitCoinValueByUrl(currency, callback) async {
    try {
      String url =
          'https://apiv2.bitcoinaverage.com/indices/global/ticker/BTC' +
              currency;

      http.Response res = await http.get(url);

      if (res.statusCode == 200) {
        var json = jsonDecode(res.body);

        var last = json['last'].toStringAsFixed(2);

        callback(last);
      } else {
        return callback(null);
      }
    } catch (e) {
      print(e);
      callback(null);
    }
  }

  void displayCurrencyBitCoinValue(currency) {
    this.setState(() {
      result = "";
    });

    getBitCoinValueByUrl(currency, (data) {
      if (data != null) {
        this.setState(() {
          selectedCurrency = currency;
          result = "1 BTC = $data $currency";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🤑 Coin Ticker'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 0),
            child: Card(
              color: Colors.lightBlueAccent,
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 28.0),
                child: Text(
                  result,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Container(
              height: 150.0,
              alignment: Alignment.center,
              padding: EdgeInsets.only(bottom: 30.0),
              color: Colors.lightBlue,
              child: Platform.isIOS ? iosPicker() : androidDropdown())
        ],
      ),
    );
  }
}
