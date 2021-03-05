import 'package:gladstoriesengine/gladstoriesengine.dart';

// read current page

void main() {
  // create first page of the story

  var rootPage = Page(
    nodes: [
      // the page has two passages "Test" and "Second"
      PageNode(text: "Test"),
      PageNode(text: "Second"),
    ],
    // After the last passage is reached the reader should select option from the next array
    next: [
      PageNext(
        text: "Go to next page",
        // this page will be the next one to read, once the user selects "Go to next page"
        nextPage: Page(
          nodes: [
            PageNode(text: "inner node"),
          ],
          endType: EndType.ALIVE,
          next: List.empty(growable: true),
        ),
      ),
    ],
  );

// initialize Story with the root page and other meta data
  var story = Story(
      authors: "Authors",
      title: "Title",
      description: "Test Description",
      year: 1648,
      root: rootPage,
      currentPage: rootPage);

  // check that story can continue
  story.canContinue(); // returns true

  // get current text of the story on this page.
  story.currentPage.getCurrentText(); // returns "Test"

  // continue to next Node
  story.doContinue();

  // get a new current text
  story.currentPage.getCurrentText(); // returns "Second"

  // the story cannot auto continue as the page reached its last passage
  // You need to show the user list of available next options
  if (!story.canContinue()) {
    // returns false
    story.currentPage.next
        .forEach((nextNode) => print(nextNode.text)); // prints Go to next page

    // use goToNextPage and pass the reference to PageNext
    // this action will add "Go to next page" (the next option name) and
    // the "inner node" (the first node of the next page) to the history array
    story.goToNextPage(
      story.currentPage.next[0],
    ); // switches currentpage to the next page
  }

  // the story cannot continue as the next page has only one node,
  // which is auto played when reader switches to it
  story.canContinue(); // returns false
  print(
    story.history.map((f) => f.text),
  ); // prints (Test, Second, Go to next page, inner node)

  // the current page has 'endType' defined. It means the story will end on this page with either
  // EndType.ALIVE or EndType.DEAD options. It is up to you to decide what to show to user.
  story.currentPage.isTheEnd(); // true
  story.currentPage.endType; // EndType.ALIVE
}
