import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:rxdart/rxdart.dart';

enum ImageType { BOAT, STEPPE, FOREST, BULRUSH, RIVER, LANDING, CAMP, COSSACKS }

abstract class HistoryImage {
  String getImagePathColored();
  String getImagePath();
}

typedef ImageResolver = HistoryImage Function(ImageType type);

class Story {
  String title;
  String description;
  String authors;
  int year;
  Page root;
  List<HistoryItem> history;
  Page currentPage;
  ImageResolver imageResolver;

  BehaviorSubject _streamHistory = BehaviorSubject<List<HistoryItem>>();
  Stream historyChanges;

  Story(
      {this.title,
      this.description,
      this.authors,
      this.root,
      this.currentPage,
      this.history,
      this.year,
      this.imageResolver}) {
    if (this.currentPage == null) {
      currentPage = root;
    }
    if (this.history == null) {
      history = [];
    }
    historyChanges = _streamHistory.stream;
    if (history.isEmpty) {
      _logCurrentPassageToHistory();
    }
  }

  void reset() {
    history = [];
    currentPage = root;
    currentPage.currentIndex = 0;
    _logCurrentPassageToHistory();
  }

  _logCurrentPassageToHistory() {
    if (currentPage.nodes.isEmpty) {
      return;
    }
    if (currentPage.getCurrentNode().imageType != null) {
      List<String> imagePaths = [];
      if (imageResolver != null) {
        var backgroundImage =
            imageResolver(currentPage.getCurrentNode().imageType);
        imagePaths.add(backgroundImage.getImagePathColored());
        imagePaths.add(backgroundImage.getImagePath());
      }
      history.add(
        HistoryItem(
          text: currentPage.getCurrentText(),
          imagePath: imagePaths,
        ),
      );
    } else {
      history.add(
        HistoryItem(
          text: currentPage.getCurrentText(),
        ),
      );
    }

    _streamHistory.sink.add(history);
  }

  doContinue() {
    if (canContinue()) {
      currentPage.nextNode();
      _logCurrentPassageToHistory();
    } else {
      throw CannotContinue;
    }
  }

  goToNextPage(PageNext next) {
    history.add(
      HistoryItem(text: next.text),
    );
    currentPage = next.nextPage;
    currentPage.currentIndex = 0;
    _logCurrentPassageToHistory();
  }

  bool canContinue() {
    return currentPage.hasNext();
  }

  toJson() {
    return jsonEncode({
      "title": title,
      "description": description,
      "authors": authors,
      "root": root.toMap(),
      "year": year,
    });
  }

  toStateJson() {
    return jsonEncode({
      "title": title,
      "description": description,
      "authors": authors,
      "root": root.toMap(),
      "currentPage": currentPage.toStateMap(),
      "year": year,
      "history": history.map((historyItem) => historyItem.toMap()).toList(),
    });
  }

  static Story fromJson(String input, {ImageResolver imageResolver}) {
    Map map = jsonDecode(input);
    var rootMap = map["root"];
    var rootPage = Page.fromMap(rootMap);
    var currentPageMap = map["currentPage"];
    print(currentPageMap);
    var currentPage =
        currentPageMap == null ? null : Page.fromMap(map["currentPage"]);
    List historyList = map["history"];
    String authors = map["authors"];
    return Story(
      title: map["title"],
      description: map["description"],
      root: rootPage,
      authors: authors,
      year: map["year"],
      currentPage: currentPage,
      imageResolver: imageResolver,
      history: historyList == null
          ? []
          : historyList.map((item) => HistoryItem.fromMap(item)).toList(),
    );
  }

  static generate() {
    var story = Story(
      title: "After the battle",
      description:
          "At the beginning of XVII century a confrontation flares up between Polish-Lithuanian Commonwealth and Ottoman Empire. As a result of a devastating defeat in the Battle of Cecora, a lot of noblemen, cossacks and soldiers perished or were captured by Turks and Tatars. A fate of a young cossack, wayfaring through the Wild FIelds in a desperate attempt to escape from captivity, depends on a reader of this interactive fiction. All challenges are equally hard: survive in a steppe, avoid the revenge of Tatars, win the trust of cossack fishermen and return home. But the time of the final battle that will change history is coming. Will the main character be able to participate in it and stay alive and where his life will go from there - only You know the answer.",
      authors: "Konstantin Boytsov, Anastasiia Tsapenko",
      root: Page.generate(),
      year: 1620,
    );
    return story;
  }

  Page findParentOfPage(Page page) {
    var queue = Queue<Page>();
    queue.add(root);
    while (queue.isNotEmpty) {
      var p = queue.removeFirst();
      if (p.next.where((pageNext) => pageNext.nextPage == page).length == 1) {
        return p;
      } else {
        queue.addAll(p.next.map((n) => n.nextPage));
      }
    }
    return null;
  }

  dispose() {
    _streamHistory.close();
  }
}

class HistoryItem {
  final String text;
  final List<String> imagePath;

  HistoryItem({this.text, this.imagePath});

  toMap() {
    return {
      "text": text,
      "imagePath": imagePath,
    };
  }

  static HistoryItem fromMap(Map map) {
    List listFromMap = map["imagePath"];
    List<String> imagePaths = listFromMap == null
        ? null
        : listFromMap.map((item) => "$item").toList();
    return HistoryItem(
      text: map["text"],
      imagePath: imagePaths,
    );
  }
}

class Page {
  List<PageNode> nodes;
  int currentIndex;

  Page parent;

  List<PageNext> next;

  EndType endType;

