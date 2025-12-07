import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../error/error_handler.dart';
import '../widgets/loading_indicator.dart';

/// Standardized data loading service for the IPC Guider app
/// Follows the CodeGear-1 protocol for JSON handling and offline-first approach
class DataLoaderService {
  /// Loads JSON data from assets with error handling
  static Future<T?> loadJsonAsset<T>({
    required String path,
    required T Function(Map<String, dynamic>) fromJson,
    String? versionKey,
    String? version,
  }) async {
    try {
      // Load raw JSON data
      final jsonString = await rootBundle.loadString(path);
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;

      // Check version if specified
      if (versionKey != null && version != null) {
        final fileVersion = jsonData[versionKey] as String?;
        if (fileVersion == null) {
          debugPrint('Warning: No version found in $path');
          return null;
        }
        if (fileVersion != version) {
          debugPrint('Warning: Version mismatch in $path. Expected: $version, Found: $fileVersion');
          return null;
        }
      }

      // Parse and return data
      return fromJson(jsonData);
    } catch (e) {
      debugPrint('Error loading JSON from $path: $e');
      return null;
    }
  }

  /// Validates JSON schema
  static bool validateSchema(
    Map<String, dynamic> data,
    Set<String> requiredFields,
  ) {
    for (final field in requiredFields) {
      if (!data.containsKey(field)) {
        debugPrint('Missing required field: $field');
        return false;
      }
    }
    return true;
  }

  /// Provides fallback data when primary data fails to load
  static T provideFallback<T>(
    T Function() fallbackBuilder,
    T? primaryData,
    String assetPath,
  ) {
    if (primaryData != null) {
      return primaryData;
    }

    debugPrint('Using fallback data for $assetPath');
    return fallbackBuilder();
  }

  /// Handles loading states with standardized UI
  static Widget withLoadingState<T>({
    required Future<T> future,
    required Widget Function(T) builder,
    required String assetPath,
    required T Function() fallbackBuilder,
    required String loadingMessage,
    required String errorTitle,
    required String errorMessage,
    required String emptyTitle,
    required String emptyMessage,
    Set<String>? requiredFields,
    String? versionKey,
    String? version,
  }) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingIndicator(message: loadingMessage);
        }

        if (snapshot.hasError) {
          return ErrorHandler.buildErrorWidget(
            context: context,
            title: errorTitle,
            message: '$errorMessage: ${snapshot.error}',
            onRetry: () => withLoadingState(
              future: future,
              builder: builder,
              assetPath: assetPath,
              fallbackBuilder: fallbackBuilder,
              loadingMessage: loadingMessage,
              errorTitle: errorTitle,
              errorMessage: errorMessage,
              emptyTitle: emptyTitle,
              emptyMessage: emptyMessage,
              requiredFields: requiredFields,
              versionKey: versionKey,
              version: version,
            ),
          );
        }

        if (!snapshot.hasData) {
          final fallbackData = fallbackBuilder();
          if (fallbackData == null) {
            return ErrorHandler.buildEmptyWidget(
              context: context,
              title: emptyTitle,
              message: emptyMessage,
              onAction: () => withLoadingState(
                future: future,
                builder: builder,
                assetPath: assetPath,
                fallbackBuilder: fallbackBuilder,
                loadingMessage: loadingMessage,
                errorTitle: errorTitle,
                errorMessage: errorMessage,
                emptyTitle: emptyTitle,
                emptyMessage: emptyMessage,
                requiredFields: requiredFields,
                versionKey: versionKey,
                version: version,
              ),
            );
          }
          return builder(fallbackData);
        }

        final data = snapshot.data!;

        // Validate schema if required fields are specified
        if (requiredFields != null && data is Map<String, dynamic>) {
          if (!validateSchema(data, requiredFields)) {
            return ErrorHandler.buildErrorWidget(
              context: context,
              title: 'Data Format Error',
              message: 'The data file is missing required fields. Please check the data file.',
            );
          }
        }

        return builder(data);
      },
    );
  }
}
