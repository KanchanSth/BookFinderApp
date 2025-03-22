import 'package:connectivity_plus/connectivity_plus.dart';

Future<bool> checkInternetStatus() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  return connectivityResult.contains(ConnectivityResult.mobile) ||
      connectivityResult.contains(ConnectivityResult.wifi);
}
