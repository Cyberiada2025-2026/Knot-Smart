shader_type spatial;

uniform sampler2D main_tex;
uniform sampler2D water_col;
uniform vec4 ripple_col: source_color = vec4(1.0);
uniform float ripple_amount: hint_range(0.0, 1.0);
uniform vec4 speeds;
uniform vec4 scales = vec4(1.0);

void fragment() {
	vec2 uv = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xz;
	float edge1 = texture(main_tex, uv * scales.r + vec2(1.0) * speeds.r * TIME).r;
	float edge2 = texture(main_tex, uv * scales.g + vec2(1.0) * speeds.g * TIME).g;
	float noise1 = texture(main_tex, uv * scales.b + vec2(1.0) * speeds.b * TIME).b;
	float noise2 = texture(main_tex, uv * scales.a + vec2(1.0) * speeds.a * TIME).a;
	
	float noise = noise1 * noise2;
	float ripples = step(edge1 * edge2, ripple_amount);
	
	vec4 col = texture(water_col, vec2(noise, 0.0));
	col = mix(col, ripple_col, ripples);
	ALBEDO = col.rgb;
	ALPHA = col.a;
}
