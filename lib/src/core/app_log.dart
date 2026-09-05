import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class AppLog {
  AppLog._();

  static const fileName = 'geotracker.log';
  static const _relativeDir = 'logs';

  static IOSink? _sink;
  static File? _file;
  static Future<void>? _writeQueue;

  static String? get filePath => _file?.path;

  static Future<void> init() async {
    if (_file != null) {
      return;
    }

    try {
      final documents = await getApplicationDocumentsDirectory();
      final dir = Directory(p.join(documents.path, _relativeDir));
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      _file = File(p.join(dir.path, fileName));
      _sink = _file!.openWrite(mode: FileMode.append);
      i('AppLog ready path=${_file!.path}');
    } catch (error, stackTrace) {
      debugPrint('AppLog.init failed: $error\n$stackTrace');
    }
  }

  static void i(String message) => _append('I', message);

  static void w(String message) => _append('W', message);

  static void e(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    final buffer = StringBuffer(message);
    if (error != null) {
      buffer.write(' error=$error');
    }
    if (stackTrace != null) {
      buffer.write('\n$stackTrace');
    }
    _append('E', buffer.toString());
  }

  static Future<bool> share() async {
    final file = _file;
    if (file == null || !await file.exists()) {
      return false;
    }
    final length = await file.length();
    if (length == 0) {
      return false;
    }

    await _flush();
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject: 'Geotracker log',
        text: 'Geotracker field test log',
      ),
    );
    return true;
  }

  static Future<void> clear() async {
    await _flush();
    await _sink?.close();
    _sink = null;
    final file = _file;
    if (file != null && await file.exists()) {
      await file.writeAsString('');
    }
    if (file != null) {
      _sink = file.openWrite(mode: FileMode.append);
      i('AppLog cleared');
    }
  }

  static void _append(String level, String message) {
    final line =
        '[${DateTime.now().toIso8601String()}] $level $message';
    debugPrint(line);

    final sink = _sink;
    if (sink == null) {
      return;
    }

    _writeQueue = (_writeQueue ?? Future<void>.value()).then((_) async {
      try {
        sink.writeln(line);
      } catch (error, stackTrace) {
        debugPrint('AppLog write failed: $error\n$stackTrace');
      }
    });
  }

  static Future<void> _flush() async {
    await _writeQueue;
    await _sink?.flush();
  }
}
