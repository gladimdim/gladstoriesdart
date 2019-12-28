import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:rxdart/rxdart.dart';

/// Contains supported by the Loca Deserta Image Types of the Page Nodes.
enum ImageType { BOAT, STEPPE, FOREST, BULRUSH, RIVER, LANDING, CAMP, COSSACKS }

/// Used to generate image paths on the real device for the ImageType.
///
/// The ImageType is provided in the constructor.
/// This abstract class is used by the ImageResolver functional typedef.
abstract class HistoryImage {
  /// Must return colored image based on the ImageType.
  String getImagePathColored();

  /// Must return black&white image based on the ImageType.
  String getImagePath();
}

/// Used to resolve the ImageType to the real path on the device to the image
typedef ImageResolver = HistoryImage Function(ImageType type);

/// The main class for the GladStoriesEngine.
///
/// Contains everything needed to create, update, save, restore the interactive fiction.
/// The Story instance has the necessary metadata of the book saved in the instance propertires.
class Story {
  /// The title of the book
  String title;

  /// The description of the book
  String description;

  /// The list of authors separated by the comma
  String authors;

  /// The year in which the interactive fiction story took place
  int year;

  /// The starting Page of the interactive Story.
  ///
  /// This can be mutated only when the Story is used in editor mode.
  /// In all other cases it must be immutable.
  Page root;

  /// List of the nodes and choices already done by the player.
  ///
  /// Usually contains just text but can also include nodes with images.
  List<HistoryItem> history;

  /// The current Page of the Story.
  ///
  /// When Story is just started then the root Page and the currentPage are identical.
  /// When player reads the Story, the currentPage is referenced to the current page.
  /// When player makes a choice and goes to choice page, then the currentPage is reassigned
  /// to the nextPage.
  /// When player starts Story from the beginning by calling:
  /// ```dart
  /// story.reset();
  /// ```
  /// Then the currentPage is reassigned to the root page.
  Page currentPage;

  /// A reference to the function to transform ImageType from enum into real image paths on the device.
  ImageResolver imageResolver;

  final BehaviorSubject _streamHistory = BehaviorSubject<List<HistoryItem>>();

  /// A stream with the full list of history.
  ///
  /// New values are pushed to the stream when user presses Continue or makes a choice.
  /// By default, once the Story is started the stream will contains the very first node
  /// from the first page.
  /// This stream can be used by Flutter StreamBuilder widget to react to the Story changes.
  /// The stream contains all the necessary info to update and build the Story view.
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
    root ??= Page(nodes: []);
    currentPage ??= root;
    history ??= [];

