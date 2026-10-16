# Release UI candidates — sources and licenses

Downloaded 2026-10-16 with user approval. Contents copied unchanged from the archives below; `.url` web shortcuts from the Kenney zips were left out. **Not connected to the game yet**: this folder has a `.gdignore`, so Godot neither imports nor exports it. Remove the `.gdignore` (or copy chosen files elsewhere) when a sound or icon is actually wired in, and add it to the in-game credits then.

| Folder | Source | Version / archive (SHA-256) | License | Contents |
|---|---|---|---|---|
| `sfx/owlish_click_clips/` | "87 Clickety Clips" by OwlishMedia — https://opengameart.org/content/87-clickety-clips | `Click_Clips.zip` 3,791,043 B (`48a6d389…cd9884`) | **CC0 1.0**, as stated on the OpenGameArt page (the zip contains no license file) | 87 WAV clicks, snaps, switches, button pushes |
| `sfx/kenney_ui_audio/` | "UI Audio" by Kenney — https://kenney.nl/assets/ui-audio | `kenney_ui-audio.zip` 411,949 B (`946fc23a…1d5eb6`) | **CC0 1.0** (`License.txt`; credit optional) | 50 OGG UI clicks/switches + preview |
| `sfx/kenney_interface_sounds/` | "Interface Sounds" 1.0 by Kenney — https://kenney.nl/assets/interface-sounds | `kenney_interface-sounds.zip` 834,536 B (`f2193d07…c81232`) | **CC0 1.0** (`License.txt`; credit optional) | 100 OGG interface sounds |
| `icons/tabler_3.48.0/` | Tabler Icons by Paweł Kuna — npm `@tabler/icons@3.48.0` (2026-09-22), https://tabler.io/icons | `icons-3.48.0.tgz` 1,257,051 B (`28447dcf…68f449`) | **MIT** (`LICENSE`; keep the notice in credits/licenses when shipped) | 5,166 outline + 1,054 filled SVG (24×24, 2 px stroke) |

## Materials (`materials/`) — downloaded 2026-10-16 with user approval

Only the colour / diffuse map of each material is kept here (other PBR maps are not used by the 2D UI and stay out of the project). Files are unmodified; the theme builder derives tinted UI panels from them into `assets/ui/release/`.

| File | Source | License | SHA-256 |
|---|---|---|---|
| `green_metal_rust_diff_1k.jpg` | Poly Haven "Green Metal Rust" — https://polyhaven.com/a/green_metal_rust (Diffuse 1k) | **CC0 1.0** (https://polyhaven.com/license) | 4509ab0cb1cf6bf9… |
| `metal_plate_02_diff_1k.jpg` | Poly Haven "Metal Plate 02" — https://polyhaven.com/a/metal_plate_02 (Diffuse 1k) | **CC0 1.0** | 6e80877d0e9d5973… |
| `Metal046B_1K-JPG_Color.jpg` | ambientCG "Metal 046 B" — https://ambientcg.com/view?id=Metal046B (zip SHA-256 b4fc855a414f7a1e…) | **CC0 1.0** (https://docs.ambientcg.com/license/) | 7caf8ddbd06aa730… |
| `Paper001_1K-JPG_Color.jpg` | ambientCG "Paper 001" — https://ambientcg.com/view?id=Paper001 (zip SHA-256 5be094ffad8a6343…) | **CC0 1.0** | e8db6f5b91f7882f… |
| `PaintedMetal016_1K-JPG_Color.jpg` | ambientCG "Painted Metal 016" — https://ambientcg.com/view?id=PaintedMetal016 (zip SHA-256 3ec5a85ceb270ace…) | **CC0 1.0** | 5eddcfa0d2b7ba5b… |
| `PaintedMetal012_1K-JPG_Color.jpg` | ambientCG "Painted Metal 012" — https://ambientcg.com/view?id=PaintedMetal012 (zip SHA-256 39ceb8cb9a6a57f3…) | **CC0 1.0** | 5bbf442ed1e1d9f8… |

Material SHA-256 (full):
- green_metal_rust_diff_1k.jpg 4509ab0cb1cf6bf9b9f970450a41f83ebd9bff178006deae568ff34b404856fc
- metal_plate_02_diff_1k.jpg 6e80877d0e9d5973d96298c6091df7ace906b0a6760afc4f3592e4855f3f1d4c
- Metal046B_1K-JPG_Color.jpg 7caf8ddbd06aa730e41db993ff344eb60d872ff698e5da117b3527f09ba1877e
- Paper001_1K-JPG_Color.jpg e8db6f5b91f7882f4711ab5b2dc5c2e91f822d4f80a7d0081991532cf5cd9b9a
- PaintedMetal016_1K-JPG_Color.jpg 5eddcfa0d2b7ba5beab8d5c2e43b893d1784a6e1911da10f3a5447082df77767
- PaintedMetal012_1K-JPG_Color.jpg 5bbf442ed1e1d9f825ed7794102f37d5a5a6e81c7cefd58c4300770c2b18339a

Full SHA-256 values:
- `Click_Clips.zip` 48a6d38931a5a388961b52aebedc9724193dd5aca1b3f13a7d63f66a24cd9884
- `kenney_ui-audio.zip` 946fc23a63d535d693eb31b2eabb80c8c28d6351e2186b344ceb71b2cb1d5eb6
- `kenney_interface-sounds.zip` f2193d072726d6758a5f7871b2dcc54dcce0d5c35c6f0a62f92549b327c81232
- `icons-3.48.0.tgz` 28447dcf6f0bb2b8d92c59a1b3d30900a180de2e97d7db4d267e6320dc68f449

