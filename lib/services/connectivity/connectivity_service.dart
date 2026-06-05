import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service to monitor internet connectivity status.
class ConnectivityService {
  final Connectivity _connectivity;
  late final StreamController<bool> _controller;

  ConnectivityService(this._connectivity) {
    _controller = StreamController<bool>.broadcast();
    _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final isConnected = !results.contains(ConnectivityResult.none);
    _controller.add(isConnected);
  }

  Stream<bool> get connectivityStream => _controller.stream;

  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }

  void dispose() {
    _controller.close();
  }
}

/// Provider for [ConnectivityService].
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService(Connectivity());
  ref.onDispose(service.dispose);
  return service;
});

/// Stream provider that emits connectivity status changes.
final connectivityStreamProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.connectivityStream;
});

/// Provider that returns the current connectivity status.
final isConnectedProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(connectivityServiceProvider);
  return service.isConnected;
});
