import 'package:flutter/material.dart';
import 'package:bbob_dart/bbob_dart.dart' as bbob;

import '../parser/flutter_renderer.dart';
import 'abstract_tags.dart';

/// The style of the list. This is used by the list items to generate the correct style
enum ListType { ordered, unordered }

/// Used to style the prefix of a list item.
class ListItemStyle {
  String prefix;
  TextStyle? prefixStyle;

  ListItemStyle(this.prefix, this.prefixStyle);
}

/// Data used to render the list properly.
/// It contains both the style for the list and other relevant information used to make the list.
class ListRenderData extends RenderData {
  ListType listType;
  int index = 0;

  ListItemStyle orderedListStyle;
  ListItemStyle unorderedListStyle;

  ListRenderData(
      {required this.listType,
      required this.orderedListStyle,
      required this.unorderedListStyle});
}

/// Represents the [*] tag used in list to define an item.
class ListItem extends AbstractTag {
  ListItem() : super(tag: "*");

  @override
  void onTagStart(FlutterRenderer renderer) {
    ListRenderData data = renderer.getRenderData() as ListRenderData;

    var style = data.listType == ListType.ordered
        ? data.orderedListStyle
        : data.unorderedListStyle;

    // Increment before rendering, since non-programmers won't really get lists
    // that start with 0.
    data.index++;

    // Append the prefix
    renderer.appendTextSpan(TextSpan(
        text: style.prefix.replaceAll("%index%", data.index.toString()),
        style: style.prefixStyle));
  }
}

/// Represents BBCode list.
/// Requires both styles for ordered and unordered lists.
class ListTag extends WrappedStyleTag {
  ListItemStyle orderedStyle;
  ListItemStyle unorderedStyle;

  ListTag(this.orderedStyle, this.unorderedStyle) : super("list");

  @override
  void onTagStart(FlutterRenderer renderer) {
    super.onTagStart(renderer);

    // Get the type. [list=1]
    var type = ListType.unordered;
    if (renderer.currentTag!.attributes.isNotEmpty) {
      if (renderer.currentTag?.attributes.values.first == "1") {
        type = ListType.ordered;
      }
    }

    // Insert render data to be used by child nodes.
    renderer.startRenderData(ListRenderData(
      listType: type,
      orderedListStyle: orderedStyle,
      unorderedListStyle: unorderedStyle,
    ));
  }

  @override
  void onTagEnd(FlutterRenderer renderer) {
    super.onTagEnd(renderer);
    renderer.endRenderData();
  }

  @override
  List<InlineSpan> wrap(bbob.Element element, List<InlineSpan> spans) {
    // Remove accidental \n at the start and end.
    if (spans.first.toPlainText() == "\n") spans.removeAt(0);
    if (spans.last.toPlainText() == "\n") spans.removeLast();

    return [
      WidgetSpan(
          child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
              child: RichText(text: TextSpan(children: spans))))
    ];
  }
}
