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
      expect(story.description != null, equals(true));
    });
    test("Inits the root page", () {
      expect(story.root != null, equals(true));
    });
    test("Inits the current page page", () {
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
      expect(story.root != null, equals(true));
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
      expect(story.history.isNotEmpty, equals(true));
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
      expect(story.history.isNotEmpty, equals(true));
    });

    test("Inits history from history argument", () {
      expect(story.history[0].text, equals("Test Node"));
    });
  });
}
