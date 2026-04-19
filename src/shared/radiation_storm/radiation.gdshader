shader_type canvas_item;

const float w_speed1 = 35.2;
const float w_speed2 = 56.7;

uniform sampler2D noise1: repeat_enable, filter_nearest;
uniform sampler2D noise2: repeat_enable, filter_nearest;
uniform sampler2D white: repeat_enable, filter_nearest;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float speed1: hint_range(-5.0, 5.0);
uniform float speed2: hint_range(-5.0, 5.0);
uniform float min_white: hint_range(0.0, 1.0);
uniform float max_white: hint_range(0.0, 1.0);
uniform float anim = 0.0;
uniform float smoothness: hint_range(0.0, 1.0);
uniform float black_delay: hint_range(0.0, 1.0);

void fragment() {
	vec3 screen =  texture(screen_texture, SCREEN_UV).rgb;
	float n1 = texture(noise1, SCREEN_UV + vec2(1.0)*speed1*TIME).r;
	float n2 = texture(noise2, SCREEN_UV + vec2(1.0)*speed2*TIME).r;
	vec3 color = screen;
	float s;

	float w1 = texture(white, SCREEN_UV + vec2(1.0)*w_speed1*TIME).r;
	float w2 = texture(white, SCREEN_UV - vec2(1.0)*w_speed2*TIME).g;
	s = step(mix(min_white, max_white, anim), (w1+w2)/2.0);
	color = mix(color, vec3(1.0), 1.0 - s);

	s = 1.415 - distance(SCREEN_UV, vec2(0.5));
	s -= anim * (1.415 + black_delay);
	s += black_delay;
	s = smoothstep(s - smoothness/2.0, s + smoothness/2.0, (2.0 - n1 - n2)/2.0);
	color = mix(color, vec3(0.0), s);

	COLOR.rgb = color;
}