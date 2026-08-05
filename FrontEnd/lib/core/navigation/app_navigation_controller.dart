import 'package:flutter/foundation.dart';

/// Controls the selected bottom-navigation tab.
///
/// It also remembers which tabs have already been opened so that
/// unvisited screens do not make API requests before they are needed.
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

  /// Returns true after a tab has been opened at least once.
  bool isLoaded(int index) {
    return _loadedIndexes.contains(index);
  }

  /// Returns how many times the currently selected tab was selected again.
  ///
  /// The parent Tasks tab uses this value to reset its form.
  int reselectionVersionFor(int index) {
    return _reselectionVersions[index] ?? 0;
  }

  void selectTab(int index) {
    if (_currentIndex == index) {
      _reselectionVersions[index] = reselectionVersionFor(index) + 1;

      notifyListeners();
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
