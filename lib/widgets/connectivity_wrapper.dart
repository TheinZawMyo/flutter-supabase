import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_supabase/utils/custom_snackbar.dart';
import 'package:flutter_supabase/utils/keys.dart';

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;

  const ConnectivityWrapper({super.key, required this.child});

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  bool _wasOffline = false;
  OverlayEntry? _offlineSnackBarEntry;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure the Navigator and Overlay are ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialConnectivity();
      _isInitialized = true;
    });

    _subscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      if (_isInitialized) {
        _handleConnectivityChange(results);
      }
    });
  }

  Future<void> _checkInitialConnectivity() async {
    final List<ConnectivityResult> results = await Connectivity()
        .checkConnectivity();
    _handleConnectivityChange(results);
  }

  @override
  void dispose() {
    _subscription.cancel();
    _dismissOfflineSnackBar();
    super.dispose();
  }

  void _dismissOfflineSnackBar() {
    if (_offlineSnackBarEntry != null) {
      try {
        if (_offlineSnackBarEntry!.mounted) {
          _offlineSnackBarEntry!.remove();
        }
      } catch (_) {
        // Entry might already be removed
      }
      _offlineSnackBarEntry = null;
    }
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    // ONLY treat as offline if results contains 'none'.
    // An empty list often means the plugin is still initializing or status is indeterminate.
    final bool isOffline = results.contains(ConnectivityResult.none);

    // Try to get overlay from navigatorKey directly to be more robust
    final overlay = navigatorKey.currentState?.overlay;
    if (overlay == null) return;

    if (isOffline) {
      if (!_wasOffline) {
        _dismissOfflineSnackBar();
        // Use a small delay to ensure UI is ready for the overlay
        Future.microtask(() {
          _offlineSnackBarEntry = CustomSnackBar.showWithOverlay(
            overlay: overlay,
            message: 'No Internet Connection',
            type: SnackBarType.error,
            duration: const Duration(days: 1),
          );
        });
        _wasOffline = true;
      }
    } else {
      if (_wasOffline) {
        _dismissOfflineSnackBar();
        Future.microtask(() {
          CustomSnackBar.showWithOverlay(
            overlay: overlay,
            message: 'Back Online',
            type: SnackBarType.success,
            duration: const Duration(seconds: 3),
          );
        });
        _wasOffline = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
