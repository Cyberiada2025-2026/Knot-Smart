shader_type spatial;
render_mode diffuse_lambert;

uniform bool billboard = false;

uniform sampler2D main_texture : source_color, filter_nearest, repeat_disable;

uniform vec3 tint : source_color = vec3(1);

varying vec4 clip_pos;

void vertex() {
	#include "res://shared/shaders/include/vertex_wobble.gdshaderinc"
}

void fragment() {
	// Called for every pixel the material is visible on.
	#include "res://shared/shaders/include/affine_texture_mapping.gdshaderinc"
	vec3 texture_color = texture(main_texture, uv).rgb;
	
	ALBEDO = texture_color * tint;
}