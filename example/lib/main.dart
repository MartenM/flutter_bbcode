import 'package:example/example_text.dart' as example_texts;
import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter BBCode Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: "Example BBCode outputs", examples: [
        'This is a text without ANY bbcode',
        'This text features [b]bold[/b] text.',
        'This text [s]is epic[/s] combines features [u][b]bold underlined[/u][/b] text.',
        'This text features [url=https://mstruijk.nl]a link[/url].',
        example_texts.flutterPackages,
        example_texts.flutterLogo,
        example_texts.flutterText,
        example_texts.flutterDevtools,
        example_texts.badBBCode,
      ]),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title, required this.examples})
      : super(key: key);

  final String title;
  final List<String> examples;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  void _selectNextExample() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.examples.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget parsedBBCode = BBCodeText(
        errorBuilder: (context, error, stack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Failed to parse BBCode correctly.",
                  style: TextStyle(color: Colors.red)),
              const Text(
                  "This usually means on of the tags is not properly handling unexpected input.\n"),
              Text(error.toString()),
            ],
          );
        },
        data: widget.examples[_currentIndex]);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(child: parsedBBCode),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _selectNextExample,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
