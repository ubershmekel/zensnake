#!/usr/bin/env python3
"""The one place the game's version is bumped, for both iOS and Android.

There is a single number to think about: config/version in project.godot.
Everything else is derived from it, so iOS and Android can never drift apart.

  project.godot       config/version   e.g. "1.0.8". The user-visible version
                                       on both stores. Android's version/name
                                       and iOS's short_version/version are all
                                       left blank in export_presets.cfg, so
                                       both platforms inherit this one string.

  export_presets.cfg  version/code     Android's internal build number. Google
                                       Play requires a plain integer that goes
                                       up every upload, so it cannot just be
                                       "1.0.8". It is computed from the version
                                       above rather than counted separately:

                                           major * 10000 + minor * 100 + patch

                                       1.0.8  -> 10008
                                       1.0.9  -> 10009
                                       1.1.0  -> 10100
                                       2.0.0  -> 20000

                                       So the code is readable straight back as
                                       the version, and it always increases as
                                       long as the version does. iOS needs no
                                       equivalent: Xcode Cloud manages its own
                                       build number.

Usage:
    python tools/bump_version.py                 # 1.0.8 -> 1.0.9, code 10009
    python tools/bump_version.py --part minor    # 1.0.8 -> 1.1.0, code 10100
    python tools/bump_version.py --part none     # recompute the code only
"""

import argparse
import io
import re
import sys

PROJECT_GODOT = "project.godot"
EXPORT_PRESETS = "export_presets.cfg"

# Room for 99 minor and 99 patch releases between bumps of the part above.
MINOR_STRIDE = 100
MAJOR_STRIDE = 10000


def read(path):
    with io.open(path, encoding="utf-8") as handle:
        return handle.read()


def write(path, text):
    with io.open(path, "w", encoding="utf-8", newline="\n") as handle:
        handle.write(text)


def version_code_for(major, minor, patch):
    if minor >= MINOR_STRIDE or patch >= MINOR_STRIDE:
        sys.exit(
            "Version %d.%d.%d overflows the version/code scheme (minor and patch "
            "must stay under %d). Bump the part above instead."
            % (major, minor, patch, MINOR_STRIDE)
        )
    return major * MAJOR_STRIDE + minor * MINOR_STRIDE + patch


def next_config_version(part):
    """Read config/version and work out what it should become. No writes."""
    text = read(PROJECT_GODOT)
    match = re.search(r'(?m)^config/version="([^"]*)"$', text)
    if not match:
        sys.exit('No \'config/version="..."\' line in %s' % PROJECT_GODOT)

    current = match.group(1)
    pieces = current.split(".")
    if len(pieces) != 3 or not all(piece.isdigit() for piece in pieces):
        sys.exit(
            "config/version is %r; expected three numbers like 1.0.8. "
            "Fix it by hand this once." % current
        )

    major, minor, patch = (int(piece) for piece in pieces)
    if part == "major":
        major, minor, patch = major + 1, 0, 0
    elif part == "minor":
        minor, patch = minor + 1, 0
    elif part == "patch":
        patch += 1

    following = "%d.%d.%d" % (major, minor, patch)
    replaced = "%s%s%s" % (text[: match.start(1)], following, text[match.end(1) :])
    return current, following, (major, minor, patch), replaced


def next_version_code(code):
    """Check the new code against the current one. No writes."""
    text = read(EXPORT_PRESETS)
    match = re.search(r"(?m)^version/code=(\d+)$", text)
    if not match:
        sys.exit("No 'version/code=' line in %s" % EXPORT_PRESETS)

    current = int(match.group(1))
    if code < current:
        sys.exit(
            "Refusing to move version/code backwards (%d -> %d). Google Play "
            "rejects an upload whose code is not higher than the last one."
            % (current, code)
        )

    replaced = "%s%d%s" % (text[: match.start(1)], code, text[match.end(1) :])
    return current, code, replaced


def main():
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument(
        "--part",
        choices=("major", "minor", "patch", "none"),
        default="patch",
        help="which part of config/version to increment, or 'none' to leave the "
        "version alone and just recompute version/code (default: patch)",
    )
    args = parser.parse_args()

    # Work everything out and validate it before touching either file, so a
    # rejected bump cannot leave the version and the code disagreeing.
    was, now, pieces, godot_text = next_config_version(args.part)
    was_code, now_code, presets_text = next_version_code(version_code_for(*pieces))

    write(PROJECT_GODOT, godot_text)
    write(EXPORT_PRESETS, presets_text)

    print("%-18s config/version: %s -> %s" % (PROJECT_GODOT, was, now))
    print("%-18s version/code:   %d -> %d" % (EXPORT_PRESETS, was_code, now_code))


if __name__ == "__main__":
    main()
