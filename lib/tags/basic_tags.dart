import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_renderer.dart';
import 'package:flutter_bbcode/tags/tag_parser.dart';
import 'package:flutter_bbcode/src/color_util.dart';
import 'package:bbob_dart/bbob_dart.dart' as bbob;

/// This file holds all basic tags that come with the project.
/// These range from the bold, italic, underline to img tags.
/// Feel free to add any tags you feel like the project is currently missing.

/// Basic implementation for [b] using the [StyleTag].
/// Defaults ot [FontWeight.bold].
class BoldTag extends StyleTag {
  final FontWeight weight;
  BoldTag({this.weight = FontWeight.bold}) : super('b');

  @override
  TextStyle transformStyle(
      TextStyle oldStyle, Map<String, String>? attributes) {
    return oldStyle.copyWith(fontWeight: weight);
  }
}

class ItalicTag extends StyleTag {
  ItalicTag() : super('i');

  @override
  TextStyle transformStyle(
      TextStyle oldStyle, Map<String, String>? attributes) {
    return oldStyle.copyWith(fontStyle: FontStyle.italic);
  }
}

class UnderlineTag extends StyleTag {
  UnderlineTag() : super('u');

  @override
  TextStyle transformStyle(
      TextStyle oldStyle, Map<String, String>? attributes) {
    return oldStyle.copyWith(decoration: TextDecoration.underline);
  }
}

class StrikeThroughTag extends StyleTag {
  StrikeThroughTag() : super('s');

  @override
  TextStyle transformStyle(
      TextStyle oldStyle, Map<String, String>? attributes) {
    return oldStyle.copyWith(decoration: TextDecoration.underline);
  }
}

/// Implements the [color] tag using the [StyleTag].
/// Only supports HEX colours.
class ColorTag extends StyleTag {
  ColorTag() : super('color');

  @override
  TextStyle transformStyle(
      TextStyle oldStyle, Map<String, String>? attributes) {
    String? hexColor = attributes?.entries.first.key;
    if (hexColor == null) return oldStyle;
    return oldStyle.copyWith(color: HexColor.fromHex(hexColor));
  }
}

/// Basic implementation of the [h<number>] tag.
/// [_textSize] is used to define the new textSize.
class HeaderTag extends StyleTag {
  final double _textSize;

  HeaderTag(int headerIndex, this._textSize) : super("h$headerIndex");

  @override
  TextStyle transformStyle(
      TextStyle oldStyle, Map<String, String>? attributes) {
    return oldStyle.copyWith(fontSize: _textSize);
  }
}

/// Default implementation of the [URL] tag.
/// Defaults to a log function when clicked.
class UrlTag extends StyleTag {
  final Function(String)? onTap;

  UrlTag({this.onTap}) : super("url");

  @override
  void onTagStart(FlutterRenderer renderer) {
    late String url;
    if (renderer.currentTag?.attributes.isNotEmpty ?? false) {
      url = renderer.currentTag!.attributes.keys.first;
    } else if(renderer.currentTag?.children.isNotEmpty ?? false) {
      url = renderer.currentTag!.children.first.textContent;
    } else {
      url = "URL is missing!";
    }

    renderer.pushTapAction(() {
      if (onTap == null) {
        log("URL $url has been pressed!");
        return;
      }
      onTap!(url);
    });
    super.onTagStart(renderer);
  }

  @override
  void onTagEnd(FlutterRenderer renderer) {
    renderer.popTapAction();
    super.onTagEnd(renderer);
  }

  @override
  TextStyle transformStyle(
      TextStyle oldStyle, Map<String, String>? attributes) {
    return oldStyle.copyWith(
        decoration: TextDecoration.underline, color: Colors.blue);
  }
}

/// Default [img] tag.
/// Extends AdvancedTag because it's children should not be displayed.
/// Instead we use those to create the image widget.
class ImgTag extends AdvancedTag {
  ImgTag() : super("img");

  @override
  List<InlineSpan> parse(FlutterRenderer renderer, bbob.Element element) {
    if (element.children.isEmpty) {
      return [TextSpan(text: "[$tag]")];
    }

    // Image URL is the first child / node. If not, that's an issue for the person writing
    // the BBCode.
    String imageUrl = element.children.first.textContent;

    final image = Image.network(imageUrl,
        errorBuilder: (context, error, stack) => Text("[$tag]"));

    if (renderer.peekTapAction() != null) {
      return [
        WidgetSpan(
            child: GestureDetector(
          onTap: renderer.peekTapAction(),
          child: image,
        ))
      ];
    }

    return [
      WidgetSpan(
        child: image,
      )
    ];
  }
}

class QuoteTag extends WrappedStyleTag {
  final TextStyle headerStyleText;

  QuoteTag({
    this.headerStyleText = const TextStyle(),
  }) : super("quote");

  @override
  List<InlineSpan> wrap(bbob.Element element, List<InlineSpan> spans) {
    String? author = element.attributes.isNotEmpty ? element.attributes.values.first : null;

    return [
      WidgetSpan(child:
        Container(
          decoration: const BoxDecoration(
            border: Border(left: BorderSide(color: Colors.grey, width: 2))
          ),
          child: Column(
            children: [
              if(author != null) Container(
                padding: const EdgeInsets.all(5),
                width: double.infinity,
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey, width: 1))
                ),
                child: Text("$author said:", style: headerStyleText),
              ),
              Container(
                  color: const Color.fromARGB(255, 235, 235, 235),
                  padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                  child: RichText(text: TextSpan(children: spans)))
            ],
          ),
        )
      ),
    ];
  }
}
