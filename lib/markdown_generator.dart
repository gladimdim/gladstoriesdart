class MarkdownDocument {
  String _document = '';

  MarkdownDocument([document]) {
    if (document != null) {
      _document = document;
    }
  }

  @override
  String toString() {
    return _document;
  }

  MarkdownDocument h1(String value) {
    _document = _document + '# ${value}\n';
    return this;
  }

  MarkdownDocument h2(String value) {
    _document = _document + '## ${value}\n';
    return this;
  }

  MarkdownDocument h3(String value) {
    _document = _document + '### ${value}\n';
    return this;
  }

  MarkdownDocument image(String imagePath,
      [String imageText, bool showText = false]) {
    imageText = imageText ?? '';
    _document = _document +
        '![${imageText}](https://locadeserta.com/game/assets/${imagePath})';
    if (showText) {
      _document = _document + ' ${imageText}';
    }
    _document = _document + '\n';

    return this;
  }

  MarkdownDocument point(String value) {
    _document = _document + '- ${value}\n';
    return this;
  }

  MarkdownDocument text(String value) {
    _document = _document + '${value}\n';
    return this;
  }

  MarkdownDocument separator() {
    _document = _document + '\n';
    _document = _document + '---\n';
    _document = _document + '\n';
    return this;
  }
}
