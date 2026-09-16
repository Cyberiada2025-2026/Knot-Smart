shader_type canvas_item;

const int points_amount = 150;

uniform sampler2D color_ramp;
uniform vec4 tint: source_color;
uniform float white_mix: hint_range(0.0, 1.0);
uniform float scale_mix: hint_range(0.0, 1.0);
uniform vec2 points[points_amount];
uniform float max_scale = 1.0;

void fragment() {
	float min_dist = 1.0;
	float scale = mix(1.0, max_scale, scale_mix);
	vec2 point;
	vec2 pixel;
	for (int i = 0; i < points_amount; i++)
	{
		point = points[i] * vec2(1.0, 0.75) / vec2(scale);
		point = (point - vec2(0.5)) * 2.0;
		point /= (vec2(scale));
		point = (point + vec2(1.0)) / 2.0;
		pixel = SCREEN_UV * vec2(1.0, 0.75);
		min_dist = min(min_dist, distance(pixel, point));
	}
	COLOR = texture(color_ramp, vec2(min_dist * scale * scale, 1.0)) * tint;
	COLOR = mix(COLOR, vec4(1.0), white_mix);
}