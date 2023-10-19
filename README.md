[![PubDev](https://img.shields.io/pub/v/flutter_bbcode?logo=flutter&logoColor=%235dc8f8&style=flat-square)](https://pub.dev/packages/flutter_bbcode)
![Pub Popularity](https://img.shields.io/pub/popularity/flutter_bbcode?color=blue&label=Pub%20popularity&style=flat-square)
![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/MartenM/flutter_bbcode/flutter-test.yml?branch=main&style=flat-square)

A simple display for BBCode in Flutter. Supports custom tags and styles.

## Features

- Render BBCode into nicely readable text
- Support for different styles
- Support for custom tags

### Preview
![Preview 1](https://i.imgur.com/HfDDR1b.png)
![Preview 2](https://i.imgur.com/BHq9BQX.png)

## Getting started

1. Install the package using the instruction on the installation page.
2. That's all! You are ready to start displaying BBCode in Flutter.

## Usage

A fully working example can be found on Github.

After installing the package displaying BBCode is rather straighforward. When using this code note that you will be using the all default available BBCode parsers.
```dart
Widget parsedBBCode = BBCodeText(data: _yourString);
```

### Custom Stylesheet

An additional `BBStylesheet` can be provided using the `stylesheet` to overwrite the default style and tags used. Simply create an instance of `BBStylesheet` and add the tags you desire. It's also possible to get the default style and add, replace or remove certain tags.

```dart
var changedStyle = BBStyleSheet(tags: [
    BoldTag(),
    HeaderTag(1, 64)
]);

var extenedStyle = defaultBBStylesheet()
    .addTag(YourNewTag())
    .replaceTag(HeaderTag(1, 16));

Widget parsedBBCode = BBCodeText(data: _yourString, stylesheet: extendedStyle);
```

### Creating your own tags
You can create your own tags by extending the `AbstractTag`, `StyleTag`, `WrappedStyleTag` or `AdvancedTag` classes. The `StyleTag` should be sufficient for most style changes.
The `WrappedStyleTag` can be used to wrap a style around the tag. An example of a tag that implements this is the \[quote] tag.

## Additional information

### Currently support tags by default
* [B] - Bold text
* [I] - Italic text
* [U] - Underlined text
* [S] - Strikethrough text
* [COLOR=#HEX] - Coloured text based on HEX
* [H1] - Header text, supported up till [H6]
* [URL=https://google.com] - Supported with or without text. Can also be used to surround an URL to make it clickable. Default action is a log message. Example using `url_launcher` can be found in the example.
* [IMG=src] - Display an image from the internet.
* [QUOTE=Marten] - Used to wrap text in a quote block.
* [SPOILER=Name] - Used to create a clickable spoiler tag.
* [LIST] / [LIST=1] / [UL] / [OL] - Used to create (ordered) lists. Note that items need to be of the form [\*]item[/\*]
* [LEFT], [CENTER], [RIGHT] - Align the text


### Contribute to the project
Feel free to create issues and pull-requests on Github. I will take a look at them as soon as possible.

Leaving a star is also highly appreciated :)
