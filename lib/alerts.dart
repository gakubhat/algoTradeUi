import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AlertsBook extends StatefulWidget {
  const AlertsBook({Key? key, required this.date}) : super(key: key);
  final String date;
  @override
  _AlertsBookState createState() => _AlertsBookState();
}

class _AlertsBookState extends State<AlertsBook> {
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
          'http://localhost:8000/alerts_${widget.date}.json?time=${DateTime.now()}'));
      if (response.statusCode == 200) {
        setState(() {
          _isLoading = false;
          _orderUpdates = json.decode(response.body);
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
          Color color =
              item['type'] == 'Crossed above' ? Colors.green : Colors.red;
          if (item['type'] == 'In Range') {
            color = Colors.orange;
          }
          return ListTile(
            title: Text('${item["type"]}'),
            subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text('${item["action"]}')]),
            trailing: Text(
              item['type'] == 'In Range'
                  ? '${item["lowerLimit"]} - ${item["upperLimit"]}'
                  : '${item["price"]}',
              style: TextStyle(color: color),
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
        title: Text('Price Alerts'),
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
