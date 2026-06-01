shader_type spatial;
render_mode unshaded, cull_front, blend_add, fog_disabled;
stencil_mode read, compare_not_equal, 20;

const bool billboard = false;

varying vec4 clip_pos;

void vertex() {
	#include "res://shared/shaders/include/vertex_wobble.gdshaderinc"
}

void fragment() {
	ALBEDO = COLOR.rgb;
	ALPHA = COLOR.a;
}
