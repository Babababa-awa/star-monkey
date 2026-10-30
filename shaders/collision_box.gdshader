shader_type spatial;
render_mode blend_add, depth_draw_opaque, cull_disabled, unshaded;

uniform float shield_active : hint_range(0.0, 1.0) = 0.0;
uniform vec4 shield_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float fresnel_power : hint_range(0.5, 8.0) = 2.5;
uniform float idle_strength : hint_range(0.0, 2.0) = 0.12;
uniform float active_strength : hint_range(0.0, 4.0) = 1.4;

void fragment() {
	vec3 view_dir = normalize(VERTEX);
	float fresnel = pow(1.0 - abs(dot(normalize(NORMAL), -view_dir)), fresnel_power);
	float energy = idle_strength * fresnel;
	energy += shield_active * active_strength * (fresnel + 0.15);

	ALBEDO = shield_color.rgb * energy;
	ALPHA = clamp(energy, 0.0, 1.0);
}