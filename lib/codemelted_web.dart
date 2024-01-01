// ignore_for_file: constant_protoIdentifier_names,
// ignore_for_file: avoid_web_libraries_in_flutter,
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

/// The implementation of the codemelted_web module project.
library codemelted_web;

// import 'dart:async';
// import 'dart:convert';
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:http/http.dart' as http;

/// Identifies the current version of this module.
String _moduleVersion = "0.2.0 (Last Modified 2023-12-24)";

// ============================================================================
// [Common Types] =============================================================
// ============================================================================

/// Defines an array definition to match JSON Array construct.
typedef CArray = List<dynamic>;

/// Provides helper methods for the CArray.
extension on CArray {
  /// Converts the JSON object to a string returning null if it cannot
  String? stringify() => jsonEncode(this);
}

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

/// Supports the [CProtocolHandler] object to report data, status, and errors
/// with a constructed protocol via [CodeMeltedAPI].
class CProtocolEvent {
  /// Data specific to the protocol constructed.
  final dynamic data;

  /// A change in status with the protocol.
  final String? status;

  /// An encountered error with the protocol.
  final String? error;

  /// Where the error was detected with the protocol.
  final StackTrace? st;

  CProtocolEvent({this.data, this.status, this.error, this.st});
}

/// Handler that is utilized with the [CodeMeltedAPI] when constructing a
/// protocol to receive [CProtocolEvent] updates.
typedef CProtocolHandler = void Function(CProtocolEvent);

/// Base class for a constructed protocol.
abstract class _CProtocol {
  // Member Fields:
  final int id;
  final String protocol;
  final CProtocolHandler handler;

  _CProtocol(this.id, this.protocol, this.handler);

  /// Sends data specific to the given protocol.
  void postMessage([data]);

  /// Terminates the given protocol.
  void terminate();
}

// ============================================================================
// [About Use Case Types] =====================================================
// ============================================================================

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
// [Network Use Case Types] ===================================================
// ============================================================================

/// Sets up a broadcast channel to allow different web pages to communicate
/// with one an other.
///
/// https://developer.mozilla.org/en-US/docs/Web/API/Broadcast_Channel_API
class _CBroadcastChannel extends _CProtocol {
  // Member Fields:
  late html.BroadcastChannel _channel;

  _CBroadcastChannel(int id, CProtocolHandler handler, String url)
      : super(id, "broadcast_channel", handler) {
    // Create the channel
    _channel = html.BroadcastChannel(url);

    // Listen for events.
    _channel.addEventListener("message", (e) {
      final data = (e as html.MessageEvent).data;
      handler(CProtocolEvent(data: data));
    });
    _channel.addEventListener("messageerror", (e) {
      handler(CProtocolEvent(error: e.toString(), st: StackTrace.current));
      codemelted.logger(
        action: "log_error",
        data: e.toString(),
        st: StackTrace.current,
      );
    });
  }

  @override
  void postMessage([data]) {
    try {
      _channel.postMessage(data);
    } catch (ex, st) {
      handler(CProtocolEvent(error: ex.toString(), st: st));
      codemelted.logger(action: "log_debug", data: ex, st: st);
    }
  }

  @override
  void terminate() {
    try {
      _channel.close();
    } catch (ex, st) {
      handler(CProtocolEvent(error: ex.toString(), st: st));
      codemelted.logger(action: "log_debug", data: ex, st: st);
    }
  }
}

/// Sets up a network fetch to a REST API specified by the URL. This will then
/// allow for delete, get, put, and post actions to be carried out with the
/// REST API specified by the URL.
class _CNetworkFetch extends _CProtocol {
  // Member Fields:
  final String url;

  _CNetworkFetch(int id, CProtocolHandler handler, this.url)
      : super(id, "network_fetch($url)", handler);

