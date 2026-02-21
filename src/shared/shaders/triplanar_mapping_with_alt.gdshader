shader_type spatial;

uniform float alt_mask_scale = 1.0;
uniform float texture_scale = 1.0;
uniform vec3 alt_mask_rotation = vec3(0.0, 0.0, 0.0);
uniform float blend_strength = 1.0;
uniform sampler2D xy_main;
uniform sampler2D xy_alt;
uniform sampler2D yz_main;
uniform sampler2D yz_alt;
uniform sampler2D xz_main;
uniform sampler2D xz_alt;
uniform sampler3D alt_mask;
uniform sampler2D gradient;
uniform float gradient_max_height = 1.0;

varying vec3 world_pos;
varying vec3 texture_pos;
varying vec3 weights;
varying float gradient_pos;

mat3 fromEuler(vec3 rot) {
	float cos_x = cos(rot.x);
	float cos_y = cos(rot.y);
	float cos_z = cos(rot.z);
	float sin_x = sin(rot.x);
	float sin_y = sin(rot.y);
	float sin_z = sin(rot.z);

	return mat3(vec3(cos_y * cos_z, 							cos_y * sin_z, 							-sin_y),
				vec3(sin_x * sin_y * cos_z - cos_x * sin_z, 	sin_x * sin_y * sin_z + cos_x * cos_z, 	sin_x * cos_y),
				vec3(cos_x * sin_y * cos_z - sin_x * sin_z, 	cos_x * sin_y * sin_z - sin_x * cos_z, 	cos_x * cos_y)
				);
}

void vertex() {
	mat4 rotation_mat = mat4(fromEuler(alt_mask_rotation));
	vec4 v_pos = MODEL_MATRIX * vec4(VERTEX, 1.0);
	world_pos = (rotation_mat * v_pos).xyz;
	texture_pos = v_pos.xyz * texture_scale;
	world_pos *= alt_mask_scale;
	weights = abs(normalize(pow(abs(vec4(NORMAL, 1.0)* MODEL_MATRIX).xyz, vec3(blend_strength))));

	gradient_pos = v_pos.y / gradient_max_height;
}

void fragment() {
	vec4 alt_sample = texture(alt_mask, world_pos);
	vec4 xy_main_sample = texture(xy_main, texture_pos.xy);
	vec4 xy_alt_sample = texture(xy_alt, texture_pos.xy);
	vec4 yz_main_sample = texture(yz_main, texture_pos.zy);
	vec4 yz_alt_sample = texture(yz_alt, texture_pos.zy);
	vec4 xz_main_sample = texture(xz_main, texture_pos.xz);
	vec4 xz_alt_sample = texture(xz_alt, texture_pos.xz);

	float texture_type = alt_sample.r;
	vec3 xy_color =  xy_main_sample.rgb * texture_type + xy_alt_sample.rgb * (1.0 - texture_type);
	vec3 yz_color =  yz_main_sample.rgb * texture_type + yz_alt_sample.rgb * (1.0 - texture_type);
	vec3 xz_color = xz_main_sample.rgb * texture_type + xz_alt_sample.rgb * (1.0 - texture_type);
	yz_color *= weights.x;
	xy_color *= weights.z;
	xz_color *= weights.y;
	
	float clamped_gradient_pos = clamp(gradient_pos, 0.0, 0.9);
	vec4 gradient_sample = texture(gradient, vec2(clamped_gradient_pos, 0.0));
	
	ALBEDO = xy_color + yz_color + xz_color;
	ALBEDO = mix(ALBEDO, gradient_sample.rgb, gradient_sample.a);
}
