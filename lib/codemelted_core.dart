// ignore_for_file: , avoid_web_libraries_in_flutter
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: unused_element
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

/// Covers the Core use cases for constructing providing queryable actions that
/// return an immediate answer to the request.
library codemelted_core;

import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// ============================================================================
// [Data Types] ===============================================================
// ============================================================================

/// Defines an array definition to match JSON Array construct.
typedef CArray = List<dynamic>;

/// Provides helper methods for the CArray.
extension on CArray {
  /// Converts the JSON object to a string returning null if it cannot
  String? stringify() => jsonEncode(this);
}

/// Event handler to support the [CodeMeltedCore.event] function for
/// processing of browser based HTML events.
typedef CHtmlEventHandler = dynamic Function(html.Event);

/// Identifies the log level of an event encountered by the module.
enum CLogLevel { off, debug, info, warning, error }

/// Support object for the [CLogHandler] to allow for additional processing
/// after the initial logging occurs by the module.
class CLogRecord {
  /// The time of the event
  final DateTime time = DateTime.now();

  /// The log level of the event
  final CLogLevel level;

  /// The message of the event that occurred.
  final dynamic data;

  /// Any associated stack trace if specified.
  final StackTrace? stackTrace;

  CLogRecord(this.level, this.data, this.stackTrace);

  @override
  String toString() {
    var msg = "${time.toIso8601String()} [$level]: $data";
    msg += stackTrace != null ? "\n$stackTrace" : "";
    return msg;
  }
}

/// Provides the ability to perform additional processing on logged events
/// handled by this module.
typedef CLogHandler = void Function(CLogRecord);

/// Defines an object definition to match a valid JSON Object construct.
typedef CObject = Map<String, dynamic>;

/// Provides helper methods for the CObject
extension on CObject {
  /// Converts the JSON object to a string returning null if it cannot.
  String? stringify() => jsonEncode(this);
}

/// Provides a series of asXXX() conversion from a string data type and do non
/// case sensitive compares.
extension on String {
  /// Will attempt to return an array object ir null if it cannot.
  CArray? asArray() {
    try {
      return jsonDecode(this) as CArray?;
    } catch (ex) {
      return null;
    }
  }

  /// Will attempt to convert to a bool from a series of strings that can
  /// represent a true value.
  bool asBool() {
    List<String> trueStrings = [
      "true",
      "1",
      "t",
      "y",
      "yes",
      "yeah",
      "yup",
      "certainly",
      "uh-huh"
    ];
    return trueStrings.contains(toLowerCase());
  }

  /// Will attempt to return a int from the string value or null if it cannot.
  int? asInt() => int.tryParse(this);

  /// Will attempt to return a double from the string value or null if it
  /// cannot.
  double? asDouble() => double.tryParse(this);

  /// Will attempt to return Map<String, dynamic> object or null if it cannot.
  CObject? asObject() {
    try {
      return jsonDecode(this) as CObject?;
    } catch (ex) {
      return null;
    }
  }

  /// Determines if a string is contained within this string.
  bool containsIgnoreCase(String v) => toLowerCase().contains(v.toLowerCase());

  /// Determines if a string is equal to another ignoring case.
  bool equalsIgnoreCase(String v) => toLowerCase() == v.toLowerCase();
}

/// Data object to capture information about the platform your pwa is running.
/// Supports the [CodeMeltedCore.about] property.
class CPlatformInfo {
  // Member Fields:
  final _data = {} as CObject;

  CPlatformInfo._() {
    _data["argument"] = html.UrlSearchParams();
    var userAgent = html.window.navigator.userAgent.toLowerCase();

    _data["browser"] = userAgent.contains("firefox/")
        ? "firefox"
        : userAgent.contains("opr/") || userAgent.contains("presto/")
            ? "opera"
            : userAgent.contains("mobile/") || userAgent.contains("version/")
                ? "safari"
                : userAgent.contains("edg/")
                    ? "edge"
                    : userAgent.contains("chrome/")
                        ? "chrome"
                        : "other";

    final osName = _getOSName();
    _data["os"] = osName;
    _data["eol"] = osName == "windows" ? "\r\n" : "\n";
    _data["is_desktop"] =
        !osName.contains("android") && !osName.contains("ios");
    _data["is_mobile"] = osName.contains("android") || osName.contains("ios");
    _data["processors"] = html.window.navigator.hardwareConcurrency;
  }

  /// Will search for passed items to the progressive web application
  /// via the url.
  String? argument(String name) {
    return (_data["argument"] as html.UrlSearchParams).get(name);
  }

  /// Will identify what browser you are running. Values are firefox, opera,
  /// safari, edge, chrome, or other
  String get browser => _data["browser"].toString();

  /// Determines the new line character for the platform.
  String get eol => _data["eol"].toString();

  /// Determines if your app is running on a desktop or not.
  bool get isDesktop => _data["is_desktop"] as bool;

  /// Determines if your app is running on a mobile or not.
  bool get isMobile => _data["is_mobile"] as bool;

  /// Gets the operating system name you are running on. The name returned
  /// could be android, ios, linux, macos, windows, or other
  String get os => _data["os"].toString();

  /// Identifies the number of processor threads available to allow you for
  /// tasking work on background workers via the protocol library.
  int get processors => _data["processors"] as int;

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