  Page({this.nodes, this.currentIndex = 0, this.next, this.endType}) {
    if (next == null) {
      next = List();
    }
    if (nodes == null) {
      nodes = List();
    }
  }

  PageNode getCurrentNode() {
    return nodes.elementAt(currentIndex);
  }

  bool hasNext() {
    return currentIndex + 1 < nodes.length;
  }

  String getCurrentText() {
    return getCurrentNode().text;
  }

  void addNodeWithText(String text) {
    var node = PageNode(text: text);
    nodes.add(node);
  }

  void removeNodeAtIndex(int i) {
    nodes.removeAt(i);
  }

  void removeNode(PageNode node) {
    nodes.remove(node);
  }

  void addNodeWithTextAtIndex(String text, int index) {
    var node = PageNode(text: text);
    nodes.insert(index, node);
  }

  changeParent(Page page) {
    parent = page;
  }

  isRoot() {
    return parent == null;
  }

  isTheEnd() {
    return endType != null;
  }

  void nextNode() {
    currentIndex++;
    if (currentIndex >= nodes.length) {
      throw "End of nodes for current page";
    }
  }

  void addNextPageWithText(String text) {
    var page = Page();
    next.add(PageNext(text: text, nextPage: page));
  }

  void removeNextPage(PageNext page) {
    next.remove(page);
  }

  static Page fromJSON(String input) {
    var map = jsonDecode(input);
    List next = map["next"];
    List nodes = map["nodes"];

    return Page(
      next: next.map((n) => PageNext.fromMap(n)).toList(),
      endType: endTypeFromString(map["endType"]),
      nodes: nodes.map((n) => PageNode.fromJSON(n)).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "endType": endTypeToString(endType),
      "next": next.map((n) => n.toMap()).toList(),
      "nodes": nodes.map((n) => n.toMap()).toList(),
    };
  }

  Map<String, dynamic> toStateMap() {
    return {
      "endType": endTypeToString(endType),
      "next": next.map((n) => n.toMap()).toList(),
      "nodes": nodes.map((n) => n.toMap()).toList(),
      "currentIndex": currentIndex,
    };
  }

  static Page fromMap(Map<String, dynamic> map) {
    if (map.isEmpty || map == null) {
      return Page();
    }
    List next = map["next"];
    List<PageNext> parsedNext = List.from(next.map((n) => PageNext.fromMap(n)));
    List nodes = map["nodes"];
    List<PageNode> parsedNodes =
        List.from(nodes.map((n) => PageNode.fromMap(n)));
    int currentI = map["currentIndex"];
    return Page(
      next: parsedNext,
      endType: endTypeFromString(map["endType"]),
      nodes: parsedNodes,
      currentIndex: currentI == null ? 0 : currentI,
    );
  }

  static Page generate() {
    var p1 = PageNode(
      text: "This is an example of passage text",
    );
    var p2 = PageNode(
      text: "This is second passage",
    );

    return Page(
        nodes: [p1, p2],
        endType: EndType.ALIVE,
        next: [
          PageNext(
            text: "Option 1",
            nextPage: Page(),
          ),
          PageNext(
            text: "Option 2",
            nextPage: Page(),
          )
        ]);
  }
}

class PageNext {
  String text;
  Page nextPage;

  PageNext({this.text, this.nextPage});

  static fromMap(Map<String, dynamic> map) {
    return PageNext(text: map["text"], nextPage: Page.fromMap(map["nextPage"]));
  }

  toMap() {
    return {
      "text": text,
      "nextPage": nextPage.toMap(),
    };
  }
}

enum EndType { DEAD, ALIVE }

String endTypeToString(EndType endType) {
  switch (endType) {
    case EndType.ALIVE:
      return "ALIVE";
    case EndType.DEAD:
      return "DEAD";
    default:
      return null;
  }
}

EndType endTypeFromString(String input) {
  switch (input) {
    case "ALIVE":
      return EndType.ALIVE;
    case "DEAD":
      return EndType.DEAD;
    default:
      return null;
  }
}

class PageNode {
  ImageType imageType;
  String text;

  PageNode({this.imageType, this.text});

  static fromJSON(String input) {
    var map = jsonDecode(input);
    return PageNode(
      imageType: imageTypeFromString(map["imageType"]),
      text: map["text"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "text": text,
      "imageType": imageTypeToString(imageType),
    };
  }

  static fromMap(Map<String, dynamic> map) {
    return PageNode(
      imageType: imageTypeFromString(map["imageType"]),
      text: map["text"],
    );
  }
}

ImageType imageTypeFromString(String input) {
  switch (input) {
    case "forest":
      return ImageType.FOREST;
    case "bulrush":
      return ImageType.BULRUSH;
    case "boat":
      return ImageType.BOAT;
    case "river":
      return ImageType.RIVER;
    case 'landing':
      return ImageType.LANDING;
    case 'camp':
      return ImageType.CAMP;
    case 'cossacks':
      return ImageType.COSSACKS;
    case 'camp':
      return ImageType.CAMP;
    default:
      return null;
  }
}

String imageTypeToString(ImageType imageType) {
  switch (imageType) {
    case ImageType.FOREST:
      return "forest";
    case ImageType.BOAT:
      return 'boat';
    case ImageType.BULRUSH:
      return 'bulrush';
    case ImageType.CAMP:
      return 'camp';
    case ImageType.COSSACKS:
      return 'cossacks';
    case ImageType.RIVER:
      return 'river';
    case ImageType.LANDING:
      return 'landing';
    case ImageType.STEPPE:
      return 'steppe';
    default:
      return null;
  }
}

class CannotContinue implements Exception {
  
}