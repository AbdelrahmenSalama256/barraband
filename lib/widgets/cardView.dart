import 'dart:math';
import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String name; // Name of the category
  final String? image; // Image URL of the category, might be null
  final VoidCallback onTap; // Add a callback for onTap event

  final List<Color> availableColors = [
    const Color(0xffF2C849),
    const Color(0xffF294A5),
    const Color(0xFF78BF45),
    const Color(0xffff6968),
  ];

  CategoryCard({
    required this.name,
    required this.image,
    required this.onTap, // Add required onTap parameter
  });

  @override
  Widget build(BuildContext context) {
    final random = Random(); // For random color assignment
    final randomColor = availableColors[random.nextInt(availableColors.length)];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: randomColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: randomColor.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              image != null && image!.isNotEmpty
                  ? Image.network(
                      image!,
                      width: 90,
                      height: 90,
                      // fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error, size: 50);
                      },
                    )
                  : const Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: Colors.white,
                    ), // Default icon if image is null or empty
              const SizedBox(height: 8),
              Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
