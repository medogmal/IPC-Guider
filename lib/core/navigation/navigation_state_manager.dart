import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manages navigation state preservation for the app
class NavigationStateManager extends StateNotifier<Map<String, dynamic>> {
  NavigationStateManager() : super({});

  /// Save state for a specific route
  void saveState(String route, Map<String, dynamic> state) {
    state = {
      ...state,
      route: Map<String, dynamic>.from(state),
    };
  }

  /// Get state for a specific route
  Map<String, dynamic>? getState(String route) {
    return state[route] as Map<String, dynamic>?;
  }

  /// Clear state for a specific route
  void clearState(String route) {
    final newState = Map<String, dynamic>.from(state);
    newState.remove(route);
    state = newState;
  }

  /// Clear all saved states
  void clearAllStates() {
    state = {};
  }

  /// Save scroll position for a list
  void saveScrollPosition(String route, double scrollOffset) {
    final routeState = getState(route) ?? {};
    routeState['scrollOffset'] = scrollOffset;
    saveState(route, routeState);
  }

  /// Get scroll position for a list
  double? getScrollPosition(String route) {
    final state = getState(route);
    return state?['scrollOffset'] as double?;
  }

  /// Save search query for a list
  void saveSearchQuery(String route, String query) {
    final routeState = getState(route) ?? {};
    routeState['searchQuery'] = query;
    saveState(route, routeState);
  }

  /// Get search query for a list
  String? getSearchQuery(String route) {
    final state = getState(route);
    return state?['searchQuery'] as String?;
  }

  /// Save filter state for a list
  void saveFilters(String route, Map<String, dynamic> filters) {
    final routeState = getState(route) ?? {};
    routeState['filters'] = filters;
    saveState(route, routeState);
  }

  /// Get filter state for a list
  Map<String, dynamic>? getFilters(String route) {
    final state = getState(route);
    return state?['filters'] as Map<String, dynamic>?;
  }
}

/// Provider for accessing the navigation state manager
final navigationStateProvider = StateNotifierProvider<NavigationStateManager, Map<String, dynamic>>(
  (ref) => NavigationStateManager(),
);

/// Extension for easier access to navigation state
extension NavigationStateExtension on WidgetRef {
  Map<String, dynamic>? getNavigationState(String route) {
    return read(navigationStateProvider.notifier).getState(route);
  }

  void saveNavigationState(String route, Map<String, dynamic> state) {
    read(navigationStateProvider.notifier).saveState(route, state);
  }

  void clearNavigationState(String route) {
    read(navigationStateProvider.notifier).clearState(route);
  }

  void saveScrollPosition(String route, double scrollOffset) {
    read(navigationStateProvider.notifier).saveScrollPosition(route, scrollOffset);
  }

  double? getScrollPosition(String route) {
    return read(navigationStateProvider.notifier).getScrollPosition(route);
  }

  void saveSearchQuery(String route, String query) {
    read(navigationStateProvider.notifier).saveSearchQuery(route, query);
  }

  String? getSearchQuery(String route) {
    return read(navigationStateProvider.notifier).getSearchQuery(route);
  }

  void saveFilters(String route, Map<String, dynamic> filters) {
    read(navigationStateProvider.notifier).saveFilters(route, filters);
  }

  Map<String, dynamic>? getFilters(String route) {
    return read(navigationStateProvider.notifier).getFilters(route);
  }
}