    historyChanges = _streamHistory.stream;
    // if the Story was just opened then add the very first node from current page to the history.
    if (history.isEmpty) {
      _logCurrentPassageToHistory();
    }
  }

  /// Makes the read Story to be unread again.
  ///
  /// Use this method when player wants to start reading the Story from the beginning.
  /// Resets currentPage to point back to the root page.
  /// Resets current node count to point to the first node in the Page.
  void reset() {
    history = [];
    currentPage = root;
    currentPage.currentIndex = 0;
    _logCurrentPassageToHistory();
  }

  void _logCurrentPassageToHistory() {
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

  /// Jump to the next node (passage) on the current page.
  ///
  /// Throws an exception CannotContinue when the current page has no next nodes.
  /// This means that either the book has ended and the consumer of this API must
  /// check story.currentPage.isTheEnd or the player must be presented with the list of
  /// next choices to be selected.
  void doContinue() {
    if (canContinue()) {
      currentPage.nextNode();
      _logCurrentPassageToHistory();
    } else {
      throw CannotContinue;
    }
  }

  /// Used to jump to the next page based on the Player's choice.
  void goToNextPage(PageNext next) {
    history.add(
      HistoryItem(text: next.text),
    );
    currentPage = next.nextPage;
    currentPage.currentIndex = 0;
    _logCurrentPassageToHistory();
  }

  /// Checks whether the currentPage has the next node.
  bool canContinue() {
    return currentPage.hasNextNode();
  }

  /// Serializes the Story without the state and currentPage to the Map.
  ///
  /// Used to persist the Story.
  String toJson() {
    return jsonEncode({
      'title': title,
      'description': description,
      'authors': authors,
      'root': root.toMap(),
      'year': year,
    });
  }

  /// Serializes the Story with the state, history and the currentPage to the Map.
  ///
  /// Used to persist the Story with saved player's progress.
  String toStateJson() {
    return jsonEncode({
      'title': title,
      'description': description,
      'authors': authors,
      'root': root.toMap(),
      'currentPage': currentPage.toStateMap(),
      'year': year,
      'history': history.map((historyItem) => historyItem.toMap()).toList(),
    });
  }

  /// Initializes the story from the input json.
  static Story fromJson(String input, {ImageResolver imageResolver}) {
    Map map = jsonDecode(input);
    var rootMap = map["root"];
    var rootPage = Page.fromMap(rootMap);
    var currentPageMap = map['currentPage'];
    var currentPage =
        currentPageMap == null ? null : Page.fromMap(map['currentPage']);
    List historyList = map['history'];
    String authors = map["authors"];
    return Story(
      title: map['title'],
      description: map['description'],
      root: rootPage,
      authors: authors,
      year: map['year'],
      currentPage: currentPage,
      imageResolver: imageResolver,
      history: historyList == null
          ? []
          : historyList.map((item) => HistoryItem.fromMap(item)).toList(),
    );
  }

  /// Generates dummy story just to get started.
  static generate() {
    var story = Story(
      title: 'After the battle',
      description:
          'At the beginning of XVII century a confrontation flares up between Polish-Lithuanian Commonwealth and Ottoman Empire. As a result of a devastating defeat in the Battle of Cecora, a lot of noblemen, cossacks and soldiers perished or were captured by Turks and Tatars. A fate of a young cossack, wayfaring through the Wild FIelds in a desperate attempt to escape from captivity, depends on a reader of this interactive fiction. All challenges are equally hard: survive in a steppe, avoid the revenge of Tatars, win the trust of cossack fishermen and return home. But the time of the final battle that will change history is coming. Will the main character be able to participate in it and stay alive and where his life will go from there - only You know the answer.',
      authors: 'Konstantin Boytsov, Anastasiia Tsapenko',
      root: Page.generate(),
      year: 1620,
    );
    return story;
  }

  /// Finds the parent page of the provided page.
  ///
  /// Does a tree breadth first search to find the parent of the page.
  /// This is used to be able to navigate in the page hierarchy.
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
  /// Text to be shown to the user.
  final String text;

  /// Images to be shown to the user.
  ///
  /// Can be empty.
  final List<String> imagePath;

  HistoryItem({this.text, this.imagePath});

  /// Used to serialize to the map for persisting data.
  Map toMap() {
    return {
      'text': text,
      'imagePath': imagePath,
    };
  }

  static HistoryItem fromMap(Map map) {
    List listFromMap = map['imagePath'] as List;
    List<String> imagePaths = listFromMap == null
        ? null
        : listFromMap.map((item) => "$item").toList();
    return HistoryItem(
      text: map['text'] as String,
      imagePath: imagePaths,
    );
  }
}

class Page {
  /// List of the passages of the page.
  ///
  /// Player has to press "Continue" button in order to jump to the next node on the page.
  List<PageNode> nodes;

  /// Pointer to the current node.
  int currentIndex;

  /// The reference to the Page from which user can get to this page.
  Page parent;

  /// List of next choices which are shown to user.
  ///
  /// Contains the text + reference to the next page.
  List<PageNext> next;

  /// Is not null if the Page is the end of the story.
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

  /// Returns true if there are more nodes.
  bool hasNextNode() {
    return currentIndex + 1 < nodes.length;
  }

  /// Returns true if there are choices on the page.
  bool hasNext() {
    return next.isNotEmpty;
  }

  /// Returns text of the current node.
  String getCurrentText() {
    return getCurrentNode().text;
  }

  /// Add a new node (paragraph) to the current page.
  ///
  ///
  /// This is used by the Editor of the interactive fiction story.
  /// Should not be used in the 'reading' mode (when player reads the book).
  void addNodeWithText(String text) {
    var node = PageNode(text: text);
    nodes.add(node);
  }

  /// Used by the Editor to remove the node at specific index.
  void removeNodeAtIndex(int i) {
    nodes.removeAt(i);
  }

  /// Used by the Editor to remove the node by reference.
  void removeNode(PageNode node) {
    nodes.remove(node);
  }

  /// Used by the Editor to insert new node at specific index.
  void addNodeWithTextAtIndex(String text, int index) {
    var node = PageNode(text: text);
    nodes.insert(index, node);
  }

  /// Used to reassign page to another place in the Story.
  void changeParent(Page page) {
    parent = page;
  }

