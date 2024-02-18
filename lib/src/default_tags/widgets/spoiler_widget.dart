import 'package:flutter/material.dart';

class SpoilerDisplay extends StatelessWidget {
  final String spoilerText;
  final List<InlineSpan> content;
  final double elevation;
  final bool selectable;

  const SpoilerDisplay({Key? key, required this.spoilerText, required this.content, this.elevation = 2, this.selectable = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: elevation,
        child: ExpansionTile(
          title: Text(spoilerText),
          shape: const Border(),
          children: [
            Divider(height: 1),
            Padding(
                padding: EdgeInsets.all(10),
                child: selectable ? SelectableText.rich(TextSpan(children: content)) : RichText(text: TextSpan(children: content))
            )
          ],
        ),
      ),
    );
  }
}