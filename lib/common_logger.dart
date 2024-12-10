import "package:logger/logger.dart";

class MyFilter extends LogFilter {
  @override
  bool shouldLog(final LogEvent event) => true;
}

final Logger commonLogger = Logger(filter: MyFilter());
