import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// Checked before a network action, so an offline tap fails fast with
/// `AppError.noInternet` instead of waiting on a Firebase timeout.
@lazySingleton
class InternetService {
  Future<bool> check() => InternetConnection().hasInternetAccess;
}
