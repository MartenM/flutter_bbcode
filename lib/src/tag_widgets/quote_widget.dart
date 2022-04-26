import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class QuoteDisplay extends StatelessWidget {

  final String? author;
  final TextStyle headerTextStyle;
  final List<InlineSpan> content;

  const QuoteDisplay({
    Key? key,
    required this.content,
    this.author,
    this.headerTextStyle = const TextStyle()
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: Colors.grey, width: 2))),
      child: Column(
        children: [
          if (author != null)
            Container(
              padding: const EdgeInsets.all(5),
              width: double.infinity,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                      bottom: BorderSide(color: Colors.grey, width: 1))),
              child: Text("$author said:", style: headerTextStyle),
            ),
          Container(
              width: double.infinity,
              color: const Color.fromARGB(255, 235, 235, 235),
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              child: RichText(text: TextSpan(children: content)))
        ],
      ),
    );
  }
}
