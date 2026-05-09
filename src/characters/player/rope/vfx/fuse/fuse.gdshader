shader_type spatial;
render_mode unshaded, depth_test_inverted, cull_front;
stencil_mode read, compare_equal, 10;

void fragment() {
	ALBEDO = COLOR.rgb;
	ALPHA = COLOR.a;
}
