import 'package:logging/logging.dart';

class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  static Logger? _logger;

  factory LoggerService() {
    return _instance;
  }

  LoggerService._internal();

  void init() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      // You could send logs to a service in production
      // For development, we'll use print but in a controlled way
      // ignore: avoid_print
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
    _logger = Logger('BedApp');
  }

  static void info(String message) {
    _logger?.info(message);
  }

  static void warning(String message) {
    _logger?.warning(message);
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _logger?.severe(message, error, stackTrace);
  }
}
