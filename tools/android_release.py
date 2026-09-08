#!/usr/bin/env python3
"""The build-template plumbing behind `task build-android`.

An Android export does not build the .aab from the Godot binary alone: Godot
unpacks a whole Gradle project into android/ and shells out to it. That
directory is generated, gitignored, and wiped on every reinstall, so nothing in
it can be committed. Anything the build needs there has to be re-applied from
scratch each time - on a dev machine and on a CI runner alike - which is what
this script is for.

The subcommands, in the order the Taskfile runs them:

  install-template  Unpack android_source.zip out of Godot's export templates
                    into android/build. This is exactly what the editor's
                    "Install Android Build Template" menu item does. Godot's
                    --install-android-build-template flag is deliberately not
                    used: it only works alongside an --export-* flag, and on its
                    own it starts the editor and waits forever, which hung the
                    first CI run for 30 minutes.

  patch-template    Raise compileSdk and buildTools in the config.gradle that
                    was just unpacked. The .aab targets Android SDK 37, but the
                    template ships compileSdk 35, and compiling against 37 is
                    not possible yet - that needs AGP 9.x, while Godot still
                    ships AGP 8.6.1 (checked through 4.7.2). So the build
                    compiles against 36 and targets 37, which is the number
                    Play actually enforces. targetSdk itself is not set here;
                    it comes from export_presets.cfg, which Godot passes to
                    Gradle as a property at export time.

  verify            Read the manifest Gradle actually emitted and fail the build
                    if it does not target the expected SDK. The target travels
                    from the export preset through a Gradle property into the
                    merged manifest, and a silent fallback anywhere along that
                    path would otherwise ship a wrongly targeted bundle that
                    looks fine until Play rejects it.

Written in Python rather than sed/grep because neither is on the PATH in a plain
Windows shell, and these commands have to behave identically there and on the
Linux CI runner.

Version numbers are not handled here - see tools/bump_version.py.
"""

import argparse
import io
import os
import re
import shutil
import stat
import sys
import zipfile

ANDROID_DIR = "android"
BUILD_DIR = os.path.join("android", "build")
CONFIG_GRADLE = os.path.join("android", "build", "config.gradle")
MERGED_MANIFEST = os.path.join(
    "android", "build", "build", "intermediates", "merged_manifest",
    "standardRelease", "processStandardReleaseMainManifest", "AndroidManifest.xml",
)


def read(path):
    with io.open(path, encoding="utf-8") as handle:
        return handle.read()


def write(path, text):
    with io.open(path, "w", encoding="utf-8", newline="\n") as handle:
        handle.write(text)


def templates_root():
    """Where the Godot editor keeps its downloaded export templates."""
    override = os.environ.get("GODOT_EXPORT_TEMPLATES")
    if override:
        return override
    if sys.platform == "win32":
        return os.path.join(os.environ["APPDATA"], "Godot", "export_templates")
    if sys.platform == "darwin":
        return os.path.expanduser(
            "~/Library/Application Support/Godot/export_templates"
        )
    return os.path.expanduser("~/.local/share/godot/export_templates")


def resolve_version_dir(root, requested):
    if requested:
        path = os.path.join(root, requested)
        if not os.path.isdir(path):
            sys.exit("No export templates for %s in %s" % (requested, root))
        return requested, path

    if not os.path.isdir(root):
        sys.exit(
            "No export templates found in %s. Install them from the Godot editor "
            "(Editor -> Manage Export Templates)." % root
        )
    installed = sorted(
        name for name in os.listdir(root) if os.path.isdir(os.path.join(root, name))
    )
    if len(installed) != 1:
        sys.exit(
            "Found %d template versions in %s (%s). Pass --godot-version to pick one."
            % (len(installed), root, ", ".join(installed) or "none")
        )
    return installed[0], os.path.join(root, installed[0])


