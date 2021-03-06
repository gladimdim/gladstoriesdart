# 0.3.1

- Page() constructor requires nodes and next properties.
If you want to create an empty Page with empty nodes and next then use Page.empty() constructor.

Before:
```
var page = Page();
```

After:
```
var page = Page.empty();
```

- Added types for Stream historyChanges


# 0.3.0
Null safety enabled.
Story constructor expeects currentPage to be not null. You can use the same Page reference as for root property.

# 0.2.8

Updated rxdart to latest version 0.25.0

# 0.2.7
- Added default image resolver **BackgroundImage**. By default it resolves all images to "images/background/..." path.
- **toMarkdownString** method now expects you to provide a path to root folder were all your images are stored:
```
story.toMarkdownString("https://locadeserta.com/game/assets");
```

Images will be resolved if used standard BackgroundImage like this:
```
https://locadeserta.com/game/assets/images/background/landing/7.jpg
```
- Added **getNextNodeTexts** method that returns a list of available next options as texts.
- Added **goToNextPageByText** method that finds PageNext by input text and goes to it.


# 0.2.6
Black and white images are used for markdown export.

# 0.2.5
- Added new API methods.
- toJson method was refactored and now returns a Map<String, dynamic> instead of String.
- fromJson method was refactored and now expected Map<String, dynamic> instead of String.
- convertToMarkDown converts history of the Story into the Markdown document.
- toMarkdownString returns a Markdown string with images, meta data. Can be used for embedding into sites.

Engine no longer uses jsonEncode/jsonDecode when working with toJson/fromJson methods. It is up to users of the API to convert strings to/from JSON.

Example
Before:
```
Story.fromJson("SOME JSON STRING");
```
After:
```
Story.fromJson(jsonEncode("SOME JSON STRING"));
```

# 0.2.4
- Made imageResolver a required field in the constructor.

# 0.2.3
- Added DartDocs.
- Fixed various linter issues.
- No functional changes.

# 0.2.2

- Removed accidentally added file.

# 0.2.1

- Fixed issue when story could not be initialized without parameters.

# 0.2.0

- Added type annotations for several methods.
- Improved test coverage to 75%.
- Page.hasNext logic is moved to Page.hasNextNode.
- Page.hasNext now returns true/false depending on emptiness of next list.

# 0.1.3

- Added example.
- Formatted the dart files.

# 0.1.2

Fixed issues in Story constructor.

History list is initialized with an empty list.

_logCurrentPassageToHistory ignores imageResolver calls if it is null.

Page.fromMap returns empty Page is map is null or has no keys.

Added unit tests.

# 0.1.1

- Added ImageResolver as an argument for fromJson method

# 0.1.0

- Initial version