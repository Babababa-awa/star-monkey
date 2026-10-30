shader_type spatial;
render_mode blend_add, unshaded, cull_disabled;

uniform vec4 energy_color : source_color = vec4(1.0, 0.15, 0.1, 1.0);
uniform float pulse_speed : hint_range(0.0, 10.0) = 2.0;
uniform float noise_scale : hint_range(1.0, 20.0) = 8.0;
uniform float intensity : hint_range(0.5, 5.0) = 2.0;
uniform float min_alpha : hint_range(0.0, 1.0) = 0.25; // 75% transparent max

// Simple value noise
float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(
		mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
		mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x),
		f.y
	);
}

void fragment() {
	vec2 uv = UV * noise_scale;
	float t = TIME * pulse_speed;
	
	// Animated noise for energy movement
	float n = noise(uv + vec2(t * 0.3, t * 0.5));
	n += noise(uv * 2.0 - vec2(t * 0.2, t * 0.4)) * 0.5;
	
	// Pulsing core
	float pulse = 0.6 + 0.4 * sin(TIME * pulse_speed);
	
	// Edge glow
	float edge = smoothstep(0.0, 0.3, UV.y) * smoothstep(1.0, 0.7, UV.y);
	
	float energy = n * pulse * edge * intensity;
	
	ALBEDO = energy_color.rgb * energy;
	ALPHA = max(clamp(energy, 0.0, 1.0), min_alpha);
	EMISSION = ALBEDO * 2.0;
}