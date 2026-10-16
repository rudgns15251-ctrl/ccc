# Release UI candidates — sources and licenses

Downloaded 2026-10-16 with user approval. Contents copied unchanged from the archives below; `.url` web shortcuts from the Kenney zips were left out. **Not connected to the game yet**: this folder has a `.gdignore`, so Godot neither imports nor exports it. Remove the `.gdignore` (or copy chosen files elsewhere) when a sound or icon is actually wired in, and add it to the in-game credits then.

| Folder | Source | Version / archive (SHA-256) | License | Contents |
|---|---|---|---|---|
| `sfx/owlish_click_clips/` | "87 Clickety Clips" by OwlishMedia — https://opengameart.org/content/87-clickety-clips | `Click_Clips.zip` 3,791,043 B (`48a6d389…cd9884`) | **CC0 1.0**, as stated on the OpenGameArt page (the zip contains no license file) | 87 WAV clicks, snaps, switches, button pushes |
| `sfx/kenney_ui_audio/` | "UI Audio" by Kenney — https://kenney.nl/assets/ui-audio | `kenney_ui-audio.zip` 411,949 B (`946fc23a…1d5eb6`) | **CC0 1.0** (`License.txt`; credit optional) | 50 OGG UI clicks/switches + preview |
| `sfx/kenney_interface_sounds/` | "Interface Sounds" 1.0 by Kenney — https://kenney.nl/assets/interface-sounds | `kenney_interface-sounds.zip` 834,536 B (`f2193d07…c81232`) | **CC0 1.0** (`License.txt`; credit optional) | 100 OGG interface sounds |
| `icons/tabler_3.48.0/` | Tabler Icons by Paweł Kuna — npm `@tabler/icons@3.48.0` (2026-09-22), https://tabler.io/icons | `icons-3.48.0.tgz` 1,257,051 B (`28447dcf…68f449`) | **MIT** (`LICENSE`; keep the notice in credits/licenses when shipped) | 5,166 outline + 1,054 filled SVG (24×24, 2 px stroke) |

Full SHA-256 values:
- `Click_Clips.zip` 48a6d38931a5a388961b52aebedc9724193dd5aca1b3f13a7d63f66a24cd9884
- `kenney_ui-audio.zip` 946fc23a63d535d693eb31b2eabb80c8c28d6351e2186b344ceb71b2cb1d5eb6
- `kenney_interface-sounds.zip` f2193d072726d6758a5f7871b2dcc54dcce0d5c35c6f0a62f92549b327c81232
- `icons-3.48.0.tgz` 28447dcf6f0bb2b8d92c59a1b3d30900a180de2e97d7db4d267e6320dc68f449

Notes:
- Tabler 3.49.0 was the newest release but only 11 days old with no release files, so the 3.48.0 npm package was used.
- These are first-pass candidates. The Kenney sets are clean digital UI sounds; for the era-appropriate mechanical feel, expect to pick from the Clickety Clips first and possibly process (EQ, room tone) before use.
