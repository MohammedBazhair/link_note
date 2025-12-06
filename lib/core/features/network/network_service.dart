import 'dart:async';

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

abstract interface class NetworkService {
  Future<bool> isConnected();
  StreamSubscription<InternetStatus> onStatusChange(
    void Function(InternetStatus)? onData,
  );
}

class NetworkServiceImpl implements NetworkService {
  final InternetConnection _connection;

  NetworkServiceImpl(this._connection);

  @override
  Future<bool> isConnected() => _connection.hasInternetAccess;

  @override
  StreamSubscription<InternetStatus> onStatusChange(
    void Function(InternetStatus)? onData,
  ) {
    return _connection.onStatusChange.listen(onData);
  }
}
