shader_type spatial;
render_mode cull_disabled;

const int dither_mat[16] = {
	    		-4, 0, -3, 1,
	    		2, -2, 3, -1,
	    		-3, 1, -4, 0,
	    		3, -1, 2, -2
};
const bool billboard = false;

uniform sampler2D main_texture : source_color, filter_nearest, repeat_disable;
uniform float alpha_treshold = 0.1f;
uniform vec3 main_col: source_color;
uniform vec3 sec_col: source_color;
uniform vec2 dot_cutoff = vec2(0.0, 1.0);

varying vec4 clip_pos;

void vertex() {
	#include "res://shared/shaders/include/vertex_wobble.gdshaderinc"
}

void fragment() {
	// Called for every pixel the material is visible on.
	#include "res://shared/shaders/include/affine_texture_mapping.gdshaderinc"

	vec3 texture_color = texture(main_texture, uv).rgb;

	//vec2 screen = SCREEN_UV;
	#include "res://shared/shaders/include/get_dither.gdshaderinc"
	dit = (1.0 + dit*0.5*0.1);

	float dotprod = abs(dot(NORMAL, VIEW));

	if (texture_color.r * COLOR.a * dit * smoothstep(dot_cutoff.x, dot_cutoff.y, dotprod) < 0.1)
		discard;

	ALBEDO = mix(main_col, sec_col, texture_color.b) * vec3(1.0-texture_color.g);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
