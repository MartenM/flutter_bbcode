[![PubDev](https://img.shields.io/pub/v/flutter_bbcode?logo=flutter&logoColor=%235dc8f8&style=flat-square)](https://pub.dev/packages/flutter_bbcode)

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

### Creating your own tags
You can create your own tags by either extending the `StyleTag` class or `AdvancedTag` class. The last one takes care of all BBCode it self. This can be useful in certain situations, but the `StyleTag` should be sufficient for most style changes.

### Contribute to the project
Feel free to create issues and pull-requests on Github. I will take a look at them as soon as possible.
