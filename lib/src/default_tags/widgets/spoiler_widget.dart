import 'package:flutter/material.dart';

class SpoilerDisplay extends StatefulWidget {
  final String spoilerText;
  final List<InlineSpan> content;

  const SpoilerDisplay(
      {Key? key, required this.spoilerText, required this.content})
      : super(key: key);

  @override
  State<SpoilerDisplay> createState() => _SpoilerDisplayState();
}

class _SpoilerDisplayState extends State<SpoilerDisplay> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_button(), if (expanded) _content()],
      ),
    );
  }

  Widget _button() {
    return ElevatedButton(
      onPressed: () => setState(() {
        expanded = !expanded;
      }),
      child: Text(widget.spoilerText),
    );
  }

  Widget _content() {
    return Container(
      padding: const EdgeInsets.all(5),
      width: double.infinity,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1),
          color: const Color.fromARGB(255, 245, 245, 245)),
      child: RichText(text: TextSpan(children: widget.content)),
    );
  }
}
