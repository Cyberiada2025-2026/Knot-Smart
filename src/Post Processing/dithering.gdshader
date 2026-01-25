shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

const int dither_mat[16] = {
	    		-4, 0, -3, 1,
	    		2, -2, 3, -1,
	    		-3, 1, -4, 0,
	    		3, -1, 2, -2
		};
const vec2 res = vec2(320, 240);

void fragment() {
	// Called for every pixel the material is visible on.
//Dithering
ivec2 pos = ivec2(SCREEN_UV.xy*res.xy);
float dit = float( dither_mat[ (pos.x % 4) + (pos.y % 4)*4 ] );

//Color quantization
vec3 quant =  texture(screen_texture, SCREEN_UV).rgb;
quant = round(quant*255.0+dit);
quant = clamp(quant, vec3(0), vec3(255));
quant = clamp(quant/8.0, vec3(0), vec3(31));
quant = round(quant);
quant /= 31.0;

COLOR.rgb = quant.rgb;
}
