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