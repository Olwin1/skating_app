import "package:flutter/material.dart";
import "package:infinite_scroll_pagination/infinite_scroll_pagination.dart";

/// Default implementation of [PagingController]
/// that handles the tracking of pagination within the scrollview
///
/// Usage:
///
/// 1. Create an instance of [GenericPagingController], passing in a [getPage] function
// ignore: comment_references
///    that fetches the data based on the [pageKey].
/// 2. Call [initialize()] after the object is created to properly initialize the
///    [pagingController].
///
/// Example:
/// ```dart
/// final GenericPagingController<Map<String, dynamic>> genericPagingController =
///     GenericPagingController<Map<String, dynamic>>(
///   getPage: getPage,
///   key: const Key("connectionsList"),
/// );
///
///   @override
///   void initState() {
///
///     // Initialize paging controller
///     genericPagingController.initialize(getPage);#
///
///     super.initState();
///    }
/// ```
class GenericPagingController<T> {
  /// Creates an instance of [GenericPagingController].
  ///
  /// This constructor accepts a [key], a [getPage] function to fetch data,
  /// and an optional [pageSize] that determines how many items should be
  /// loaded per page (defaults to 20).
  ///
  // ignore: comment_references
  /// The [getPage] function is used to fetch the data, where the [pageKey]
  /// is passed to retrieve the corresponding page.
  GenericPagingController({
    required this.key,
    this.pageSize = 20,
  });

  final Key key;
  final int pageSize;

  // ignore: comment_references
  /// A function that fetches a page of data, taking the [pageKey] and returning
  /// a list of of type [T]. It is expected to return a list of
  /// data for a given page or `null` if the page fetch fails.
  late Future<List<T>?> Function(int pageKey) getPage;

  /// The actual [PagingController] that handles the pagination logic.
  late PagingController<int, T> pagingController;

  /// Initializes the [pagingController] and adds the page request listener.
  ///
  /// This method should be called after the [GenericPagingController] instance
  /// is created to properly set up the paging functionality.
  Future<void> initialize(
      final Future<List<T>?> Function(int pageKey) callback) async {
    getPage = callback;
    pagingController = PagingController(firstPageKey: 0);

    // Add the page request listener here, after the instance is fully created
    pagingController.addPageRequestListener(_fetchPage);
  }

  /// Fetches the next page of data when requested by the [PagingController].
  ///
  /// This method is triggered by the [PagingController] when the user scrolls
  /// to the bottom of the list and requests the next page of data. It uses the
  /// [getPage] function to fetch the data and updates the [pagingController]
  /// with the results.
  ///
  /// If the page is the last one, it appends the last page to the controller,
  /// otherwise, it appends the next page with a new page key.
  Future<void> _fetchPage(final int pageKey) async {
    try {
      // Fetch a page of suggestions from the API using the getPage function
      final List<T>? page = await this.getPage(pageKey);

      if (page == null) {
        return;
      }

      // Determine if this is the last page
      final isLastPage = page.length < pageSize;

      if (isLastPage) {
        // If this is the last page, append it and mark as the last
        pagingController.appendLastPage(page);
      } else {
        // If not the last page, append the page and prepare for the next request
        final nextPageKey = pageKey + 1;
        pagingController.appendPage(page, nextPageKey);
      }
    } catch (error) {
      // If there's an error fetching the page, set the error on the controller
      pagingController.error = error;
    }
  }
}
