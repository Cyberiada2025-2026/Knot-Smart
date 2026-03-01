shader_type spatial;
render_mode diffuse_lambert;

uniform bool billboard = false;

uniform sampler2D main_texture : source_color, filter_nearest, repeat_enable;
uniform sampler2D alt_texture : source_color, filter_nearest, repeat_enable;
uniform sampler3D alt_mask: source_color, filter_nearest, repeat_enable;
uniform mat4 alt_transform;

uniform vec3 tint : source_color = vec3(1);

varying vec4 clip_pos;
varying vec3 world_pos;

void vertex() {
	#include "res://shared/shaders/include/vertex_wobble.gdshaderinc"
	
	vec4 v_pos = MODEL_MATRIX * vec4(VERTEX, 1.0);
	world_pos = (alt_transform * v_pos).xyz;
}

void fragment() {
	// Called for every pixel the material is visible on.
	#include "res://shared/shaders/include/affine_texture_mapping.gdshaderinc"
	vec3 texture_color_main = texture(main_texture, uv).rgb;
	vec3 texture_color_alt = texture(alt_texture, uv).rgb;
	
	float alt_sample = texture(alt_mask, world_pos).r;

	ALBEDO = mix(texture_color_main, texture_color_alt, alt_sample) * tint;
}
