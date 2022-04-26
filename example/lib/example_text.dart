const String flutterPackages = '''
[h1]Using packages[/h1]

[b][color=#33b9f6]Flutter[/color][/b] supports using shared packages contributed by other developers to the [b][color=#33b9f6]Flutter[/color][/b] and Dart ecosystems. This allows quickly building an app without having to develop everything from scratch.
[quote=using-packages.md]
[b]What is the difference between a package and a plugin?[/b]
A plugin is a [i]type[/i] of package—the full designation is [i]plugin package[/i], which is generally shortened to [i]plugin[/i].

[b]Packages[/b]
At a minimum, a Dart package is a directory containing a pubspec file. Additionally, a package can contain dependencies (listed in the pubspec), Dart libraries, apps, resources, tests, images, and examples. The [url]pub.dev[/url] site lists many packages—developed by Google engineers and generous members of the Flutter and Dart community— that you can use in your app.

[b]Plugins[/b]
A plugin package is a special kind of package that makes platform functionality available to the app. Plugin packages can be written for Android (using Kotlin or Java), iOS (using Swift or Objective-C), web, macOS, Windows, Linux, or any combination thereof. For example, a plugin might provide Flutter apps with the ability to use a device’s camera.
[/quote]
''';

const String flutterLogo = '''
[h2]Flutter[/h2]
[url=https://flutter.dev/][img]https://i.imgur.com/fvPRAWW.png[/img][/url]

[i]The text is actually a link![/i] Isn't that amazing! Who would have thought you could actually do such things in [color=#00b7ff][b]Flutter[/b][/color].
''';

const String flutterText = '''
[img]https://i.imgur.com/fvPRAWW.png[/img]

[h1]Learn [b][color=#32b9f6]Flutter[/color][/b] any way you want[/h1]

[i]With codelabs, YouTube videos, detailed docs, and more, find everything you need to get started with [b][color=#32b9f6]Flutter[/color][/b] or continue your learning journey.[/i]

[h3]Become a [b][color=#32b9f6]Flutter[/color][/b] developer[/h3]
Whether this is your first time programming, or you're coming from another language, we'll get you started on the right path.

[h3]Take your skills to the next level[/h3]
Take your skills to the next level with the format that works best for you – check out videos, high-quality documentation, codelabs, and more.

[h3]Expand your Flutter knowledge[/h3]
Learn new things about [b][color=#32b9f6]Flutter[/color][/b], continue to expand your skills, and stay up to date on the latest announcements and breaking changes.

[url=https://flutter.dev]Click here to learn more[/url]
''';

const String flutterDevtools = '''
[h1]DevTools[/h1]
[h4]For debugging and profiling apps, DevTools might be the first tool you reach for. DevTools runs in a browser and supports a variety of features:[/h4]
[spoiler=Logging]Another useful debugging tool is logging. You set logging up programmatically then view the output in the DevTools logging view, or in the console.[/spoiler]
[spoiler="The Dart analyzer"]If you’re using a Flutter enabled IDE/editor, the Dart analyzer is already checking your code and looking for possible mistakes.

If you run from the command line, test your code with flutter analyze.

The Dart analyzer makes heavy use of type annotations that you put in your code to help track problems down. You are encouraged to use them everywhere (avoiding var, untyped arguments, untyped list literals, and so on) as this is the quickest and least painful way of tracking down problems.

For more information, see Using the Dart analyzer.[/spoiler]
[spoiler=Measuring app startup time]To gather detailed information about the time it takes for your Flutter app to start, you can run the flutter run command with the trace-startup and profile options.
[quote]flutter run --trace-startup --profile[/quote][/spoiler]
''';
