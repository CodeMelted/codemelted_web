// ignore_for_file: constant_protoIdentifier_names, avoid_web_libraries_in_flutter
/*
===============================================================================
MIT License

© 2023 Mark Shaffer. All Rights Reserved.

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
===============================================================================
*/

/// The implementation of the codemelted_web module project.
library codemelted_web;

// import 'dart:async';
// import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

// ============================================================================
// [About Use Case Types] =====================================================
// ============================================================================

/// Identifies the current version of this module.
String _moduleVersion = "0.2.0 (Last Modified 2023-12-24)";

/// Assists get determining the operating system the progressive web
/// application is running.
String _getOSName() {
  final userAgent = html.window.navigator.userAgent.toLowerCase();
  if (userAgent.contains("android")) {
    return "android";
  } else if (userAgent.contains("ios")) {
    return "ios";
  } else if (userAgent.contains("linux")) {
    return "linux";
  } else if (userAgent.contains("mac")) {
    return "macos";
  } else if (userAgent.contains("windows")) {
    return "windows";
  }

  return "unknown";
}

// ============================================================================
// [Logger Use Case Types] ====================================================
// ============================================================================

/// Identifies the logging level to set with the [CodeMeltedAPI.logger]
/// "level" action.
enum CLogLevel {
  // Enumerations
  off(Level.OFF),
  info(Level.INFO),
  warning(Level.WARNING),
  error(Level.SEVERE),
  debug(Level.FINE);

  // Member Fields:
  final Level level;

  /// Constructor for the enum definition.
  const CLogLevel(this.level);

  /// Utility method to help in retrieving the log level.
  static CLogLevel getCLogLevel(Level level) {
    for (var element in CLogLevel.values) {
      if (element.level == level) {
        return element;
      }
    }
    return CLogLevel.off;
  }
}

/// Wrapper object to provide a consistent log record object between module
/// sdks.
class CLogRecord {
  // Member Fields:
  final LogRecord _record;

  CLogRecord(this._record);

  /// Gets the time of the logged event.
  DateTime get time => _record.time;

  /// Gets the log level associated with the record.
  CLogLevel get level => CLogLevel.getCLogLevel(_record.level);

  /// Gets the message associated with the event.
  String get message => _record.message;

  /// Gets an associated stack trace if one was provided.
  StackTrace? get stackTrace => _record.stackTrace;

  @override
  String toString() {
    var msg = "${_record.time} ${_record.message}";
    msg += _record.stackTrace != null ? "\n${_record.stackTrace}" : "";
    return msg;
  }
}

/// Provides the ability to perform additional processing on logged events
/// handled by this module.
typedef CLoggerHandler = void Function(CLogRecord);

// ============================================================================
// [Public API] ===============================================================
// ============================================================================

/// The main API for the codemelted_web library. It implements the use cases as
/// identified by the https://developer.codemelted.com identifies applicable to
/// this module.
class CodeMeltedAPI {
  // Member Fields:
  String? _error;
  final Logger _logger = Logger("codemelted-logger");
  CLoggerHandler? _onLoggedEvent;

  /// Private constructor to form a namespace.
  CodeMeltedAPI._() {
    // Make sure we are on a web only platform as that is what this library was
    // designed for.
    if (!kIsWeb) {
      // This module is designed for flutter web only. If somehow this library
      // separated from its parent project and put into a flutter source, go
      // stop the user from doing it.
      throw PlatformException(
        code: "-42",
        message: "The codemelted library is only supported on web browsers.",
        stacktrace: StackTrace.current.toString(),
      );
    }

    // Hookup into the flutter runtime error handlers so any error it
    // encounters, is also reported.
    FlutterError.onError = (details) {
      _error = details.exceptionAsString();
      logger(
        action: "log_error",
        data: details.exception,
        st: details.stack,
      );
    };

    PlatformDispatcher.instance.onError = (error, st) {
      _error = error.toString();
      logger(action: "log_error", data: error, st: st);
      return true;
    };

    // Now setup our global logging for the module
    Logger.root.onRecord.listen((v) {
      // Go print the record to console.
      final record = CLogRecord(v);
      if (kDebugMode) {
        print(record.toString());
      }

      // Pass off that same record to a log handler for further processing.
      if (_onLoggedEvent != null) {
        _onLoggedEvent!(record);
      }
    });
  }

