import 'package:flutter/material.dart';

/// A robust network image widget that:
/// - Sends a browser-like User-Agent to bypass hotlink protection
/// - Shows a shimmer-style loading placeholder
/// - Shows a fallback icon if the image fails to load
class AnimalNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const AnimalNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final image = Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      headers: const {
        // Mimics a real browser request — bypasses most hotlink protection
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Referer': 'https://www.google.com/',
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildPlaceholder();
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildErrorFallback();
      },
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFECE5D8),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2E7D32),
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildErrorFallback() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFECE5D8),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported, color: Color(0xFF2E7D32), size: 36),
          SizedBox(height: 6),
          Text(
            'Image unavailable',
            style: TextStyle(fontSize: 11, color: Colors.black45),
          ),
        ],
      ),
    );
  }
}