  /// Returns true if the page does not have parents.
  bool isRoot() {
    return parent == null;
  }

  /// Used to notify the Player that the Story has ended.
  bool isTheEnd() {
    return endType != null;
  }

  /// Used by the Editor to navigate to the next node.
  void nextNode() {
    currentIndex++;
    if (currentIndex >= nodes.length) {
      throw 'End of nodes for current page';
    }
  }

  /// Used by the Editor to add choice with next page.
  void addNextPageWithText(String text) {
    var page = Page();
    next.add(PageNext(text: text, nextPage: page));
  }

  /// Used by the Editor to remove choice with the page.
  void removeNextPage(PageNext page) {
    next.remove(page);
  }

  /// Used to deserialize Page from the json string.
  static Page fromJSON(String input) {
    var map = jsonDecode(input);
    List next = map['next'];
    List nodes = map['nodes'];

    return Page(
      next: next.map((n) => PageNext.fromMap(n)).toList(),
      endType: endTypeFromString(map["endType"]),
      nodes: nodes.map((n) => PageNode.fromJSON(n)).toList(),
    );
  }

  /// Used to serialize Page instance to map for persistence.
  ///
  /// Does not save the state of the Page.
  Map<String, dynamic> toMap() {
    return {
      'endType': endTypeToString(endType),
      'next': next.map((n) => n.toMap()).toList(),
      'nodes': nodes.map((n) => n.toMap()).toList(),
    };
  }

  /// Used to serialize Page instance with state to map for persistence.
  ///
  /// Saves the player's state of the Page.
  Map<String, dynamic> toStateMap() {
    return {
      'endType': endTypeToString(endType),
      'next': next.map((n) => n.toMap()).toList(),
      "nodes": nodes.map((n) => n.toMap()).toList(),
      "currentIndex": currentIndex,
    };
  }

  /// Used to deserialize from the map into Page instance.
  ///
  /// If the state was present, it will be restored too.
  static Page fromMap(Map<String, dynamic> map) {
    if (map.isEmpty || map == null) {
      return Page();
    }
    List next = map['next'];
    List<PageNext> parsedNext = List.from(next.map((n) => PageNext.fromMap(n)));
    List nodes = map['nodes'];
    List<PageNode> parsedNodes =
        List.from(nodes.map((n) => PageNode.fromMap(n)));
    int currentI = map['currentIndex'];
    return Page(
      next: parsedNext,
      endType: endTypeFromString(map['endType']),
      nodes: parsedNodes,
      currentIndex: currentI == null ? 0 : currentI,
    );
  }

  /// Used to generate dummy Page.
  static Page generate() {
    var p1 = PageNode(
      text: 'This is an example of passage text',
    );
    var p2 = PageNode(
      text: 'This is second passage',
    );

    return Page(
        nodes: [p1, p2],
        endType: EndType.ALIVE,
        next: [
          PageNext(
            text: 'Option 1',
            nextPage: Page(),
          ),
          PageNext(
            text: 'Option 2',
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
    return PageNext(text: map['text'], nextPage: Page.fromMap(map['nextPage']));
  }

  Map toMap() {
    return {
      'text': text,
      'nextPage': nextPage.toMap(),
    };
  }
}

enum EndType { DEAD, ALIVE }

String endTypeToString(EndType endType) {
  switch (endType) {
    case EndType.ALIVE:
      return 'ALIVE';
    case EndType.DEAD:
      return 'DEAD';
    default:
      return null;
  }
}

EndType endTypeFromString(String input) {
  switch (input) {
    case 'ALIVE':
      return EndType.ALIVE;
    case 'DEAD':
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
      imageType: imageTypeFromString(map['imageType']),
      text: map['text'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'imageType': imageTypeToString(imageType),
    };
  }

  static fromMap(Map<String, dynamic> map) {
    return PageNode(
      imageType: imageTypeFromString(map['imageType']),
      text: map['text'],
    );
  }
}

ImageType imageTypeFromString(String input) {
  switch (input) {
    case 'forest':
      return ImageType.FOREST;
    case 'bulrush':
      return ImageType.BULRUSH;
    case 'boat':
      return ImageType.BOAT;
    case "river":
      return ImageType.RIVER;
    case 'landing':
      return ImageType.LANDING;
    case 'camp':
      return ImageType.CAMP;
    case 'cossacks':
      return ImageType.COSSACKS;
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

class CannotContinue implements Exception {}
