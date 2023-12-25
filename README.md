<center>
  <a title="Back to Codemelted Developer" href="https://developer.codemelted.com" target="_self"><img style="width: 100%; max-width: 500px;" src="https://developer.codemelted.com/assets/images/logos/developer-non-banner.png" /></a>
  <div style="display: grid; grid-template-columns: auto auto auto auto auto; width: 100%; max-width: 500px;">
    <a title="Raspberry Pi Project" href="https://developer.codemelted.com/codemelted_pi" target="_self"><img style="height: 30px;" src="https://developer.codemelted.com/assets/images/icons/raspberry-pi.png"/></a>
    <a title="Embedded Module" href="https://developer.codemelted.com/codemelted_embedded" target="_self"><img style="height: 30px;" src="https://developer.codemelted.com/assets/images/icons/c.png"/></a>
    <a title="Terminal Module" href="https://developer.codemelted.com/codemelted_terminal" target="_self"><img style="height: 25px;" src="https://developer.codemelted.com/assets/images/icons/powershell.png"/></a>
    <a title="Fullstack Module" href="https://developer.codemelted.com/codemelted_fullstack" target="_self"><img style="height: 30px;" src="https://developer.codemelted.com/assets/images/icons/javascript.png"/></a>
    <a title="Web Module" href="https://developer.codemelted.com/codemelted_web" target="_self"><img style="height: 30px;" src="https://developer.codemelted.com/assets/images/icons/flutter.png"/></a>
  </div>
</center>

<h1> <img style="height: 35px;" src="https://developer.codemelted.com/assets/images/icons/flutter.png" /> CodeMelted Web Module </h1>

Welcome to the **CodeMelted Web Module** project. This project aims to provide a developer with the ability to build a rich Progressive Web Application (PWA) bypassing app stores. It will utilize flutter as the SDK language. This provides a rich widget set to build Single Page Applications (SPA). It also provides full access to the <a href='https://developer.mozilla.org/en-US/docs/Web/API' target='_blank'>Browser Web APIs</a>. This combined with the Flutter SDK will allows developers to build powerful applications in less time then other web based frameworks.

<center>
  <a title="Support My Work" href="#">
  <img id="btnSupport" style="height: 30px;" src="https://developer.codemelted.com/assets/images/icons/bmc-button.png"/>
  </a>
  <p>Please support my work if you find this module useful. Thank you.</p>
</center>

**Table of Contents**

- [Getting started](#getting-started)
- [Usage](#usage)
  - [Error](#error)
  - [Logger](#logger)
- [Other Information](#other-information)
  - [Test Results](#test-results)
  - [Change Log](#change-log)
  - [License](#license)

## Getting started

TBD

## Usage

The following are examples of how this module implements the **CodeMelted Developer** use cases.

### Error

Provides the ability to check on the last use cases execution and gather any errors associated with it.

```dart
// The following demonstrates checking if a use case successfully
// execute. NOTE: this only makes sense for void use case functions.
// Other functions will have a return type that will indicate an error.
if (codemelted.error() != null) {
  // Use case successfully executed.
}
```

### Logger

Provides the logger ability with the module.

```dart
// To set the log_level. Valid data parameter values are
// "debug", "info", "warning", "error", and "off"
codemelted.logger(
  action: "log_level",
  data: "warning",
);

// To set the log_handler. To unassign it, set null for data.
codemelted.logger(
  action: "log_handler",
  data: (record) {
    // Do something with the log record
  },
);

// Now to do actual logging
codemelted.logger(
  action: "log_error",
  data: "Something really bad happened here!",
  st: StackTrace.current,
);
```

## Other Information

### Test Results

<iframe width="100%" height="300" frameBorder="0" src="test_results.txt"></iframe>

### Change Log

**0.2.0 (Last Modified 2023-12-24):**

- Implemented the logger and error use cases.
- Fleshed out testing with browser in flutter. No coverage file. Sad.
- While these are tested, not "releasing" via Getting Started just yet. Want to flesh out more of the module first.

### License

MIT License

© 2023 Mark Shaffer. All Rights Reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

<script src="https://developer.codemelted.com/assets/js/codemelted_channel.js"></script>