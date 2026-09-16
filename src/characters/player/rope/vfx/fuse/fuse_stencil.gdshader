shader_type spatial;
render_mode depth_draw_never;
stencil_mode write, 10;

void fragment() {
	ALPHA = 0.0;
}