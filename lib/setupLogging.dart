import 'package:flutter/foundation.dart';
import 'services/FinampLogsHelper.dart';
import 'package:logging/logging.dart';
import 'package:get_it/get_it.dart';
import 'models/FinampModels.dart';
import 'dart:developer';



void setupLogging() {
  GetIt.instance.registerSingleton(FinampLogsHelper());
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((event) {
    FinampLogsHelper finampLogsHelper = GetIt.instance<FinampLogsHelper>();

    // We don't want to print log messages from the Flutter logger since Flutter prints logs by itself
    if (!kReleaseMode && event.loggerName != "Flutter") {
      log("[${event.loggerName}/${event.level.name}] ${event.time}: ${event.message}");
    }
    finampLogsHelper.addLog(FinampLogRecord.fromLogRecord(event));
  });
}
