import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OrderUpdats extends StatefulWidget {
  const OrderUpdats({Key? key, required this.orderId}) : super(key: key);
  final String orderId;
  @override
  _OrderUpdatsState createState() => _OrderUpdatsState();
}

class _OrderUpdatsState extends State<OrderUpdats> {
  bool _isLoading = false;
  String error = '';
  List<dynamic> _orderUpdates = [];
  @override
  void initState() {
    super.initState();
    fetchUpdates();
  }

  //fetchupdates
  fetchUpdates() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse(
          'http://localhost:8000/order_updates_${widget.orderId}.json?time=${DateTime.now()}'));
      if (response.statusCode == 200) {
        setState(() {
          _isLoading = false;
          _orderUpdates = json.decode(response.body).reversed.toList();
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        error = e.toString();
      });
    }
  }

  Widget buildContents() {
    if (_isLoading)
      return const Center(
        child: CircularProgressIndicator(),
      );
    else if (error.isNotEmpty)
      return Center(
        child: Text(error),
      );
    else if (_orderUpdates.isEmpty) {
      return Center(
        child: Text('No updates yet'),
      );
    } else {
      return ListView.builder(
        itemCount: _orderUpdates.length,
        itemBuilder: (context, index) {
          final item = _orderUpdates[index];
          Color color = item['type'] == 'B' ? Colors.green : Colors.red;
          var orderType = item['type'] == 'B' ? "Buy" : "Sell";
          return ListTile(
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${item["type"]}',
                  style: TextStyle(color: color, fontSize: 16),
                ),
              ],
            ),
            title: Text('$orderType @ ${item["price"]}'),
            subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text('${item["time"]}'), Text('${item["status"]}')]),
            trailing: Text(
              '${item["note"]}',
              // style: TextStyle(color: color),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trail of ${widget.orderId}'),
        actions: [
          ElevatedButton.icon(
              onPressed: () => fetchUpdates(),
              icon: Icon(Icons.refresh),
              label: Text("Refresh"))
        ],
      ),
      body: Container(
        child: buildContents(),
      ),
    );
  }
}
