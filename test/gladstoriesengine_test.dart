import 'package:test/test.dart';
import 'package:gladstoriesengine/gladstoriesengine.dart';

void main() {
  var gladStory =
      '{"title":"After the Battle","description":"At the beginning of the XVII century...","authors":"Dmytro Gladkyi, Someone else","year":1648,"root":{"endType":null,"nodes":[{"text":"Dmytro lay hidden in the thicket far from the water","imageType":"river"},{"text":"The Cossack lay like this for a long time."}],"next":[{"text":"Shoot the rifle","nextPage":{}},{"text":"Run away","nextPage":{}}]}}';
  group("Can be initialized from json", () {
    var story = Story.fromJson(gladStory);
    test("Inits the title", () {
      expect(story.title, equals("After the Battle"));
    });
    test("Inits the description", () {
      expect(story.description != null, isTrue);
    });
    test("Inits the root page", () {
      expect(story.root != null, isTrue);
    });
    test("Inits the current page", () {
      expect(story.root, equals(story.currentPage));
    });
    test("Inits the history list", () {
      expect(story.history.length, equals(1));
    });
    test("Inits the year", () {
      expect(story.year, equals(1648));
    });
    test("Inits the authors", () {
      expect(story.authors, equals("Dmytro Gladkyi, Someone else"));
    });
  });

  group("Can be initialized from constructor", () {
    var story = Story(
        authors: "Authors",
        title: "Title",
        description: "Test Description",
        year: 1648,
        root: Page());

    test("Inits the title", () {
      expect(story.title, equals("Title"));
    });
    test("Inits the description", () {
      expect(story.description, equals("Test Description"));
    });
    test("Inits the root page", () {
      expect(story.root != null, isTrue);
    });
    test("Inits the current page page", () {
      expect(story.root, equals(story.currentPage));
    });
    test("Inits the history list with an empty list as root is empty Page", () {
      expect(story.history.length, equals(0));
    });
    test("Inits the year", () {
      expect(story.year, equals(1648));
    });
    test("Inits the authors", () {
      expect(story.authors, equals("Authors"));
    });
  });

  group("Inits with history array from Page", () {
    var story = Story(
      authors: "Authors",
      title: "Title",
      description: "Test Description",
      year: 1648,
      root: Page(nodes: [PageNode(text: "Test")]),
      // history: [HistoryItem(imagePath: [], text: "Test")],
    );

    test("Inits with non-empty history array if page is not empty", () {
      expect(story.history.isNotEmpty, isTrue);
    });

    test("Inits history with the first node from Page", () {
      expect(story.history[0].text, equals("Test"));
    });
  });

  group("Inits with history array", () {
    var story = Story(
      authors: "Authors",
      title: "Title",
      description: "Test Description",
      year: 1648,
      root: Page(nodes: [PageNode(text: "Test")]),
      history: [HistoryItem(imagePath: [], text: "Test Node")],
    );

    test("Inits with history argument if it is present", () {
      expect(story.history.isNotEmpty, isTrue);
    });

    test("Inits history from history argument", () {
      expect(story.history[0].text, equals("Test Node"));
    });
  });

  group("Story API. ", () {
    var story = Story(
      authors: "Authors",
      title: "Title",
      description: "Test Description",
      year: 1648,
      root: Page(
        nodes: [PageNode(text: "Test"), PageNode(text: "Second")],
        next: [
          PageNext(
            text: "Go to next page",
            nextPage: Page(
              nodes: [
                PageNode(text: "inner node"),
              ],
            ),
          ),
        ],
      ),
      history: [HistoryItem(imagePath: [], text: "Test Node")],
    );

    test("Can jump to next node if present.", () async {
      expect(story.history.length, equals(1));
      story.doContinue();
      expect(story.history.length, equals(2));
    });

    test("Cannot continue when at the end", () {
      expect(story.canContinue(), isFalse);
      expect(story.history.length, equals(2));
    });

    test("Cannot continue when at the end", () {
      expect(story.doContinue, throwsA(CannotContinue));
    });

    test(
        "Can go to next page by name. Adds next text and the first node to history",
        () {
      story.goToNextPage(story.currentPage.next[0]);
      expect(story.history.length, equals(4));
      expect(story.history[3].text, equals("inner node"));
      expect(story.history[2].text, equals("Go to next page"));
    });

    test("Can find parent Page of the child page by reference", () {
      expect(story.findParentOfPage(story.currentPage), equals(story.root));
    });

    test(
        "Can convert itself to json string and initialize from that string back.",
        () {
      String json = story.toJson();
      expect(json.contains("year"), isTrue);
      expect(json.contains("title"), isTrue);
      expect(json.contains("description"), isTrue);
      expect(json.contains("history"), isFalse);
      var storyFromJson = Story.fromJson(json);
      expect(storyFromJson.title, equals("Title"));
      expect(storyFromJson.currentPage, equals(storyFromJson.root));
    });

    test(
        "Can convert itself to json with state and initialize from that string back",
        () {
      String jsonWithState = story.toStateJson();
      expect(jsonWithState.contains("history"), isTrue);
      expect(jsonWithState.contains("currentPage"), isTrue);

      var storyFromStateJson = Story.fromJson(jsonWithState);
      expect(storyFromStateJson.history.length, equals(4));
      expect(
          storyFromStateJson.root == storyFromStateJson.currentPage, isFalse);
    });

    test("Can reset the story state back to the beginning of the story", () {
      story.reset();
      expect(story.history.length, equals(1));
      expect(story.currentPage, equals(story.root));
      expect(story.currentPage.currentIndex, equals(0));
    });
  });

  group("Page tests", () {
    var page = Page(nodes: [
      PageNode(
        text: "First",
        imageType: ImageType.BOAT,
      ),
      PageNode(
        text: "Second",
      ),
    ], next: [
      PageNext(
        text: "Next Options",
        nextPage: Page(),
      ),
    ]);

    test("Can get current node", () {
      expect(page.getCurrentNode().text, equals("First"));
    });

    test("Can get current text from the current node", () {
      expect(page.getCurrentText(), equals("First"));
    });

    test("Can tell if next node is present", () {
      expect(page.hasNextNode(), isTrue);
    });

    test("Can tell if the next options are available", () {
      expect(page.hasNext(), isTrue);
    });

    test("Can proceed to next node", () {
      page.nextNode();
      expect(page.hasNextNode(), isFalse);
    });
  });
}