import 'package:book_finder_app/screens/book_details_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text("Favorite Books")),
        body: ValueListenableBuilder(
          valueListenable: Hive.box('favorite_book_data').listenable(),
          builder: (context, Box box, child) {
            if (box.isEmpty) {
              return const Center(child: Text("No favorite books found."));
            }

            final favoriteKeys = box.keys.toList();

            return ListView.builder(
              itemCount: favoriteKeys.length,
              itemBuilder: (context, index) {
                final String bookId = favoriteKeys[index];
                final Map favoriteData = box.get(bookId);
                final book = favoriteData["book"];
                final favoriteBookData = book["volumeInfo"];
                final title = favoriteBookData["title"] ?? "No Title";

                final imageUrl = favoriteBookData["imageLinks"]?["thumbnail"] ??
                    "https://placehold.co/600x400";
                final category = favoriteData["category"];

                return ListTile(
                  onTap: () {
                    Get.to(
                      () => BookDetailsScreen(book: book),
                    );
                  },
                  title: Text(title),
                  subtitle: Text("Category: $category"),
                  leading: imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.book, size: 25),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.book, size: 25),
                          ),
                        )
                      : const Icon(Icons.book),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () {
                      Get.closeAllSnackbars();
                      box.delete(bookId);
                      Get.snackbar(
                        "Deleted",
                        "Book removed from favorites",
                        colorText: Colors.blue,
                        duration: const Duration(seconds: 2),
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
