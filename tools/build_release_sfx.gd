extends SceneTree

# Builds the release preview's event and ambience sounds from the CC0 BigSoundBank originals
# (assets/third_party/release_ui/sfx/bigsoundbank, .gdignore'd; see CREDITS.md).
#   godot --headless --path . --script res://tools/build_release_sfx.gd
# Each output is mono 16-bit PCM: silence trimmed, faded, peak-normalised for its role.
# Loops are cut from a steady section and cross-faded so the end flows into the start.
const SRC := "res://assets/third_party/release_ui/sfx/bigsoundbank/"
const OUT := "res://assets/ui/release/sfx/"

# name: [source id, start s (-1 = first sound), max length s, peak dBFS, loop crossfade s (0 = one-shot)]
const SOUNDS := {
	"doc_page_a": ["2212", -1, 1.0, -8.0, 0.0],
	"doc_page_b": ["2210", -1, 1.0, -8.0, 0.0],
	"report_open": ["0164", -1, 0.8, -8.0, 0.0],
	"switch_heavy": ["3061", -1, 0.7, -6.0, 0.0],
	"switch_light": ["3063", -1, 0.5, -9.0, 0.0],
	"mic_on": ["2026", -1, 0.4, -9.0, 0.0],
	"radio_burst": ["0312", -1, 1.4, -13.0, 0.0],
	"radio_static": ["0310", -1, 1.8, -15.0, 0.0],
	"radio_start": ["0589", -1, 1.2, -12.0, 0.0],
	"crt_switch": ["2134", -1, 0.6, -12.0, 0.0],
	"crt_off": ["1783", -1, 0.4, -12.0, 0.0],
	"alarm_warning": ["3411", -1, 2.6, -11.0, 0.0],
	"alarm_buzzer": ["0035", -1, 1.4, -13.0, 0.0],
	"metal_scrape": ["0303", -1, 1.2, -11.0, 0.0],
	"hatch": ["1803", -1, 3.0, -12.0, 0.0],
	"amb_vent": ["3598", 6.0, 14.0, -24.0, 1.5],
	"amb_neon": ["2118", 1.0, 7.0, -30.0, 0.8],
}


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	for name: String in SOUNDS:
		var spec: Array = SOUNDS[name]
		var decoded: Dictionary = _read_wav(ProjectSettings.globalize_path(SRC + spec[0] + ".wav"))
		if decoded.is_empty():
			push_error("build_release_sfx: cannot read " + spec[0]); continue
		var samples: PackedFloat32Array = decoded.samples
		var rate: int = decoded.rate
		var start: int = _first_sound(samples) if spec[1] < 0 else int(spec[1] * rate)
		var length: int = mini(int(spec[2] * rate), samples.size() - start)
		var cut: PackedFloat32Array = samples.slice(start, start + length)
		if spec[4] > 0.0: cut = _loop(cut, int(spec[4] * rate))
		else: _fade(cut, int(0.003 * rate), int(minf(0.06, spec[2] * 0.25) * rate))
		_normalise(cut, spec[3])
		_write_wav(ProjectSettings.globalize_path(OUT + name + ".wav"), cut, rate)
		print("SFX %s <- %s  %.2fs %s" % [name, spec[0], cut.size() / float(rate), "loop" if spec[4] > 0.0 else ""])
	quit()


func _read_wav(path: String) -> Dictionary:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null: return {}
	var b: PackedByteArray = f.get_buffer(f.get_length())
	if b.slice(0, 4).get_string_from_ascii() != "RIFF": return {}
	var pos := 12
	var channels := 1; var rate := 44100; var bits := 16
	var data_start := -1; var data_len := 0
	while pos + 8 <= b.size():
		var id: String = b.slice(pos, pos + 4).get_string_from_ascii()
		var len: int = b.decode_u32(pos + 4)
		if id == "fmt ":
			channels = b.decode_u16(pos + 10); rate = b.decode_u32(pos + 12); bits = b.decode_u16(pos + 22)
		elif id == "data":
			data_start = pos + 8; data_len = mini(len, b.size() - data_start); break
		pos += 8 + len + (len % 2)
	if data_start < 0 or bits not in [16, 24]: return {}
	var width: int = bits / 8
	var frames: int = data_len / (width * channels)
	var out := PackedFloat32Array(); out.resize(frames)
	for i in frames:
		var sum := 0.0
		for c in channels:
			var o: int = data_start + (i * channels + c) * width
			var v: int
			if bits == 16: v = b.decode_s16(o)
			else:
				v = b[o] | (b[o + 1] << 8) | (b[o + 2] << 16)
				if v & 0x800000: v -= 0x1000000
			sum += float(v) / (32768.0 if bits == 16 else 8388608.0)
		out[i] = sum / channels
	return {"samples": out, "rate": rate}


func _first_sound(s: PackedFloat32Array) -> int:
	var peak := 0.0
	for v in s: peak = maxf(peak, absf(v))
	for i in s.size():
		if absf(s[i]) >= peak * 0.03: return maxi(0, i - 220)  # ~5 ms pre-roll
	return 0


func _fade(s: PackedFloat32Array, fade_in: int, fade_out: int) -> void:
	for i in mini(fade_in, s.size()): s[i] *= float(i) / fade_in
	for i in mini(fade_out, s.size()): s[s.size() - 1 - i] *= float(i) / fade_out


# Seamless loop: blend the last `xf` samples into the first `xf`, then drop the tail.
func _loop(s: PackedFloat32Array, xf: int) -> PackedFloat32Array:
	var n: int = s.size() - xf
	var out := s.slice(0, n)
	for i in xf:
		var t: float = float(i) / xf
		out[i] = s[i] * t + s[n + i] * (1.0 - t)
	return out


func _normalise(s: PackedFloat32Array, peak_db: float) -> void:
	var peak := 0.0
	for v in s: peak = maxf(peak, absf(v))
	if peak <= 0.0: return
	var gain: float = db_to_linear(peak_db) / peak
	for i in s.size(): s[i] = clampf(s[i] * gain, -1.0, 1.0)


func _write_wav(path: String, s: PackedFloat32Array, rate: int) -> void:
	var data := PackedByteArray(); data.resize(s.size() * 2)
	for i in s.size(): data.encode_s16(i * 2, int(round(s[i] * 32767.0)))
	var h := PackedByteArray(); h.resize(44)
	h.encode_u32(0, 0x46464952); h.encode_u32(4, 36 + data.size()); h.encode_u32(8, 0x45564157)
	h.encode_u32(12, 0x20746d66); h.encode_u32(16, 16); h.encode_u16(20, 1); h.encode_u16(22, 1)
	h.encode_u32(24, rate); h.encode_u32(28, rate * 2); h.encode_u16(32, 2); h.encode_u16(34, 16)
	h.encode_u32(36, 0x61746164); h.encode_u32(40, data.size())
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_buffer(h); f.store_buffer(data); f.close()
