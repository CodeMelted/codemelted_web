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

// ============================================================================
// [ Mocks ] ==================================================================
// ============================================================================

// ============================================================================
// [ Tests ] ==================================================================
// ============================================================================

import 'package:codemelted_web/codemelted_web.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // group("codemelted.logger() Tests", () {
  //   test("codemelted.logger() Error Demo", () {
  //     expect(codemelted.error(), isNull);
  //     codemelted.logger(action: "duh", data: "duh");
  //     expect(codemelted.error(), isNotNull);
  //   });

  //   test("codemelted.logger() Success Demo", () {
  //     // Setup our log handler
  //     var count = 0;
  //     logHandler(rec) {
  //       count += 1;
  //     }

  //     // Setup to log some events
  //     expect(codemelted.error(), isNull);
  //     codemelted.logger(action: "log_level", data: "warning");
  //     codemelted.logger(action: "log_handler", data: logHandler);
  //     codemelted.logger(
  //       action: "log_debug",
  //       data: "debug",
  //       st: StackTrace.current,
  //     );
  //     codemelted.logger(
  //       action: "log_info",
  //       data: "info",
  //       st: StackTrace.current,
  //     );
  //     codemelted.logger(
  //       action: "log_warning",
  //       data: "warning",
  //       st: StackTrace.current,
  //     );
  //     codemelted.logger(
  //       action: "log_error",
  //       data: "error",
  //       st: StackTrace.current,
  //     );
  //     expect(count, 2);
  //     expect(codemelted.error(), isNull);

  //     // Now setup to log all events
  //     codemelted.logger(action: "log_level", data: "debug");
  //     codemelted.logger(
  //       action: "log_debug",
  //       data: "debug",
  //       st: StackTrace.current,
  //     );
  //     codemelted.logger(
  //       action: "log_info",
  //       data: "info",
  //       st: StackTrace.current,
  //     );
  //     codemelted.logger(
  //       action: "log_warning",
  //       data: "warning",
  //       st: StackTrace.current,
  //     );
  //     codemelted.logger(
  //       action: "log_error",
  //       data: "error",
  //       st: StackTrace.current,
  //     );
  //     expect(count, 6);
  //     expect(codemelted.error(), isNull);
  //   });
  // });
}
