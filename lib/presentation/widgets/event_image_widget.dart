
import 'dart:io';
import 'package:flutter/material.dart';

class EventImageWidget extends StatelessWidget {
  final String? imagePath;
  final double width;
  final double height;
  final bool isEditable;
  final VoidCallback? onTap;

  const EventImageWidget({
    super.key,
    this.imagePath,
    this.width = 150,
    this.height = 200,
    this.isEditable = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEditable ? onTap : null,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF4A90E2).withOpacity(0.3),
              const Color(0xFF6C63FF).withOpacity(0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF6C63FF).withOpacity(0.4),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: imagePath != null
              ? Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                File(imagePath!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholder();
                },
              ),
              if (isEditable)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                  child: const Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
            ],
          )
              : _buildPlaceholder(),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4A90E2).withOpacity(0.2),
            const Color(0xFF6C63FF).withOpacity(0.2),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isEditable ? Icons.add_photo_alternate : Icons.image,
            size: 48,
            color: const Color(0xFFE0E0E0).withOpacity(0.7),
          ),
          if (isEditable) ...[
            const SizedBox(height: 8),
            Text(
              'Dodaj zdjęcie',
              style: TextStyle(
                color: const Color(0xFFE0E0E0).withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
// Na końcu pliku event_image_widget.dart

class EventImageWidgetWithHero extends StatelessWidget {
  final String? imagePath;
  final double width;
  final double height;
  final bool isEditable;
  final VoidCallback? onTap;
  final String? heroTag;

  const EventImageWidgetWithHero({
    super.key,
    this.imagePath,
    this.width = 150,
    this.height = 200,
    this.isEditable = false,
    this.onTap,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final imageWidget = EventImageWidget(
      imagePath: imagePath,
      width: width,
      height: height,
      isEditable: isEditable,
      onTap: onTap,
    );

    if (heroTag != null) {
      return Hero(
        tag: heroTag!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}