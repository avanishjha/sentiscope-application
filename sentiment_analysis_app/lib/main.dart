import 'package:flutter/material.dart';

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

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sentiment Analysis'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Enter text for analysis',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Trigger sentiment analysis
              },
              child: Text('Analyze Sentiment'),
            ),
          ],
        ),
      ),
    );
  }
}