  /// Determines information about the browser / operating system you are
  /// running. The supported queryable actions include "argument", "browser",
  /// "eol", "is_desktop", "is_mobile", "module_version", "os", and
  /// "processors". The data types returned are either string, bool, or number
  /// types depending on the actionable query. Null is returned if an error
  /// occurs with the request.
  dynamic about({required String action, String? name}) {
    try {
      _error = null;
      if (action == "argument") {
        final urlParams = html.UrlSearchParams();
        return urlParams.get(name!);
      } else if (action == "browser") {
        final userAgent = html.window.navigator.userAgent.toLowerCase();
        return userAgent.contains("firefox/")
            ? "firefox"
            : userAgent.contains("opr/") || userAgent.contains("presto/")
                ? "opera"
                : userAgent.contains("mobile/") ||
                        userAgent.contains("version/")
                    ? "safari"
                    : userAgent.contains("edg/")
                        ? "edge"
                        : userAgent.contains("chrome/")
                            ? "chrome"
                            : "other";
      } else if (action == "eol") {
        final osName = _getOSName();
        return osName == "windows" ? "\r\n" : "\n";
      } else if (action == "is_desktop") {
        final osName = _getOSName();
        return !osName.contains("android") && !osName.contains("ios");
      } else if (action == "is_mobile") {
        final osName = _getOSName();
        return osName.contains("android") || osName.contains("ios");
      } else if (action == "module_version") {
        return _moduleVersion;
      } else if (action == "os") {
        return _getOSName();
      } else if (action == "processors") {
        return html.window.navigator.hardwareConcurrency!;
      } else {
        throw "codemelted.about: unsupported $action specified.";
      }
    } catch (err, st) {
      _error = err.toString();
      logger(action: "log_error", data: err.toString(), st: st);
      return null;
    }
  }

  /// @nodoc
  int async() {
    return -1;
  }

  /// @nodoc
  int audio() {
    return -1;
  }

  /// @nodoc
  dynamic data() {}

  /// Determines the last error if any encountered by the module. One can
  /// determine use case success by checking `codemelted.error() == null`
  String? error() {
    final err = _error;
    _error = null;
    return err;
  }

  /// Provides a logger so the module can log events as they are
  /// encountered. The supported actions are "log_level", "log_handler",
  /// "log_debug", "log_info", "log_warning", and "log_error". The "log_level"
  /// paired with the data parameter as a string can set a corresponding log
  /// level of "debug", "info", "warning", "error", or off. The "log_handler"
  /// paired with a data parameter of [CLoggerHandler] provide additional
  /// logging processing when encountered. The other actions carry out the log
  /// request where the data and st parameters provide the data to be logged.
  void logger({
    required String action,
    required dynamic data,
    StackTrace? st,
  }) {
    try {
      _error = null;
      if (action == "log_level") {
        Logger.root.level = data.toString() == "debug"
            ? Level.FINE
            : data.toString() == "info"
                ? Level.INFO
                : data.toString() == "warning"
                    ? Level.WARNING
                    : data.toString() == "error"
                        ? Level.SEVERE
                        : Level.OFF;
      } else if (action == "log_handler") {
        _onLoggedEvent = data;
      } else if (action == "log_debug") {
        _logger.fine(data, null, st);
      } else if (action == "log_info") {
        _logger.info(data, null, st);
      } else if (action == "log_warning") {
        _logger.warning(data, null, st);
      } else if (action == "log_error") {
        _logger.severe(data, null, st);
      } else {
        throw "codemelted.logger: unsupported action '$action' specified.";
      }
    } catch (err, st) {
      logger(action: "log_error", data: err.toString(), st: st);
      _error = err.toString();
    }
  }

  /// @nodoc
  List<double> math() {
    return [0.0];
  }

  /// @nodoc
  int network() {
    return -1;
  }

  /// @nodoc
  int peripheral() {
    return -1;
  }

  /// @nodoc
  dynamic runtime() {}

  /// @nodoc
  int storage() {
    return -1;
  }

  /// @nodoc
  Future<dynamic> task() async {
    return null;
  }

  /// @nodoc
  Widget ui() {
    return const Text("not implemented yet");
  }
}

/// Entry point to access the [CodeMeltedAPI] as a namespaced utility object.
final codemelted = CodeMeltedAPI._();
