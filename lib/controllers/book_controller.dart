import 'dart:async';
import 'dart:io';

import 'package:book_finder_app/services/api_service.dart';
import 'package:book_finder_app/utils/network_utils.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BookController extends GetxController {
  var books = <dynamic>[].obs;
  var popularBooks = <dynamic>[].obs;
  var errorMessage = "".obs;

  var isBooksLoading = false.obs;
  var isPopularBooksLoading = false.obs;
  var isOffline = false.obs;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  String? lastQueriedCategory;

  @override
  void onInit() {
    super.onInit();
    initializeData();
    _listenToInternetRestoration();
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }

  void _listenToInternetRestoration() {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        // If any type of connection is available, setting isOffline to false
        isOffline.value = false;
        fetchPopularBooks();
        if (lastQueriedCategory != null) {
          fetchBooks(lastQueriedCategory!);
        }
      } else {
        isOffline.value = true;
      }
    });
  }

  Future<void> initializeData() async {
    isPopularBooksLoading(true);
    bool isOnline = await checkInternetStatus();
    isOffline(!isOnline);

    if (isOnline) {
      await fetchPopularBooks();
    } else {
      await loadCachedPopularBooks();
    }
  }

  Future<void> loadCachedPopularBooks() async {
    try {
      final Box popularBookDataBox = await Hive.openBox('popular_book_data');
      final cachedBooks = popularBookDataBox.get('popular');

      if (cachedBooks != null) {
        popularBooks.assignAll(cachedBooks);
      } else {
        errorMessage.value = "No cached popular books available";
        popularBooks.clear();
      }
    } catch (e) {
      errorMessage.value = "Error loading cached data: $e";
    } finally {
      isPopularBooksLoading(false);
    }
  }

  Future<void> fetchBooks(String query) async {
    isBooksLoading(true);

    bool isOnline = await checkInternetStatus();
    isOffline(!isOnline);
    lastQueriedCategory = query;
    try {
      final Box bookDataBox = await Hive.openBox('book_data');

      if (isOnline) {
        // Online - fetch new data
        try {
          final fetchedBooks = await ApiService().fetchBooks(subject: query);
          await bookDataBox.put(query, fetchedBooks); // Cache the new data
          books.assignAll(fetchedBooks);
        } catch (e) {
          // Handle other errors
          errorMessage.value = "Error: $e";
          books.clear();
        }
      } else {
        // Offline - use cached data
        final cachedBooks = bookDataBox.get(query);
        if (cachedBooks != null) {
          books.assignAll(cachedBooks);
        } else {
          errorMessage.value =
              "No internet connection and no cached data available for $query";
          books.clear();
        }
      }
    } catch (e) {
      errorMessage.value = "Error: $e";
      books.clear();
    } finally {
      isBooksLoading(false);
    }
  }

  Future<void> fetchPopularBooks() async {
    isPopularBooksLoading(true);
    bool isOnline = await checkInternetStatus();
    isOffline(!isOnline);

    try {
      final Box popularBookDataBox = await Hive.openBox('popular_book_data');

      if (isOnline) {
        // Online - fetch new data
        try {
          final fetchedPopularBooks = await ApiService()
              .fetchBooks(subject: "Technology", maxResults: 3);
          await popularBookDataBox.put('popular', fetchedPopularBooks);
          popularBooks.assignAll(fetchedPopularBooks);
        } catch (e) {
          // Handle other errors
          errorMessage.value = "Error: $e";
          popularBooks.clear();
        }
      } else {
        // Offline - use cached data
        final cachedBooks = popularBookDataBox.get('popular');
        if (cachedBooks != null) {
          popularBooks.assignAll(cachedBooks);
        } else {
          errorMessage.value = "No cached popular books available";
          popularBooks.clear();
        }
      }
    } catch (e) {
      errorMessage.value = "Error: $e";
      popularBooks.clear();
    } finally {
      isPopularBooksLoading(false);
    }
  }
}
