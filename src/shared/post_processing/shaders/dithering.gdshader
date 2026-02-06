shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

#include "res://shared/shaders/include/resolution.gdshaderinc"
#include "res://shared/shaders/include/dither_setup.gdshaderinc"

void fragment() {
	// Called for every pixel the material is visible on.
//Dithering
#include "res://shared/shaders/include/get_dither.gdshaderinc"

//Color quantization
vec3 quant =  texture(screen_texture, SCREEN_UV).rgb;
quant = round(quant*255.0+dit);
quant = clamp(quant, vec3(0), vec3(255));
quant = clamp(quant/8.0, vec3(0), vec3(31));
quant = round(quant);
quant /= 31.0;

COLOR.rgb = quant.rgb;
}
