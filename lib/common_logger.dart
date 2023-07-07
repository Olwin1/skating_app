import 'package:logger/logger.dart';

class MyFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return true;
  }
}

final Logger commonLogger = Logger(filter: MyFilter());
