import 'package:example/example_text.dart' as example_texts;
import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';

void main() {
  runApp(const MyApp());
}

/// Wrapper class to wrap the style with an hint on what has been changed.
class HintedStyle {
  final BBStylesheet? style;
  final String hint;

  HintedStyle(this.style, this.hint);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const inputs = <String>[
    'This is a text without ANY bbcode',
    'This text features [b]bold[/b] text.',
    'This text [s]is epic[/s] combines features [u][b]bold underlined[/u][/b] text.',
    'This text features [url=https://mstruijk.nl]a link[/url].',
    example_texts.flutterPackages,
    example_texts.flutterLogo,
    example_texts.flutterText,
    example_texts.flutterDevtools,
    example_texts.badBBCode,
    example_texts.listBBCode,
  ];

  static final styles = <HintedStyle>[
    HintedStyle(null, "Default style"),
    HintedStyle(
        defaultBBStylesheet(
            textStyle: const TextStyle(color: Colors.blue, fontSize: 28)),
        "Default style with text style changed."
    ),
    HintedStyle(
        BBStylesheet(tags: []),
        "Empty style sheet"
    ),
    HintedStyle(
        defaultBBStylesheet()
            .replaceTag(HeaderTag(3, 6)),
        "Default style, replaced H3 tag (smaller)."
    ),
    HintedStyle(
        BBStylesheet(tags: [
          BoldTag(),
          ItalicTag(),
        ]),
        "Only Bold and Italic tags"
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter BBCode Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
        title: "Example BBCode outputs",
        examples: inputs,
        styles: styles,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title, required this.examples, required this.styles})
      : super(key: key);

  final String title;
  final List<String> examples;
  final List<HintedStyle?> styles;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentTextIndex = 0;
  int _currentStyleIndex = 0;

  String get _currentExampleText => widget.examples[_currentTextIndex];
  HintedStyle get _currentHintedStyle => widget.styles[_currentStyleIndex]!;

  void _selectNextExample() {
    setState(() {
      _currentTextIndex = (_currentTextIndex + 1) % widget.examples.length;
    });
  }

  void _selectNextStyle() {
    setState(() {
      _currentStyleIndex = (_currentStyleIndex + 1) % widget.styles.length;
    });

    var sm = ScaffoldMessenger.of(context);
    sm.clearSnackBars();
    sm.showSnackBar(SnackBar(
        content: Text(_currentHintedStyle.hint),
    ));
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
        stylesheet: _currentHintedStyle.style,
        data: _currentExampleText
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(child: parsedBBCode),
      ),
      floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton.small(
              onPressed: _selectNextExample,
              tooltip: 'Next example text',
              child: const Icon(Icons.navigate_next),
            ),
            FloatingActionButton.small(
              onPressed: _selectNextStyle,
              child: const Icon(Icons.draw),
              tooltip: 'Next BBStylesheet',
            )
          ]
      ),
    );
  }
}
