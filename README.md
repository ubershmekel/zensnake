# Kat and Noodles

A zen-like, one-button snake toy where you drift in circles, weave figure eights, or twirl with a friend. No score chase, just flow.

## Play

- [Android](https://play.google.com/store/apps/details?id=com.andluck.zensnake)
- [iPhone and iPad](https://apps.apple.com/us/app/kat-and-noodles/id6755672232)
- [Web](https://ubershmekel.itch.io/zensnake)

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
2. Bump Version -> Code.
3. Export Project... to produce the new `.aab`.
4. Go to https://play.google.com/console and create a new release.
5. Upload the `.aab`.
6. Update release notes.
7. Review and approve the release.
