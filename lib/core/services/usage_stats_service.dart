import 'package:flutter/foundation.dart';

/// Abstract service for gathering Digital Consumption data (Screen Time, App Usage).
/// Requires platform-specific implementation (e.g., usage_stats plugin on Android).
abstract class UsageStatsService {
  const UsageStatsService();

  /// Requests necessary permissions for accessing usage statistics.
  /// Returns true if permissions are granted.
  Future<bool> requestPermissions();

  /// Fetches aggregated usage data over a specified time range.
  /// Returns data in seconds for consistency.
  Future<int> getTotalScreenTimeSeconds({required Duration range});

  /// Fetches a list of the most used applications/categories.
  Future<List<Map<String, dynamic>>> getTopAppUsage({required int limit});
}

// A concrete, yet to be implemented, provider will consume this.
// For now, we define a placeholder provider factory that expects runtime implementation later.
// Provider will be implemented in Code Mode once logic is ready.
// Example structure: final usageStatsServiceProvider = Provider<UsageStatsService>((ref) => throw UnimplementedError('Service not initialized'));