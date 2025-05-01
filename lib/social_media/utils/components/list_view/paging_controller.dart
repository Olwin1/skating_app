import "package:flutter/material.dart";
import "package:infinite_scroll_pagination/infinite_scroll_pagination.dart";

typedef StateUpdater<T> = void Function(PagingState<int, T> pagingState);

class GenericStateController<T> {
  GenericStateController({
    required this.key,
    this.pageSize = 20,
  });

  final Key key;
  final int pageSize;
  late State _widget;
  late StateUpdater<T> _updateState;
  late Future<List<T>?> Function(int newKey, int pageSize) _builder;
  late List<T> Function() _lastPageBuilder;

  late PagingState<int, T> pagingState = PagingState<int, T>();

  void init(
      final State widget,
      final StateUpdater<T> updateState,
      final Future<List<T>?> Function(int newKey, int pageSize) builder,
      final List<T> Function() lastPageBuilder) {
    this._widget = widget;
    this._updateState = updateState;
    this._builder = builder;
    this._lastPageBuilder = lastPageBuilder;
  }

  Future<List<T>?> getNextPage() async {
    if (pagingState.isLoading | !_widget.mounted) {
      return null;
    }

    await Future.value();

    _updateState(pagingState.copyWith(isLoading: true, error: null));

    try {
      final newKey = (pagingState.keys?.last ?? -1) + 1;
      // Get new items
      final newItems = await _builder(newKey, pageSize);

      if (newItems == null) {
        throw Exception("No items were found. ");
      }

      // End of custom calls
      final isLastPage = newItems.isEmpty;

      if (isLastPage) {
        newItems.addAll(_lastPageBuilder());
      }

      _updateState(pagingState.copyWith(
        pages: [...?pagingState.pages, newItems],
        keys: [...?pagingState.keys, newKey],
        hasNextPage: !isLastPage,
        isLoading: false,
      ));
    } catch (error) {
      _updateState(pagingState.copyWith(
        error: error,
        isLoading: false,
      ));
    }
    return null;
  }

  void refresh() {
    if (!_widget.mounted) {
      return;
    }

    pagingState = PagingState<int, T>(hasNextPage: true, isLoading: false);

    _updateState(pagingState);
    // getNextPage(); // Optionally trigger first fetch immediately
  }
}
