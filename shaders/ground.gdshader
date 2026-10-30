shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled;

uniform vec4 color : source_color = vec4(0.42, 0.42, 0.42, 1.0);

uniform bool fade_left  = false;
uniform bool fade_right = false;

uniform bool fade_forward = false;
uniform bool fade_back    = false;

uniform float fade_start_x : hint_range(0.0, 0.5) = 0.375;
uniform float fade_start_y : hint_range(0.0, 0.5) = 0.375;

void fragment() {
    float fade = 1.0;

    if (fade_left) {
        fade *= smoothstep(0.0, fade_start_x, UV.x);
    }
    if (fade_right) {
        fade *= smoothstep(1.0, 1.0 - fade_start_x, UV.x);
    }

    if (fade_forward) {
        fade *= smoothstep(0.0, fade_start_y, UV.y);
    }
    if (fade_back) {
        fade *= smoothstep(1.0, 1.0 - fade_start_y, UV.y);
    }

    ALBEDO = color.rgb;
    ALPHA  = color.a * fade;
}