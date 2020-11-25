import 'dart:math';

import 'package:gladstoriesengine/gladstoriesengine.dart';

// image: bulrush; image boat; image river; image cossacks, image fight, image steppe, image forest
class BackgroundImage {
  factory BackgroundImage() => _bgImage;
  static final BackgroundImage _bgImage = BackgroundImage._internal();

  BackgroundImage._internal();

  static Map<ImageType, RandomImage> _images = {
    ImageType.BOAT: RandomImage(ImageType.BOAT),
    ImageType.STEPPE: RandomImage(ImageType.RIVER), // shadowed
    ImageType.FOREST: RandomImage(ImageType.FOREST),
    ImageType.BULRUSH: RandomImage(ImageType.BULRUSH),
    ImageType.RIVER: RandomImage(ImageType.RIVER),
    ImageType.LANDING: RandomImage(ImageType.LANDING),
    ImageType.CAMP: RandomImage(ImageType.CAMP),
    ImageType.COSSACKS: RandomImage(ImageType.CAMP), // shadowed
  };

  static RandomImage getRandomImageForType(ImageType type) {
    return _images[type];
  }

  static void nextRandomForType(ImageType type) {
    return _images[type].nextRandom();
  }

  static void resetRandomForType(ImageType type) {
    return _images[type].resetUsedRandomNumbers();
  }
}

class RandomImage implements HistoryImage {
  Random _random = Random();
  int _currentRandom;
  int _max;
  List<int> _usedRandomNumbers;
  final ImageType type;

  Map<ImageType, String> _imagePrefix = {
    ImageType.BULRUSH: "bulrush",
    ImageType.FOREST: "forest",
    ImageType.STEPPE: "steppe",
    ImageType.BOAT: "boat",
    ImageType.RIVER: "river",
    ImageType.LANDING: 'landing',
    ImageType.CAMP: "camp",
    ImageType.COSSACKS: "cossacks",
  };

  RandomImage(this.type) {
    switch (type) {
      case ImageType.BOAT:
        _max = 18;
        break;
      case ImageType.FOREST:
        _max = 10;
        break;
      case ImageType.BULRUSH:
        _max = 12;
        break;
      case ImageType.RIVER:
        _max = 21;
        break;
      case ImageType.LANDING:
        _max = 8;
        break;
      case ImageType.CAMP:
        _max = 15;
        break;
      default:
        throw "Not implemented";
        break;
    }

    _currentRandom = _random.nextInt(_max);
    _usedRandomNumbers = [_currentRandom];
  }

  String getImagePath() {
    return "images/background/${_imagePrefix[type]}/${_currentRandom.toString()}.jpg";
  }

  String getImagePathColored() {
    return "images/background/${_imagePrefix[type]}/c_${_currentRandom.toString()}.jpg";
  }

  void nextRandom() {
    if (_usedRandomNumbers.length == _max) {
      _usedRandomNumbers = [];
    }
    var temp = _random.nextInt(_max);
    if (_usedRandomNumbers.indexOf(temp) >= 0) {
      nextRandom();
      return;
    } else {
      _currentRandom = temp;
    }
    _usedRandomNumbers.add(_currentRandom);
  }

  void resetUsedRandomNumbers() {
    _usedRandomNumbers = [];
  }
}
