import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'API Integration App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _controller = TextEditingController();
  String _sentimentResult = '';
  String _topicResult = '';
  bool _isLoading = false;

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _performSentimentAnalysis() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var response = await http.post(
        Uri.parse(
            'https://us-central1-eloquent-clover-417510.cloudfunctions.net/predictsent'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'text': _controller.text,
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          _sentimentResult = data['Prediction'];
        });
      } else {
        _showErrorDialog('Failed to get sentiment analysis.');
      }
    } catch (e) {
      _showErrorDialog('Error occurred while trying to send data.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _performTopicModeling() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var response = await http.post(
        Uri.parse(
            'https://asia-south2-eloquent-clover-417510.cloudfunctions.net/Topic'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'review_text': _controller.text,
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          _topicResult = data['topic'];
        });
      } else {
        _showErrorDialog('Failed to get topic analysis.');
      }
    } catch (e) {
      _showErrorDialog('Error occurred while trying to send data.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Text Analysis App'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter text here',
                ),
                minLines: 1,
                maxLines: 5,
              ),
              SizedBox(height: 20),
              if (_isLoading)
                CircularProgressIndicator()
              else ...[
                ElevatedButton(
                  onPressed: _performSentimentAnalysis,
                  child: Text('Analyze Sentiment'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _performTopicModeling,
                  child: Text('Analyze Topic'),
                ),
              ],
              SizedBox(height: 20),
              Text('Sentiment Result: $_sentimentResult'),
              SizedBox(height: 10),
              Text('Topic Result: $_topicResult'),
            ],
          ),
        ),
      ),
    );
  }
}
