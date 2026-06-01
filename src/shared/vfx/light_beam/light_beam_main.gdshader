shader_type spatial;
render_mode unshaded, fog_disabled;
stencil_mode write, 20;

const bool billboard = false;

uniform vec4 main_col: source_color;
uniform vec4 stripe_col: source_color;

uniform float stripe_width: hint_range(0.0, 1.0);
uniform float stripe_frequency;
uniform float stripe_speed;

varying vec4 clip_pos;

void vertex() {
	#include "res://shared/shaders/include/vertex_wobble.gdshaderinc"
}

void fragment() {
	float height = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).y;
	float weight = step(abs(sin(height * 2.0 * PI * stripe_frequency - 2.0 * PI * stripe_speed * TIME)), stripe_width);
	vec4 col = mix(main_col, stripe_col, weight);
	ALBEDO = col.rgb;
	ALPHA = col.a;
}
