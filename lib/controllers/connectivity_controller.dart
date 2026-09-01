import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  final isConnected = true.obs;
  StreamSubscription<dynamic>? _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _checkInitialConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(dynamic result) {
    if (result is List<ConnectivityResult>) {
      isConnected.value = result.any((element) => element != ConnectivityResult.none);
    } else if (result is ConnectivityResult) {
      isConnected.value = result != ConnectivityResult.none;
    } else if (result is List) {
      isConnected.value = result.any((element) => element != ConnectivityResult.none);
    }
  }

  Future<bool> checkCurrentConnection() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
    return isConnected.value;
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }
}
