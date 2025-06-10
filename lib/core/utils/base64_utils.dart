import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class Base64Utils {
  // Cache to store decoded Base64 strings
  static final Map<String, Uint8List> _cache = {};

  /// Decodes a Base64 string into Uint8List, with caching
  static Uint8List? decodeBase64(String base64String) {
    if (base64String.isEmpty) return null;

    // Check cache first
    if (_cache.containsKey(base64String)) {
      return _cache[base64String];
    }

    try {
      // Handle data URL format (e.g., "data:image/...;base64,")
      String cleanBase64 = base64String;
      if (base64String.contains(',')) {
        cleanBase64 = base64String.split(',').last;
      }

      // Decode and cache the result
      final bytes = base64Decode(cleanBase64);
      _cache[base64String] = bytes;
      return bytes;
    } catch (e) {
      debugPrint('Error decoding Base64 string: $e');
      return null;
    }
  }

  /// Clears the cache (optional, use with caution)
  static void clearCache() {
    _cache.clear();
  }

  /// Removes a specific entry from the cache
  static void removeFromCache(String base64String) {
    _cache.remove(base64String);
  }
}
