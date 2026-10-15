shader_type canvas_item;
// TV snow: grey static, a new frame `speed` times a second, rows jittering in brightness and a
// brighter band rolling down. Put it on a ColorRect; `amount` below 1 lays it over what's behind.

uniform float cell : hint_range(1.0, 8.0) = 1.0; // the grain's size in screen pixels: the UI's scale
uniform float speed = 30.0;
uniform float roll : hint_range(0.0, 1.0) = 0.35;
uniform vec4 tint : source_color = vec4(0.92, 0.92, 0.95, 1.0);
uniform float amount : hint_range(0.0, 1.0) = 1.0;

// integer hashing: float hashes of large coordinates tear into steps
uint snow_hash(uvec3 v) {
	v = v * 1664525u + 1013904223u;
	v.x += v.y * v.z;
	v.y += v.z * v.x;
	v.z += v.x * v.y;
	v ^= v >> 16u;
	v.x += v.y * v.z;
	v.y += v.z * v.x;
	v.z += v.x * v.y;
	return v.x ^ v.y ^ v.z;
}

float snow_rand(uvec3 v) {
	return float(snow_hash(v) & 0xFFFFu) / 65535.0;
}

void fragment() {
	vec2 p = floor(FRAGCOORD.xy / max(cell, 1.0));
	uint frame = uint(floor(TIME * speed));
	float grain = pow(snow_rand(uvec3(uint(p.x), uint(p.y), frame)), 1.6);
	float line = snow_rand(uvec3(7u, uint(p.y), frame));
	float v = 0.65 * grain + 0.35 * line * snow_rand(uvec3(uint(p.x) + 9u, uint(p.y), frame + 3u));
	float band = exp(-pow((fract(SCREEN_UV.y - TIME * 0.35) - 0.5) * 7.0, 2.0));
	v = clamp(v * (0.75 + roll * 1.4 * band), 0.0, 1.0);
	COLOR = vec4(tint.rgb * v, amount);
}
