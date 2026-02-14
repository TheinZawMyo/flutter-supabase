import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityUtils {
  static Future<bool> hasInternet() async {
    final results = await Connectivity().checkConnectivity();
    // If it explicitly says none, we are offline.
    // Otherwise, we assume we might have a connection (empty often means undetermined on start).
    if (results.contains(ConnectivityResult.none)) return false;
    return true;
  }

  static bool isNoInternetError(dynamic error) {
    final message = error.toString().toLowerCase();
    return message.contains('socketexception') ||
        message.contains('failed host lookup') ||
        message.contains('clientexception');
  }
}
