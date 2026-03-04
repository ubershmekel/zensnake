#!/bin/sh
set -eu

# Safety net for Xcode Cloud: ensure the Godot iOS Xcode project exists right
# before xcodebuild starts (including dependency resolution).

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
"$SCRIPT_DIR/ci_post_clone.sh"
