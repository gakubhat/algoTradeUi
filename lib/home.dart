import 'dart:convert';
import 'package:algo_trade_ui/alerts.dart';
import 'package:algo_trade_ui/order-book.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text('Trading Bot for $today'),
        ),
        body: Row(
          children: [
            Container(
              width: 400,
              child: AlertsBook(
                date: today,
              ),
            ),
            Container(
              width: 1,
              color: Colors.black.withAlpha(50),
            ),
            Expanded(
                child: OrderBook(
              date: today,
            )),
          ],
        ));
  }
}
