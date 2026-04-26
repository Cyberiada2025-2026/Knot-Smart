shader_type canvas_item;

const int points_amount = 150;

uniform sampler2D color_ramp;
uniform vec4 tint: source_color;
uniform vec2 points[points_amount];

void fragment() {
	float min_dist = 1.0;
	for (int i = 0; i < points_amount; i++)
	{
		min_dist = min(min_dist, distance(SCREEN_UV * vec2(1.0, 0.75), points[i] * vec2(1.0, 0.75)));
	}
	COLOR = texture(color_ramp, vec2(min_dist, 1.0)) * tint;
}