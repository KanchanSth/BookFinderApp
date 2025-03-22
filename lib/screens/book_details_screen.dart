import 'package:book_finder_app/core/app/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';

class BookDetailsScreen extends StatelessWidget {
  final book;

  const BookDetailsScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    // Extracting book details
    final volumeInfo = book["volumeInfo"];
    final title = volumeInfo["title"] ?? "No Title";
    final authors = volumeInfo["authors"] ?? ["Unknown Author"];
    final publishedDate = volumeInfo["publishedDate"] ?? "Unknown Date";
    final description =
        volumeInfo["description"] ?? "No description available.";
    final imageUrl = volumeInfo["imageLinks"]?["thumbnail"] ??
        "https://placehold.co/600x400"; // Fallback image

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.keyboard_arrow_left, size: 30),
          ),
          title: Text(title),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  height: 180,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.book, size: 50),
                ),
              ),
              hSizedBox1andHalf,
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      vSizedBox0,
                      Text(
                        "By ${authors.join(", ")}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                      vSizedBox0,
                      Text(
                        "Published: $publishedDate",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      vSizedBox1andHalf,
                      Text(
                        description,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
