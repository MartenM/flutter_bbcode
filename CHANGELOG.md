## 1.5.1
* Updated dependencies to fix [#12](https://github.com/MartenM/flutter_bbcode/issues/12)

## 1.5.0
* 'Selectable' is now part of the Stylesheet.
* Fixed accessibility issues for future flutter releases.
* Fixed an accessibility issue for selectable text.
* Text in quotes can now be selected.
* Fixed a minor issue in the example texts
* Bumped flutter lints to 3.0.0

## 1.4.2
* Added \[UL] and \[OL] list tags. 

## 1.4.1
* Improved accessibility. Text now scales according the TextScaleFactor defined in the accessibility menu.
* Bumped bbob_dart to 2.0.1 (Non pre-release version)
* Updated linter to latest.
* Fixed double import statement.

## 1.4.0
* Added \[LEFT], \[CENTER] and \[RIGHT] tags.

## 1.3.0
> **Notice:** This is update a breaking update if you added new tags or changed the default text style.
> Please check the ReadMe on how to use the new BBStylesheet.

* Changed the layout of the source to be in line with the guidelines on https://dart.dev/guides/libraries/create-library-packages
* Added a BBStylesheet class that will hold all information related to style.

## 1.2.0
* Added support for \[LIST] tags.

## 1.1.3
* Fixed the strikethrough BBCode tag.

## 1.1.2
* Added the option for an ErrorBuilder when parsing fails. Defaults to showing the original text.
* Improved the color tag such that it should no longer throw any errors.
* Updated the readme.

## 1.1.1
* Included a \[spoiler] tag.

## 1.1.0
* Project now supports wrapped tags. This allows for creation of tags like \[quote].
* Implemented the \[quote] tag.

## 1.0.1
* Formatted project according to pub.dev guidelines.

## 1.0.0

* Initial release