    return "other";
  }
}

// ============================================================================
// [Public API] ===============================================================
// ============================================================================

/// Wrapper API for the [codemelted_core] library.
class CodeMeltedCore {
  // Member Fields:
  final _about = CPlatformInfo._();

  /// Private constructor to form a namespace.
  CodeMeltedCore._() {
    // Make sure we are on a web only platform as that is what this library was
    // designed for.
    if (!kIsWeb) {
      // This module is designed for flutter web only. If somehow this library
      // separated from its parent project and put into a flutter source, go
      // stop the user from doing it.
      throw PlatformException(
        code: "-42",
        message:
            "The codemelted_core library is only supported on web browsers.",
        stacktrace: StackTrace.current.toString(),
      );
    }

    // Hookup into the flutter runtime error handlers so any error it
    // encounters, is also reported.
    FlutterError.onError = (details) {
      log(level: CLogLevel.debug, data: details.exception, st: details.stack);
    };

    PlatformDispatcher.instance.onError = (error, st) {
      log(level: CLogLevel.debug, data: error, st: st);
      return true;
    };
  }

  /// Accesses information about the platform environment you are running.
  CPlatformInfo get about => _about;

  /// Provides the ability to validate or convert data. The actions support
  /// are "has_property", "json_parse", "json_stringify", "is_array",
  /// "is_bool", "is_double", "is_int", "is_object", "is_string",
  /// "is_valid_url", "to_array", "to_bool", "to_double", "to_int",
  /// "to_object", and "to_string".
  ///
  /// The returned value will be a bool for has_ or is_ actions, the data type
  /// of the to_, or a string / [CObject] if a json serialization is being
  /// performed
  dynamic data({required String action, required dynamic data, String? key}) {
    try {
      if (action == "has_property") {
        return (data as CObject).containsKey(key);
      } else if (action == "json_parse") {
        return jsonDecode(data);
      } else if (action == "json_stringify") {
        return jsonEncode(data);
      } else if (action == "is_array") {
        return data is CArray;
      } else if (action == "is_bool") {
        return data is bool;
      } else if (action == "is_double") {
        return data is double;
      } else if (action == "is_int") {
        return data is int;
      } else if (action == "is_object") {
        return data is CObject;
      } else if (action == "isString") {
        return data is String;
      } else if (action == "is_valid_url") {
        return Uri.tryParse(data) != null;
      } else if (action == "to_array") {
        return data.toString().asArray();
      } else if (action == "to_bool") {
        data.toString().asBool();
      } else if (action == "to_double") {
        return data.toString().asDouble();
      } else if (action == "to_int") {
        return data.toString().asInt();
      } else if (action == "to_object") {
        return data.toString().asObject();
      } else if (action == "to_string") {
        return data.toString();
      } else {
        throw "codemelted.data: unsupported action '$action' specified.";
      }
    } catch (ex, st) {
      log(level: CLogLevel.error, data: ex.toString(), st: st);
      return null;
    }
  }

  /// @nodoc
  void event({
    required String action,
    String? type,
    CHtmlEventHandler? handler,
    html.EventTarget? obj,
  }) {
    /// TODO - add use case
    try {
      if (action == "add_event_listener") {
        if (obj == null) {
          html.window.addEventListener(type!, handler!);
        } else {
          obj.addEventListener(type!, handler!);
        }
      } else if (action == "print") {
        html.window.print();
      } else if (action == "remove_event_listener") {
        if (obj == null) {
          html.window.removeEventListener(type!, handler!);
        } else {
          obj.removeEventListener(type!, handler!);
        }
      }
    } catch (ex, st) {
      log(level: CLogLevel.error, data: ex.toString(), st: st);
    }
  }

  /// @nodoc
  dynamic fetch() {}

  /// Identifies the current log level of the module.
  CLogLevel logLevel = CLogLevel.error;

  /// Identified a log handler to utilize for post processing of the event.
  CLogHandler? onLoggedEvent;

  /// Logs events via the module to allow for further development of an
  /// and tracking of events.
  void log({
    required CLogLevel level,
    required dynamic data,
    StackTrace? st,
  }) {
    // See if we meet the logging conditions
    if (logLevel == CLogLevel.off || level.index < logLevel.index) {
      return;
    }

    // We do go process this thing
    final record = CLogRecord(level, data, st);
    switch (level) {
      case CLogLevel.debug:
        html.window.console.debug(record.toString());
        break;
      case CLogLevel.info:
        html.window.console.info(record.toString());
        break;
      case CLogLevel.warning:
        html.window.console.warn(record.toString());
        break;
      case CLogLevel.error:
        html.window.console.error(record.toString());
        break;
      default:
        break;
    }

    // Print to console if in debug mode
    if (kDebugMode) {
      print(record.toString());
    }

    // Now send off for later processing if a handler exists.
    if (onLoggedEvent != null) {
      onLoggedEvent!(record);
    }
  }

  /// @nodoc
  Future<bool> open() async {
    // TODO - add use case.
    return false;
  }

  /// @nodoc
  String? storage() {
    return null;
  }

  /// @nodoc
  Future<dynamic> task() async {
    return null;
  }
}

/// Accesses the [CodeMeltedCore] API to access queryable actions within your
/// application.
final codemelted_core = CodeMeltedCore._();
