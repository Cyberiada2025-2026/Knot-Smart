shader_type spatial;

uniform sampler2D main_tex: filter_nearest;
uniform sampler2D wave_tex: filter_nearest;
uniform sampler2D water_col;
uniform vec4 ripple_col: source_color;
uniform vec2 ripple_egdes;
uniform vec2 speed1;
uniform vec2 speed2;
uniform vec2 speed3;
uniform vec2 speed4;
uniform vec4 scales = vec4(1.0);

void fragment() {
	vec2 uv = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xz;
	float n1 = texture(wave_tex, uv * scales.r + speed1 * TIME).r;
	float n2 = texture(wave_tex, uv * scales.g + speed2 * TIME).g;
	float n3 = texture(main_tex, uv * scales.b + speed3 * TIME).b;
	float n4 = texture(main_tex, uv * scales.a + speed4 * TIME).a;
	
	float noise = (n3 + n4) / 2.0;
	vec4 col = texture(water_col, vec2(noise, 0.0));
	
	float ripple = (n1 + n2)/2.0;
	ripple *= noise;
	col = mix(col, ripple_col, smoothstep(ripple_egdes.x, ripple_egdes.y, 1.0 - ripple));
	
	ALBEDO = col.rgb;
	ALPHA = col.a;
}
