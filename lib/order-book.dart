import 'dart:convert';

import 'package:algo_trade_ui/order-updates.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderBook extends StatefulWidget {
  const OrderBook({Key? key, required this.date}) : super(key: key);
  final String date;
  @override
  _OrderBookState createState() => _OrderBookState();
}

class _OrderBookState extends State<OrderBook> {
  String selectedOrderId = '';
  bool loading = false;
  String error = '';
  List<dynamic> orderBook = [];
  var balance = 0;
  fetchTodaysOrders() async {
    setState(() {
      loading = true;
    });
    try {
      var response = await http.get(Uri.parse(
          "http://localhost:8000/allorders_${widget.date}.json?time=${DateTime.now()}"));
      var body = json.decode(response.body);
      setState(() {
        loading = false;
        balance = 0;
        orderBook = body['orderBook'];
        error = "";
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = e.toString();
        orderBook = [];
        balance = 0;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTodaysOrders();
  }

  Widget buildContents(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (error.isNotEmpty) {
      return Center(
        child: Text(error, style: TextStyle(color: Colors.red)),
      );
    } else if (orderBook.isEmpty) {
      return Center(
          child: Text(
        "No orders",
      ));
    } else {
      return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: orderBook.length,
                itemBuilder: (BuildContext context, int index) {
                  Color color = orderBook[index]["BuySell"] == 'B'
                      ? Colors.green
                      : Colors.red;
                  String orderType =
                      orderBook[index]["BuySell"] == 'B' ? "Buy" : "Sell";

                  String orderId = orderBook[index]["ExchOrderID"];
                  return ListTile(
                    onTap: () => {
                      setState(() {
                        selectedOrderId = orderId;
                      })
                    },
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${orderBook[index]["BuySell"]}',
                          style: TextStyle(color: color, fontSize: 16),
                        ),
                      ],
                    ),
                    title: Text('$orderType @ ${orderBook[index]["Rate"]}'),
                    subtitle: Text('${orderBook[index]["ExchOrderTime"]}'),
                    trailing: Text(
                      '${orderBook[index]["OrderStatus"]}',
                      style: TextStyle(
                          color: orderBook[index]["OrderStatus"] ==
                                  'Fully Executed'
                              ? Colors.lightGreen
                              : Colors.deepOrange),
                    ),
                  );
                },
              ),
            ),
            if (selectedOrderId.isNotEmpty)
              Container(
                child: OrderUpdats(
                  orderId: selectedOrderId,
                  key: Key(selectedOrderId),
                ),
                width: 400,
              )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Book'),
        actions: [
          Container(
            padding: EdgeInsets.all(4),
            child: Text("${balance != 0 ? "In Active Trade" : "Not Trading"}"),
          ),
          ElevatedButton.icon(
              onPressed: () => fetchTodaysOrders(),
              icon: Icon(Icons.refresh),
              label: Text("Refresh"))
        ],
      ),
      body: buildContents(context),
    );
  }
}