def install_template(args):
    """Unpack Godot's Android build template into android/build.

    This is what the editor's "Install Android Build Template" menu item does.
    Godot's --install-android-build-template flag is not used because it only
    works alongside an --export-* flag; on its own it starts the editor and
    never exits, which hangs a CI runner.
    """
    root = templates_root()
    version, version_dir = resolve_version_dir(root, args.godot_version)
    source_zip = os.path.join(version_dir, "android_source.zip")
    if not os.path.isfile(source_zip):
        sys.exit("No android_source.zip in %s" % version_dir)

    if os.path.isdir(BUILD_DIR):
        shutil.rmtree(BUILD_DIR)
    os.makedirs(BUILD_DIR)

    with zipfile.ZipFile(source_zip) as archive:
        archive.extractall(BUILD_DIR)
        # extractall drops the executable bit, which Linux needs for gradlew.
        for entry in archive.infolist():
            mode = entry.external_attr >> 16
            if mode and not entry.is_dir():
                target = os.path.join(BUILD_DIR, entry.filename)
                if os.path.exists(target):
                    os.chmod(target, stat.S_IMODE(mode))

    # Markers the editor writes so it treats the template as installed.
    write(os.path.join(ANDROID_DIR, ".build_version"), version + "\n")
    open(os.path.join(BUILD_DIR, ".gdignore"), "w").close()

    print("Installed Android build template %s from %s" % (version, source_zip))


def patch_template(args):
    """Re-apply the SDK bump to Godot's generated Android build template.

    Runs after every install-template, since that unpacks a pristine
    config.gradle over the top of any previous patch.
    """
    if not os.path.isfile(CONFIG_GRADLE):
        sys.exit(
            "%s not found - run 'task android-template' first." % CONFIG_GRADLE
        )

    text = read(CONFIG_GRADLE)
    edits = [
        (r"(\n\s*compileSdk\s*:\s*)\d+,", r"\g<1>%s," % args.compile_sdk),
        (r"(\n\s*targetSdk\s*:\s*)\d+,", r"\g<1>%s," % args.target_sdk),
        (r"(\n\s*buildTools\s*:\s*')[^']+',", r"\g<1>%s'," % args.build_tools),
    ]
    for pattern, replacement in edits:
        text, count = re.subn(pattern, replacement, text, count=1)
        if not count:
            sys.exit("Could not apply %r - did the template layout change?" % pattern)

    write(CONFIG_GRADLE, text)
    for line in read(CONFIG_GRADLE).splitlines():
        if re.search(r"(compileSdk|targetSdk|buildTools)\s*:", line):
            print(line.strip())


def verify(args):
    """Assert the manifest the build actually produced targets the right SDK."""
    if not os.path.isfile(MERGED_MANIFEST):
        sys.exit("No merged manifest at %s - build the .aab first." % MERGED_MANIFEST)

    manifest = read(MERGED_MANIFEST)
    found = {}
    for key in ("targetSdkVersion", "minSdkVersion", "versionCode", "versionName"):
        match = re.search(r'%s="([^"]*)"' % key, manifest)
        found[key] = match.group(1) if match else "?"
        print("%s=%s" % (key, found[key]))

    if found["targetSdkVersion"] != args.target_sdk:
        sys.exit(
            "FAIL: built manifest targets SDK %s, expected %s"
            % (found["targetSdkVersion"], args.target_sdk)
        )
    print("OK: targets Android SDK %s" % args.target_sdk)


def main():
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    sub = parser.add_subparsers(dest="command")
    sub.required = True

    p = sub.add_parser("install-template", help="unpack the Android build template")
    p.add_argument(
        "--godot-version",
        help='template version directory, e.g. "4.5.1.stable" '
        "(default: the only one installed)",
    )
    p.set_defaults(func=install_template)

    p = sub.add_parser("patch-template", help="bump SDK versions in config.gradle")
    p.add_argument("--compile-sdk", required=True)
    p.add_argument("--target-sdk", required=True)
    p.add_argument("--build-tools", required=True)
    p.set_defaults(func=patch_template)

    p = sub.add_parser("verify", help="check the built manifest's targetSdkVersion")
    p.add_argument("--target-sdk", required=True)
    p.set_defaults(func=verify)

    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
