// ignore_for_file: non_constant_identifier_names

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
library codemelted_math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// ============================================================================
// [Public API ] ==============================================================
// ============================================================================

/// Wrapper API for the [codemelted_math] library.
class CodeMeltedMath {
  /// Private constructor to form a namespace.
  CodeMeltedMath._() {
    // Make sure we are on a web only platform as that is what this library was
    // designed for.
    if (!kIsWeb) {
      // This module is designed for flutter web only. If somehow this library
      // separated from its parent project and put into a flutter source, go
      // stop the user from doing it.
      throw PlatformException(
        code: "-42",
        message:
            "The codemelted_math library is only supported on web browsers.",
        stacktrace: StackTrace.current.toString(),
      );
    }
  }
}

/// Accesses the [CodeMeltedMath] API to solve complex math formulas.
final codemelted_math = CodeMeltedMath._();
