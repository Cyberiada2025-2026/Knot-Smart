shader_type spatial;

uniform float scale = 1.0;
uniform vec3 rotation = vec3(0.0, 0.0, 0.0);
uniform sampler2D wall_main;
uniform sampler2D wall_damaged;
uniform sampler3D noise;

varying vec3 world_pos;

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
	world_pos = (rotation_mat * MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_pos =
	world_pos /= scale;
}

void fragment() {
	vec4 noise_sample = texture(noise, world_pos);
	vec4 wall_main_sample = texture(wall_main, world_pos.xy);
	vec4 wall_damaged_sample = texture(wall_damaged, world_pos.xy);

	float texture_type = noise_sample.r;
	ALBEDO = wall_main_sample.rgb * texture_type + wall_damaged_sample.rgb * (1.0 - texture_type);;
}
