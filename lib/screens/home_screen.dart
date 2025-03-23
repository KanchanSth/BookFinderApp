import 'package:book_finder_app/controllers/theme_controller.dart';
import 'package:book_finder_app/core/app/dimensions.dart';
import 'package:book_finder_app/screens/book_details_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../controllers/book_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final bookController = Get.find<BookController>();
  final List<String> categories = [
    "Technology",
    "Science",
    "Business",
    "Fiction",
    "Psychology"
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);

    bookController.fetchBooks(categories[_tabController.index]);

//handle the tabview change through swipe
    _tabController.animation?.addListener(() {
      final newIndex = _tabController.animation?.value.round();

      if (_tabController.index != newIndex) {
        bookController.isBooksLoading.value = true;
      }
    });

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        bookController.fetchBooks(categories[_tabController.index]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Book Finder App'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.brightness_6),
              onPressed: () {
                Get.find<ThemeController>().toggleTheme();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Obx(() {
              if (bookController.errorMessage.isNotEmpty) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  color: Colors.red.shade100,
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      hSizedBox0,
                      Expanded(
                        child: Text(
                          bookController.errorMessage.value,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          bookController.errorMessage.value = "";
                        },
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            Expanded(
              child: Obx(() {
                if (bookController.popularBooks.isEmpty &&
                    bookController.isPopularBooksLoading.value == false) {
                  return const Center(child: Text("No books found."));
                }
                if (bookController.popularBooks.isEmpty &&
                    bookController.isPopularBooksLoading.value == false &&
                    bookController.isOffline.value) {
                  return const Center(
                      child: Text(
                          "No books found. Please check your internet connection!!!"));
                }

                if (bookController.isPopularBooksLoading.value) {
                  //placeholder to show the loading effect
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      vSizedBox0,
                      const Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: Text(
                          "Popular Tech Books",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      Container(
                        height: 190,
                        padding: const EdgeInsets.all(12),
                        child: Skeletonizer(
                          enabled: true,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 3,
                            itemBuilder: (context, index) {
                              return Card(
                                elevation: 4,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 3, vertical: 3),
                                child: Column(
                                  children: [
                                    vSizedBox0,
                                    Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(
                                        height: 110,
                                        width: 130,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    vSizedBox0,
                                    const Text(
                                      "title....",
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TabBar(
                              tabAlignment: TabAlignment.start,
                              controller: _tabController,
                              isScrollable: true,
                              tabs: categories
                                  .map((category) => Tab(text: category))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Skeletonizer(
                          enabled: true,
                          child: ListView.builder(
                            itemCount: 5,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: const Text("Loading title..."),
                                subtitle: const Text("Loading author..."),
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.book, size: 25),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.favorite_border,
                                      color: Colors.red),
                                  onPressed: () {},
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: Text(
                        "Popular Tech Books",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    Container(
                      height: 190,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Obx(() {
                        return Skeletonizer(
                          enabled: false,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: bookController.popularBooks.length,
                            itemBuilder: (context, index) {
                              final book = bookController.popularBooks[index]
                                  ["volumeInfo"];
                              final title = book["title"] ?? "No Title";
                              final thumbnail = book["imageLinks"]
                                      ?["thumbnail"] ??
                                  "https://placehold.co/600x400";

                              return GestureDetector(
                                onTap: () {
                                  Get.to(BookDetailsScreen(
                                      book:
                                          bookController.popularBooks[index]));
                                },
                                child: Card(
                                  elevation: 4,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 3, vertical: 3),
                                  child: Column(
                                    children: [
                                      vSizedBox0,
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: CachedNetworkImage(
                                          imageUrl: thumbnail,
                                          width: 150,
                                          height: 110,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              SizedBox(
                                            child: Shimmer.fromColors(
                                              baseColor: Colors.grey[300]!,
                                              highlightColor: Colors.grey[100]!,
                                              child: Container(
                                                height: 150,
                                                width: 120,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                            width: 150,
                                            height: 120,
                                            color: Colors.grey.shade200,
                                            child: Icon(Icons.book,
                                                color: Colors.grey.shade600),
                                          ),
                                        ),
                                      ),
                                      vSizedBox0,
                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Text(title,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TabBar(
                            tabAlignment: TabAlignment.start,
                            controller: _tabController,
                            isScrollable: true,
                            tabs: categories
                                .map((category) => Tab(text: category))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: categories.map((category) {
                          return ValueListenableBuilder(
                            valueListenable:
                                Hive.box('favorite_book_data').listenable(),
                            builder: (context, box, child) {
                              return Obx(() {
                                if (bookController.books.isEmpty &&
                                    bookController.isBooksLoading.value ==
                                        false) {
                                  return Center(
                                      child: Text(
                                          "No books found for $category."));
                                }

                                if (bookController.books.isEmpty &&
                                    bookController.isBooksLoading.value ==
                                        false &&
                                    bookController.isOffline.value) {
                                  return Center(
                                      child: Text(
                                          "No books found for $category. Please check your internet connection!!!"));
                                }
                                if (bookController.isBooksLoading.value) {
                                  // Placeholder until the data loads
                                  return Skeletonizer(
                                    enabled: true,
                                    child: ListView.builder(
                                      itemCount: 5,
                                      itemBuilder: (context, index) {
                                        return ListTile(
                                          title: const Text("Loading title..."),
                                          subtitle:
                                              const Text("Loading author..."),
                                          leading: Container(
                                            width: 50,
                                            height: 50,
                                            color: Colors.grey.shade200,
                                            child: const Icon(Icons.book,
                                                size: 25),
                                          ),
                                          trailing: IconButton(
                                            icon: const Icon(
                                                Icons.favorite_border,
                                                color: Colors.red),
                                            onPressed: () {},
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                }
                                return ListView.builder(
                                  itemCount: bookController.books.length,
                                  itemBuilder: (context, index) {
                                    final book = bookController.books[index]
                                        ["volumeInfo"];

                                    final String bookId =
                                        book["title"] + "_" + category;
                                    final isFavorite = box.get(bookId) != null;

                                    return ListTile(
                                      title: Text(book["title"]),
                                      subtitle: Text(book["authors"] != null
                                          ? book["authors"][0]
                                          : ""),
                                      leading: book["imageLinks"] != null
                                          ? CachedNetworkImage(
                                              imageUrl: book["imageLinks"]
                                                  ["thumbnail"],
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  SizedBox(
                                                child: Shimmer.fromColors(
                                                  baseColor: Colors.grey[300]!,
                                                  highlightColor:
                                                      Colors.grey[100]!,
                                                  child: Container(
                                                    height: 150,
                                                    width: 120,
                                                    margin: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Container(
                                                width: 50,
                                                height: 50,
                                                color: Colors.grey.shade200,
                                                child: const Icon(Icons.book,
                                                    size: 25),
                                              ),
                                            )
                                          : const Icon(Icons.book),
                                      trailing: IconButton(
                                        icon: Icon(
                                            isFavorite
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: Colors.red),
                                        onPressed: () async {
                                          Get.closeAllSnackbars();
                                          if (isFavorite) {
                                            await box.delete(bookId);
                                          } else {
                                            await box.put(bookId, {
                                              "book":
                                                  bookController.books[index],
                                              "category": category
                                            });
                                          }
                                          Get.snackbar(
                                            "Update",
                                            "Your Favorite List Has Been Updated Successfully!!!",
                                            colorText: Colors.blue,
                                            duration:
                                                const Duration(seconds: 2),
                                            snackPosition: SnackPosition.BOTTOM,
                                          );
                                        },
                                      ),
                                      onTap: () {
                                        Get.to(
                                          () => BookDetailsScreen(
                                              book:
                                                  bookController.books[index]),
                                        );
                                      },
                                    );
                                  },
                                );
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
