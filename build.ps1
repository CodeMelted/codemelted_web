#!/usr/local/bin/pwsh
# =============================================================================
# MIT License
#
# © 2023 Mark Shaffer
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.
# =============================================================================
function build([string[]]$params) {
    # -------------------------------------------------------------------------
    # Constants
    # -------------------------------------------------------------------------
    [string]$PROJ_NAME = "CodeMelted Web Module Build"

    # -------------------------------------------------------------------------
    # Helper Function
    # -------------------------------------------------------------------------
    function message([string]$msg) {
        Write-Host
        Write-Host "MESSAGE: $msg"
        Write-Host
    }

    # -------------------------------------------------------------------------
    # Main Build Script
    # -------------------------------------------------------------------------
    message "Now building $PROJ_NAME"

    message "Setting up the docs directory"
    Remove-Item -Path "docs" -Force -Recurse -ErrorAction Ignore

    message "Running flutter test framework"
    flutter test --platform=chrome
    flutter test --platform=chrome > test_results.txt

    message "Now generating dart doc"
    dart doc --output "docs"
    Move-Item -Path test_results.txt -Destination "docs" -Force

    # Fix the title
    [string]$htmlData = Get-Content -Path "docs/index.html" -Raw
    $htmlData = $htmlData.Replace("codemelted_web - Dart API docs", "CodeMelted - Web Module")
    $htmlData = $htmlData.Replace("https://developer.codemelted.com/codemelted_web/docs", "https://developer.codemelted.com/codemelted_web")
    $htmlData | Out-File docs/index.html -Force

    # Put the right icon
    Copy-Item -Path assets/images/favicon.png -Destination docs/static-assets -Force

    message "$PROJ_NAME build completed."
}
build $args