Notes:
- Tabler 3.49.0 was the newest release but only 11 days old with no release files, so the 3.48.0 npm package was used.
- These are first-pass candidates. The Kenney sets are clean digital UI sounds; for the era-appropriate mechanical feel, expect to pick from the Clickety Clips first and possibly process (EQ, room tone) before use.

## BigSoundBank originals (`sfx/bigsoundbank/`) — downloaded 2026-10-16 with user approval

Unmodified WAV originals from https://bigsoundbank.com (Joseph Sardin), each from `https://bigsoundbank.com/UPLOAD/bwf-en/<id>.wav`. Every page is marked "Free and Royalty Free" — **CC0 1.0** (https://bigsoundbank.com/licenses.html; credit optional). Game-ready cuts are made by `tools/build_release_sfx.gd` into `assets/ui/release/sfx/` (see that folder's README).

| ID | Sound | Used as |
|---|---|---|
| 2212 / 2210 / 0164 | Pages that turn #5 / #3, Turned page | doc_page_a / doc_page_b / report_open |
| 3061 / 3063 | Industrial switch #1 / #3 | switch_heavy / switch_light |
| 0540 / 0026 | Old switch, Electric switch | (candidates, not cut) |
| 2026 | Microphone, switch #1 | mic_on |
| 0312 / 0310 / 0313 | Crackling radio #1, Radio interference #1, Crackling radio #2 | radio_burst / radio_static / (candidate) |
| 0589 / 2618 | Walkie talkie: Start, Radio frequency sweep #2 | radio_start / (candidate) |
| 2134 / 1783 / 1786 | Zapping, Cathode screen off #1 / #4 | crt_switch / crt_off / (candidate) |
| 3411 / 0035 / 1269 | Evacuation alarm #1, Electronic alarm (buzzer) #1, Industrial doorbell #1 | alarm_warning / alarm_buzzer / (candidate) |
| 3598 / 2118 / 0957 / 0064 | Ventilation #5, Neon or transformer #1, VMC engine, Electric transformer #1 | amb_vent (loop) / amb_neon (loop) / (candidates) |
| 0303 / 1803 / 0616 | Grinding metal gate #1, Automatic hatch opening, Creaking metallic door | metal_scrape / hatch / (candidate) |

SHA-256 of the originals:
- 836d737af5128b7f4a975062e7360df5f777871070d1dac6d8686bb5e5b37ef8 *0026.wav
- 1d9c2d5e4bfe00868e25fff28f578c5844cf48cc7afe9cec53fdd06a422ca880 *0035.wav
- f1a9a59fbc1d6e0f7815d81279643e0c1dce8fb3cbb6cd15c4a0577decdae4ab *0064.wav
- bb3e704ba55c9b023b67df80013c498875cd55db61a0e16fd43f9fe259cca3ad *0164.wav
- a693fe3443c73bc019a42d0cba61b049b08de9c8cc2bedd28e1bd5d2f6f8de62 *0303.wav
- 8362a2622e243583f6adc95bc19be984fbb77176fc26112fa98af3605ea19df7 *0310.wav
- e53ec91815d493e8046e2a05059ceb7fd179130584befb8b891fd54437e42f8d *0312.wav
- 63084d47d325d4547b915d70a7b202a71b2be2d02a19c6a2e6b73330c808ea9d *0313.wav
- cc3e8616f03787e463e14c112c02d02aa3dc8c733bf9a0cdab3369a472049ae8 *0540.wav
- 1e43da08fc03e7d53bc113aaa9f170cc6d327f4015ea845507a0a160d6e049c1 *0589.wav
- 7095712d8a36ad71890eeac768ddc6dabcfd8894bef70dba20d430e8745c2bdd *0616.wav
- 1b00c39b3a4f44e639826047f063a140be3b854d399621b5f1df9b24ec100699 *0957.wav
- 49476ed2e7625825250f979e27aafb9ff58bee13650b05d05a7c30bfb190650c *1269.wav
- 163282542bc746e4ac2ed1e6d798a71030e47a9393d8890110542f0fe541ea78 *1783.wav
- 8ee8450849b281a3e2940d2b2df9b33a0e9165ca141de90c8b9d8755817e4e9b *1786.wav
- 0c16cf5f5fa62dc49beaa9fc83fb02b0e58c901f3285cd527570dc1143b2b82c *1803.wav
- 5e78d913b55d05b47b396059da653c3046a305721340dbf9b52a0713becaad33 *2026.wav
- 1f98b9507fc2b4556749110c7ec375552cd58010e5c9738a374da32b7d95d21e *2118.wav
- f8ba743ef40f9e35b7e37d2b1e1860547594cf51731070c2ba9c0aeb375a4bbc *2134.wav
- 5b34d5f08dbf392609c12f62eebf6db23a18be06dc662636b7b969405920fc54 *2210.wav
- 24defd28f3166c0188708dfab4fcb0df01e8ef9e0c69ed02fed73b389223b049 *2212.wav
- 30bab4283e78df9333e7b63fa2fd4f7d103e3c87b71975a49629a28df65f70de *2618.wav
- b5e7b6f8d9357c5978f31298844eeefaaf8b9efb6ff0346109145684ad0b2d1a *3061.wav
- b711e6d9a58a10a4e1aa384617b71211e596f627e85a033fad70e47aa5795a6c *3063.wav
- 060c28ee21ddccb154fb1c339bc87cfa19069f9dd336e05f61d1507387f84cbf *3411.wav
- ceda6eeca1becf1aead564ddda16676316df878a66f06cba3c72e0cfc1623149 *3598.wav
