
import 'package:flutter/material.dart';

import '../default_tags/basic_tags.dart';
import '../default_tags/list_tag.dart';
import '../default_tags/abstract_tags.dart';

/// A [BBStylesheet] contains all style related information required to render a text that contains BBCode including the parsers for tags.
class BBStylesheet {

  final Map<String, AbstractTag> _tags = {};
  Map<String, AbstractTag> get tags => _tags;

  late final TextStyle defaultTextStyle;

  /// Constructor for a [BBStylesheet]. Requires at least a list
  /// of tags to be supplied.
  BBStylesheet({
    required Iterable<AbstractTag> tags,
    TextStyle? defaultText
  }) {
    defaultTextStyle = defaultText ?? const TextStyle(color: Colors.black, fontSize: 14);

    for (var parser in tags) {
      _tags[parser.tag] = parser;
    }
  }

  /// Add a tag to this style.
  /// Ensures no tag is replaced.
  BBStylesheet addTag(AbstractTag tag) {
    if (_tags.containsKey(tag.tag)) {
      throw Exception("Cannot add a tag that has already been added. Consider using 'replaceOrAddTag' instead.");
    }

    _tags[tag.tag] = tag;
    return this;
  }

  /// Replace or add a tag from this style.
  BBStylesheet addOrReplaceTag(AbstractTag tag) {
    _tags[tag.tag] = tag;
    return this;
  }

  AbstractTag? getTag(String tag) {
    return _tags[tag];
  }

  /// Gets a list of all currently available tags.
  Set<String> get validTags => { ...tags.keys };
}


/// Returns the default BBCode style.
BBStylesheet defaultBBStyle({
  TextStyle? textStyle
}) =>
    BBStylesheet(
        defaultText: textStyle,
        tags: [
      BoldTag(),
      ItalicTag(),
      UnderlineTag(),
      StrikeThroughTag(),
      ColorTag(),
      HeaderTag(1, 28),
      HeaderTag(2, 26),
      HeaderTag(2, 24),
      HeaderTag(3, 22),
      HeaderTag(4, 20),
      HeaderTag(5, 18),
      HeaderTag(6, 16),
      UrlTag(),
      ImgTag(),
      QuoteTag(),
      SpoilerTag(),
      ListTag(
          ListItemStyle("%index%. ",
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ListItemStyle(
              "● ",
              const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.blueAccent))),
      ListItem()
    ]);