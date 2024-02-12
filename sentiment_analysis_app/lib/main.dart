import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(SentimentAnalysisApp());
}

class SentimentAnalysisApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sentiment Analysis',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  Future<Map<String, dynamic>> analyzeSentiment(String review) async {
    final String apiUrl =
        "https://asia-south1-final-year-sentiscope.cloudfunctions.net/sentiscope-1";
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"review": review}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load analysis');
    }
  }

  void _handleAnalysis() async {
    if (_controller.text.isEmpty) {
      _showDialog('Error', 'Please enter text for analysis.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final Map<String, dynamic> result =
          await analyzeSentiment(_controller.text);
      setState(() {
        _isLoading = false;
      });
      _showDialog(
          'Analysis Result',
          'Sentiment: ${result['sentiment']}\n'
              'Probabilities:\n'
              'Negative: ${result['probabilities']['Negative']}%\n'
              'Neutral: ${result['probabilities']['Neutral']}%\n'
              'Positive: ${result['probabilities']['Positive']}%');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showDialog('Error', 'Failed to analyze sentiment. Please try again.');
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sentiment Analysis'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Enter text for analysis',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _handleAnalysis,
                    child: Text('Analyze Sentiment'),
                  ),
          ],
        ),
      ),
    );
  }
}
