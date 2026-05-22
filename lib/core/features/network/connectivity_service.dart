import 'dart:async';

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../../constants/internal_constants/log.dart';

abstract interface class ConnectivityService {
  Future<bool> hasConnection();
  Stream<bool> onStatusChanged();
}

class ConnectivityServiceImpl implements ConnectivityService {
  ConnectivityServiceImpl(this._connection);
  final InternetConnection _connection;

  @override
  Future<bool> hasConnection() async {
    try {
      return await _connection.hasInternetAccess;
    } on Exception catch (e, st) {
      Logger.log(error: e, stackTrace: st);
      return false;
    }
  }

  @override
  Stream<bool> onStatusChanged() {
    return _connection.onStatusChange.map((status) {
      return status == InternetStatus.connected;
    });
  }
}
