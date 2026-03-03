#!/bin/sh
set -eu

# Xcode Cloud hook: generate the Godot iOS Xcode project before xcodebuild runs.

WORKSPACE_DIR="${CI_PRIMARY_REPOSITORY_PATH:-$(pwd)}"
cd "$WORKSPACE_DIR"

GODOT_VERSION="${GODOT_VERSION:-4.5-stable}"
GODOT_VERSION_DIR="${GODOT_VERSION_DIR:-4.5.stable}"
GODOT_BIN_DIR="$HOME/.cache/godot/${GODOT_VERSION}"
GODOT_BIN="$GODOT_BIN_DIR/Godot.app/Contents/MacOS/Godot"

if [ ! -x "$GODOT_BIN" ]; then
  mkdir -p "$GODOT_BIN_DIR"
  curl -fL "https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}/Godot_v${GODOT_VERSION}_macos.universal.zip" \
    -o "$GODOT_BIN_DIR/godot.zip"
  ditto -x -k "$GODOT_BIN_DIR/godot.zip" "$GODOT_BIN_DIR"
fi

TEMPLATES_ZIP="$GODOT_BIN_DIR/templates.tpz"
if [ ! -f "$TEMPLATES_ZIP" ]; then
  curl -fL "https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}/Godot_v${GODOT_VERSION}_export_templates.tpz" \
    -o "$TEMPLATES_ZIP"
fi

TEMPLATES_DIR="$HOME/Library/Application Support/Godot/export_templates/${GODOT_VERSION_DIR}"
if [ ! -f "$TEMPLATES_DIR/.installed" ]; then
  mkdir -p "$TEMPLATES_DIR"
  ditto -x -k "$TEMPLATES_ZIP" "$TEMPLATES_DIR"
  touch "$TEMPLATES_DIR/.installed"
fi

mkdir -p exports
"$GODOT_BIN" --headless --path "$WORKSPACE_DIR" --export-release "iOS" "exports/zensnake.xcodeproj"

if [ ! -d "exports/zensnake.xcodeproj" ]; then
  echo "Failed to generate exports/zensnake.xcodeproj" >&2
  exit 1
fi

echo "Generated exports/zensnake.xcodeproj for Xcode Cloud"
