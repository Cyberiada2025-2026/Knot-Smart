shader_type spatial;
render_mode unshaded,blend_mix,depth_prepass_alpha,cull_disabled,specular_disabled;
uniform sampler2D sprite_texture : source_color, filter_linear;

uniform vec4 line_color : source_color = vec4(1.0,1.0,1.0,1.0); // Glow or outline color
uniform float glowSize: hint_range(0.0, 300) = 15.0; // Size of glow
uniform int glowDensity: hint_range(0, 30) = 3; // How many stamps to repeat in one direction
uniform int glowRadialCoverage: hint_range(0, 32) = 4; // How many directions to spread out
uniform float glowAngle: hint_range(0.0, 6.28) = 1.57; // The starting angle. More important if you want to use this as a trail.
uniform float glowSharpness: hint_range(0.0, 5.0) = 1.0; // Effect how quickly stamps become transparent as they move out
uniform float alphaThreshold: hint_range(0.0, 1.0) =  0.2; // Alpha level a pixel should be considered a glow

//Goes through every single pixle and does thing
void fragment() {
	vec4 col = texture(sprite_texture, UV); // Gets color at uv position of pixel
	
	// Sets source image as default pixel
	ALBEDO = col.rgb;
	ALPHA = col.a;
	
	vec2 pixel_size = 1.0 / vec2(textureSize(sprite_texture, 0)); // Set pixel size
	float alph = 0.0; // Start with a 0 alpha to add to with each check
	for (int i = 0; i < glowRadialCoverage; i++) { // Goes around in a circle
		for (int j = 0; j < glowDensity; j++) { // Extends out
			float radians360 = 6.28;
			// The angle from which to grab pixel information
			float angle = (radians360 / float(glowRadialCoverage))*float(i+1) + glowAngle;
			// The distance to reach to grab pixel information
			float dist = glowSize * float(j + 1) / float(glowDensity);
			// Pixel coordinate to grab
			vec2 pixel_coor = vec2( sin(angle) , cos(angle) );
			// Gets the pixel based on the previous information
    		vec4 tex = texture(sprite_texture, UV + pixel_coor * pixel_size * dist);
			
			// Sharpness. If you don't care about this, enable the next line and delete the next 3
			//alph += tex.a * line_color.a;
			float distFrom = float(glowDensity-j) / float(glowDensity); // Distance iteration number (how far out)
			float sharpness = mix(0.0, 1.0, pow(distFrom, glowSharpness) ); // Figure out sharpness level, interplote with distance and Glow Sharpness modifier
			alph += (tex.a * line_color.a) * sharpness; // Apply sharpness
		}
	}
	
	// Adds outline if this part of the image is transparent
	if (ALPHA < alphaThreshold){
		ALBEDO = line_color.rgb;
		ALPHA = alph;
	}
	
	// Enabling this line will cut out the image and leave the outline
	ALPHA -= col.a * 10.0; 
	// if you set blend to add, and set this as a second pass, you'll get a better glow effect
}