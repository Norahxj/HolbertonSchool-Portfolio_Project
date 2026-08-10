import 'package:flutter/foundation.dart';

class AppNavigationController extends ChangeNotifier {
  AppNavigationController({required int initialIndex})
    : _currentIndex = initialIndex,
      _loadedIndexes = {initialIndex};

  int _currentIndex;

  final Set<int> _loadedIndexes;
  final Map<int, int> _reselectionVersions = {};

  int _childrenVersion = 0;

  int get currentIndex => _currentIndex;

  int get childrenVersion => _childrenVersion;

  bool isLoaded(int index) {
    return _loadedIndexes.contains(index);
  }

  int reselectionVersionFor(int index) {
    return _reselectionVersions[index] ?? 0;
  }

  void selectTab(int index) {
    if (_currentIndex == index) {
      _reselectionVersions[index] = reselectionVersionFor(index) + 1;

      notifyListeners();
      return;
    }

    openTab(index);
  }

  void openTab(int index) {
    if (_currentIndex == index) {
      return;
    }

    _currentIndex = index;
    _loadedIndexes.add(index);

    notifyListeners();
  }

  void notifyChildrenChanged() {
    _childrenVersion++;
    notifyListeners();
  }
}
