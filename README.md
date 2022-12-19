[![PubDev](https://img.shields.io/pub/v/flutter_bbcode?logo=flutter&logoColor=%235dc8f8&style=flat-square)](https://pub.dev/packages/flutter_bbcode)
![Pub Popularity](https://img.shields.io/pub/popularity/flutter_bbcode?color=blue&label=Pub%20popularity&style=flat-square)
![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/MartenM/flutter_bbcode/flutter-test.yml?branch=main&style=flat-square)

A simple display for BBCode in Flutter. Supports custom tags and styles.

## Features

- Render BBCode into human readable text.
- Support for custom tags

### Preview
![Preview 1](https://i.imgur.com/HfDDR1b.png)
![Preview 2](https://i.imgur.com/BHq9BQX.png)

## Getting started

1. Install the package using the instruction on the installation page.

## Usage

A fully working example can be found on Github.

After installing the package displaying BBCode is rather straighforward. When using this code note that you will be using ALL available BBCode parsers.
```dart
Widget parsedBBCode = BBCodeText(data: _yourString);
```

The default style currently used is `TextStyle(color: Colors.black, fontSize: 14)`. This can be overwritten using the `defaultStyle` parameter.

In order to make the package versatile as possible it's possible to define your own tags, or overwrite existing ones. To supply your own tag parsers use the optional `tagParsers` argument.

## Additional information

### Currently support tags by default
* [B] - Bold text
* [I] - Italic text
* [U] - Underlined text
* [S] - Strikethrough text
* [COLOR=#HEX] - Coloured text based on HEX
* [H1] - Header text, supported up till [H6]
* [URL=https://google.com] - Supported with or without text. Can also be used to surrouned an URL to make it clickable. Default action is a log message. Opening a webbrowser or any other actions need to be implemented by the developer.
* [IMG=src] - Display an image from the internet.
* [QUOTE=Marten] - Used to wrap text in a quote block.
* [SPOILER=Name] - Used to create a clickable spoiler tag.
* [LIST] / [LIST=1] - Used to create (ordered) lists. Note that items need to be of the form [*]item[/*]

### Creating your own tags
You can create your own tags by either extending the `StyleTag`, `WrappedStyleTag` or `AdvancedTag` classes. The last one takes care of all BBCode it self. This can be useful in certain situations, but the `StyleTag` should be sufficient for most style changes.
The `WrappedStyleTag` can be used to wrap a style around the tag. An example of a tag that implements this is the \[quote] tag.

### Contribute to the project
Feel free to create issues and pull-requests on Github. I will take a look at them as soon as possible.
