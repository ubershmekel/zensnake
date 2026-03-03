# Kat and Noodles

A zen-like, one-button snake toy where you drift in circles, weave figure eights, or twirl with a friend. No score chase, just flow.

## Play

- [Android](https://play.google.com/store/apps/details?id=com.andluck.zensnake)
- [iPhone](https://apps.apple.com/us/app/kat-and-noodles/id6755672232)
- [Web](https://ubershmekel.itch.io/zensnake) (older version)
- [Install the app on android or iphone](https://ubershmekel.github.io/zensnake/app/)

## Highlights

- Single-button steering; the snake lazily curves on its own and pressing or holding arcs the other way.
- Screen wraps endlessly with no walls or fail state; this is about motion and rhythm, not pressure.
- Fruits change the vibe: some glide smoothly, others hop in chunky steps; all make you longer.
- Couch and pocket friendly: play on touch or keyboard, with a two-player mode on the same screen.

## Controls

- Keyboard: Player 1 toggles turn direction with `A`; Player 2 with `B`.
- Touch: 1P tap or hold anywhere to turn left. 2P tap the left/right screen edges as your buttons.
- Eating fruit happens automatically as you cross it.

## Modes

- Solo drift.
- Local two-player share-the-screen.

## How it feels

Start in a slow spiral, then chase fruit that stretch the body and swap the movement style. The playfield loops endlessly, so you keep sketching ribbons and rhythms: more a fidget toy than score grind.

## Development

- Engine: Godot 4 (see `export_presets.cfg` for export templates).
- Run locally: open the project in Godot and press Play (F5).
- Exports: Web, Android, iOS; ensure templates are installed.

### Android release checklist

1. Godot: Project -> Export -> Android (Runnable).
1. Bump Version -> Code.
1. Export Project... to produce the new `.aab`.
1. Go to https://play.google.com/console -> Test and release -> Production -> Create new release.
1. Upload the `.aab`.
1. Update release notes.
1. Review and approve the release.

### iOS release checklist

### Xcode Cloud setup for iOS

Xcode Cloud machines do not include Godot by default, so the `.xcodeproj` must be generated in CI before `xcodebuild` starts.

1. Keep the iOS export preset configured as **Export as Xcode project** (`application/export_project_only=true`).
1. Commit `ci_scripts/ci_post_clone.sh` (Xcode Cloud automatically runs this hook).
1. In Xcode Cloud, point the workflow to `exports/zensnake.xcodeproj` + scheme `zensnake`.
1. Optional: set `GODOT_VERSION` and `GODOT_VERSION_DIR` env vars in the workflow if you upgrade Godot.

The post-clone hook installs Godot + export templates, then runs headless export:

```bash
./ci_scripts/ci_post_clone.sh
```


1. Godot: Project → Project Settings → Application → Config. Bump version.
1. Godot: Project -> Export -> iOS (Runnable).
1. Export Project... to produce the `exports/zensnake.xcodeproj`.
1. Open `exports/zensnake.xcodeproj`.
1. Product -> Archive
1. Distribute App -> App Store Connect -> Distribute
1. Wait 4 minutes, you can now test the new version on TestFlight
1. Go to https://appstoreconnect.apple.com/login
1. Click the little blue plus under iOS app, name the version
1. Add Build
1. Edit "What's New in This Version"
1. Save
1. Add for Review
1. Submit for Review
