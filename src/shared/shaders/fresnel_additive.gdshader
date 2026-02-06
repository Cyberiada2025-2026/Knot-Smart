shader_type spatial;
render_mode cull_disabled, blend_add, unshaded;

#include "res://shared/shaders/include/resolution.gdshaderinc"

uniform bool billboard = false;
uniform float power = 3.0f;
uniform vec4 tint = vec4(1.0,1.0,1.0,1.0);
uniform float alpha_cutoff = 0.001;

varying vec4 clip_pos;

void vertex() {
	#include "include/vertex_wobble.gdshaderinc"
}

void fragment() {
	// Called for every pixel the material is visible on.
	float fresnel = pow(1.0-dot(NORMAL, VIEW), power);
	if (COLOR.a*fresnel*tint.a < alpha_cutoff)
		discard;

	ALBEDO = COLOR.rgb*tint.rgb;
}
