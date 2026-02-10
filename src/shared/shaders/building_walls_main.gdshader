shader_type spatial;

uniform float damage_scale = 1.0;
uniform float texture_scale = 1.0;
uniform vec3 rotation = vec3(0.0, 0.0, 0.0);
uniform float blend_strength = 1.0;
uniform sampler2D wall_main;
uniform sampler2D wall_damaged;
uniform sampler2D floor_main;
uniform sampler2D floor_damaged;
uniform sampler3D noise;
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
	mat4 rotation_mat = mat4(fromEuler(rotation));
	vec4 v_pos = MODEL_MATRIX * vec4(VERTEX, 1.0);
	world_pos = (rotation_mat * v_pos).xyz;
	texture_pos = v_pos.xyz * texture_scale;
	world_pos *= damage_scale;
	weights = abs(normalize(pow(abs(vec4(NORMAL, 1.0)* MODEL_MATRIX).xyz, vec3(blend_strength))));

	gradient_pos = v_pos.y / gradient_max_height;
}

void fragment() {
	vec4 noise_sample = texture(noise, world_pos);
	vec4 wall_main_sample_xy = texture(wall_main, texture_pos.xy);
	vec4 wall_damaged_sample_xy = texture(wall_damaged, texture_pos.xy);
	vec4 wall_main_sample_yz = texture(wall_main, texture_pos.zy);
	vec4 wall_damaged_sample_yz = texture(wall_damaged, texture_pos.zy);
	
	vec4 floor_main_sample = texture(floor_main, texture_pos.xz);
	vec4 floor_damaged_sample = texture(floor_damaged, texture_pos.xz);

	float texture_type = noise_sample.r;
	vec3 wall_color_xy =  wall_main_sample_xy.rgb * texture_type + wall_damaged_sample_xy.rgb * (1.0 - texture_type);
	vec3 wall_color_yz =  wall_main_sample_yz.rgb * texture_type + wall_damaged_sample_yz.rgb * (1.0 - texture_type);
	vec3 floor_color = floor_main_sample.rgb * texture_type + floor_damaged_sample.rgb * (1.0 - texture_type);
	wall_color_yz *= weights.x;
	wall_color_xy *= weights.z;
	floor_color *= weights.y;
	
	float clamped_gradient_pos = clamp(gradient_pos, 0.0, 0.9);
	vec4 gradient_sample = texture(gradient, vec2(clamped_gradient_pos, 0.0));
	
	ALBEDO = wall_color_xy + wall_color_yz + floor_color;
	ALBEDO = mix(ALBEDO, gradient_sample.rgb, gradient_sample.a);
}
