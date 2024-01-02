// ignore_for_file: non_constant_identifier_names
// ignore_for_file: avoid_web_libraries_in_flutter
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

/// Covers the Math use cases for carrying out mathematical formula requests
library codemelted_protocol;

import 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// ============================================================================
// [Data Types] ===============================================================
// ============================================================================

/// Supports the [CProtocolHandler] object to report data, status, and errors
/// with a constructed protocol via [CodeMeltedProtocol] API.
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

/// Handler that is utilized with the [CodeMeltedProtocol] when constructing a
/// protocol to receive [CProtocolEvent] updates.
typedef CProtocolHandler = void Function(CProtocolEvent);

/// Base class for a constructed protocol.
abstract class CProtocol {
  final String id;
  final CProtocolHandler handler;

  CProtocol(this.id, this.handler);

  /// Sends data specific to the given protocol.
  void postMessage([data]);

  /// Terminates the given protocol.
  void terminate();

  /// @nodoc
  void reportError(String ex, StackTrace st) {
    handler(CProtocolEvent(error: ex.toString(), st: st));
    // TODO
    // codemelted.logger(
    //   action: "log_error",
    //   data: e.toString(),
    //   st: StackTrace.current,
    // );
  }
}

/// Supports the [CodeMeltedProtocol.broadcastChannel] function.
class _CBroadcastChannel extends CProtocol {
  // Member Fields:
  late html.BroadcastChannel _channel;

  _CBroadcastChannel(CProtocolHandler handler, String url)
      : super("broadcast_channel", handler) {
    // Create the channel
    _channel = html.BroadcastChannel(url);

    // Listen for events.
    _channel.addEventListener("message", (e) {
      final data = (e as html.MessageEvent).data;
      handler(CProtocolEvent(data: data));
    });
    _channel.addEventListener("messageerror", (e) {
      reportError(e.toString(), StackTrace.current);
    });
  }

  @override
  void postMessage([data]) {
    try {
      _channel.postMessage(data);
    } catch (ex, st) {
      reportError(ex.toString(), st);
    }
  }

  @override
  void terminate() {
    try {
      _channel.close();
    } catch (ex, st) {
      reportError(ex.toString(), st);
    }
  }
}

///
class _CWorker extends CProtocol {
  // Member Fields:
  late html.Worker worker;

  _CWorker(CProtocolHandler handler, String url)
      : super("worker_protocol", handler) {
    var worker = html.Worker(url);
    worker.addEventListener("message", (event) {
      handler(
        CProtocolEvent(data: (event as html.MessageEvent).data),
      );
    });
    worker.addEventListener("messageerror", (event) {
      reportError(event.toString(), StackTrace.current);
    });
    worker.addEventListener("error", (event) {
      reportError(event.toString(), StackTrace.current);
    });
  }

  @override
  void postMessage([data]) {
    try {
      worker.postMessage(data);
    } catch (ex, st) {
      reportError(ex.toString(), st);
    }
  }

  @override
  void terminate() {
    try {
      worker.terminate();
    } catch (ex, st) {
      reportError(ex.toString(), st);
    }
  }
}

// ============================================================================
// [Public API ] ==============================================================
// ============================================================================

/// Wrapper API for the [codemelted_protocol] library.
class CodeMeltedProtocol {
  /// Private constructor to form a namespace.
  CodeMeltedProtocol._() {
    // Make sure we are on a web only platform as that is what this library was
    // designed for.
    if (!kIsWeb) {
      // This module is designed for flutter web only. If somehow this library
      // separated from its parent project and put into a flutter source, go
      // stop the user from doing it.
      throw PlatformException(
        code: "-42",
        message:
            "The codemelted_protocol library is only supported on web browsers.",
        stacktrace: StackTrace.current.toString(),
      );
    }
  }

  /// @nodoc
  CProtocol? audio() {
    return null;
  }

  /// @nodoc
  CProtocol? bluetooth() {
    return null;
  }

  /// Constructs a broadcast_channel protocol to allow for communications
  /// between different pages of a web domain.
  ///
  /// https://developer.mozilla.org/en-US/docs/Web/API/Broadcast_Channel_API
  CProtocol? broadcastChannel(CProtocolHandler handler, String url) {
    try {
      return _CBroadcastChannel(handler, url);
    } catch (ex, st) {
      _logError(ex.toString(), st);
      return null;
    }
  }

  /// @nodoc
  CProtocol? database() {
    return null;
  }

  /// @nodoc
  CProtocol? midi() {
    return null;
  }

  /// @nodoc
  CProtocol? orientation() {
    return null;
  }

  /// @nodoc
  CProtocol? usb() {
    return null;
  }

  /// @nodoc
  CProtocol? webSocket() {
    return null;
  }

  /// @nodoc
  CProtocol? webRTC() {
    return null;
  }

  /// Constructs a worker object to offload work processing into a javascript
  /// file that has a FIFO processor for it to fire back messages when
  /// completed.
  ///
  /// https://developer.mozilla.org/en-US/docs/Web/API/Worker
  CProtocol? worker(CProtocolHandler handler, String url) {
    try {
      return _CWorker(handler, url);
    } catch (ex, st) {
      _logError(ex.toString(), st);
      return null;
    }
  }

  /// Supports the logging of errors when protocol creation fails.
  void _logError(String ex, StackTrace st) {
    // TODO: codemelted.
  }
}

/// Accesses the [CodeMeltedProtocol] API to carry out complex protocols.
final codemelted_protocol = CodeMeltedProtocol._();
