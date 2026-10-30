shader_type spatial;
render_mode unshaded, blend_add;

uniform vec4 core_color : source_color = vec4(0.0, 0.7, 1.0, 1.0);
uniform vec4 glow_color : source_color = vec4(0.2, 0.8, 1.0, 0.6);
uniform float intensity = 4.0;
uniform float core_radius = 0.15;   // tweak to match your mesh size
uniform float glow_radius = 0.5;    // tweak to match your mesh size

varying vec3 local_pos;

void vertex() {
    local_pos = VERTEX;  // object space
}

void fragment() {
    // Assumes the crystal is elongated along its local Z axis.
    // Change to .xz or .yz if your mesh points along a different axis.
    float dist = length(local_pos.xy);

    float core = smoothstep(core_radius, 0.0, dist);
    float glow = smoothstep(glow_radius, 0.0, dist);

    ALBEDO = (core_color.rgb * core + glow_color.rgb * glow) * intensity;
    ALPHA = max(core, glow * 0.7);
}