  @override
  void postMessage([data]) async {
    try {
      // Setup the given request
      const duration = Duration(seconds: 10);
      final action = (data as CObject)["action"].toString();
      final headers = ((data)["headers"] as Map<String, String>?);
      final body = ((data)["body"] as Object?);
      http.Response resp;
      var uri = Uri.parse(url);

      // Determine the action we will be carrying out.
      if (action == "get") {
        resp = await http.get(uri).timeout(duration);
      } else if (action == "delete") {
        resp = await http
            .delete(uri, headers: headers, body: body)
            .timeout(duration);
      } else if (action == "put") {
        resp = await http
            .put(
              uri,
              headers: headers,
              body: body,
            )
            .timeout(duration);
      } else if (action == "post") {
        resp = await http
            .post(uri, headers: headers, body: body)
            .timeout(duration);
      } else {
        throw "codemelted.network: $action is not supported with fetch "
            "protocol";
      }

      // Now form the received data and report it.
      final status = resp.statusCode;
      final statusText = resp.reasonPhrase ?? "";
      dynamic responseData;
      String contentType = resp.headers["content-type"].toString();
      if (contentType.containsIgnoreCase('plain/text') ||
          contentType.containsIgnoreCase('text/html')) {
        responseData = resp.body;
      } else if (contentType.containsIgnoreCase('application/json')) {
        responseData = jsonDecode(resp.body);
      } else if (contentType.containsIgnoreCase('application/octet-stream')) {
        responseData = resp.bodyBytes;
      }

      handler(CProtocolEvent(data: {
        "data": responseData,
        "status": status,
        "statusText": statusText,
      }));
    } on TimeoutException {
      handler(CProtocolEvent(status: "Request Timeout"));
    } catch (ex, st) {
      handler(CProtocolEvent(error: ex.toString(), st: st));
      codemelted.logger(action: "log_debug", data: ex, st: st);
    }
  }

  @override
  void terminate() {
    // Does nothing
  }
}

// class _CClientWebSocket extends _CProtocol {
//   @override
//   void postMessage([data]) {
//     // TODO: implement postMessage
//   }

//   @override
//   void terminate() {
//     // TODO: implement terminate
//   }
// }

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
  int _protoId = 0;
  final _protoMap = <int, _CProtocol>{};

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
  /// running. The supported queries include "argument", "browser",
  /// "eol", "is_desktop", "is_mobile", "module_version", "os", and
  /// "processors". The data types returned are either string, bool, or number
  /// types depending on the actionable query. Null is returned if an error
  /// occurs with the request.
  dynamic about({required String query, String? name}) {
    try {
      _error = null;
      if (query == "argument") {
        final urlParams = html.UrlSearchParams();
        return urlParams.get(name!);
      } else if (query == "browser") {
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
      } else if (query == "eol") {
        final osName = _getOSName();
        return osName == "windows" ? "\r\n" : "\n";
      } else if (query == "is_desktop") {
        final osName = _getOSName();
        return !osName.contains("android") && !osName.contains("ios");
      } else if (query == "is_mobile") {
        final osName = _getOSName();
        return osName.contains("android") || osName.contains("ios");
      } else if (query == "module_version") {
        return _moduleVersion;
      } else if (query == "os") {
        return _getOSName();
      } else if (query == "processors") {
        return html.window.navigator.hardwareConcurrency!;
      } else {
        throw "codemelted.about: unsupported $query specified.";
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

  /// Creates the supported client side network based protocols available in a
  /// web browser environment. The supported protocol actions are
  /// "create_broadcast_channel", "create_network_fetch", and
  /// "create_client_web_socket". The url parameter specifies where to make a
  /// connection for the fetch / web socket. For the broadcast channel it
  /// represents the name all web pages will use on that channel. The other
  /// supported actions are "post" and "terminate" for transmitting data and
  /// terminating the protocol.
  int network({
    required String action,
    required CProtocolHandler handler,
    String? url,
    dynamic data,
    int? protoId,
  }) {
    try {
      if (action == "create_broadcast_channel") {
        _protoId += 1;
        _protoMap[_protoId] = _CBroadcastChannel(_protoId, handler, url!);
      } else if (action == "create_network_fetch") {
        _protoId += 1;
        _protoMap[_protoId] = _CNetworkFetch(_protoId, handler, url!);
      } else if (action == "post") {
        _protoMap[protoId!]!.postMessage(data);
      } else if (action == "terminate") {
        _protoMap[protoId!]!.terminate();
        _protoMap.remove(protoId);
      } else {
        throw "codemelted.network: unsupported action '$action' specified.";
      }
    } catch (ex, st) {
      _protoId -= 1;
      logger(action: "log_error", data: ex, st: st);
      return -1;
    }

    return _protoId;
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
