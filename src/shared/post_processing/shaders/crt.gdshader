shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

const vec2 RES = vec2(320, 240);

const vec2 MASK_SHAPE = vec2(3.0, 6.0);

// Should be uneven
const int MAX_BLUR = 5;

// Has to be positive, uneven, not greater than MAX_BLUR
const int BLUR_SIZE[3] = {3, 5, 3};

/**  Hardness of scanline */
uniform float hard_scan: hint_range(-16.0, -8.0) = -8.0;

/** Hardness of pixels in scanline */
uniform float hard_pix: hint_range(-5.0, -0.5)=-2.5;

/** Warping screen along x */
uniform float warp_x: hint_range(0.0, 0.125) = 0.03125;
/** Warping screen along y */
uniform float warp_y: hint_range(0.0, 0.125) = 0.041667;

/** Strength of darker grid */
uniform float mask_dark: hint_range(0.25, 3.0) = 0.75;
/** Strength of lighter points */
uniform float mask_light: hint_range(0.25, 3.0) = 1.75;

vec3 Fetch(vec2 pos, vec2 off, vec2 size){
  pos = floor(pos*RES + off)/RES;
  if (max(abs(pos.x - 0.5), abs(pos.y - 0.5)) > 0.5) return vec3(0.0, 0.0, 0.0);
  //pos *= size;
  return  texture(screen_texture, pos.xy).rgb;
}

// Distance in emulated pixels to nearest texel.
vec2 Dist(vec2 pos){
	pos *= RES;
	return -(pos - floor(pos)) - vec2(0.5);
}

float Gauss(float pos, float scale) { return exp2(scale * pos * pos); }

vec3 HorizontalBlur(vec2 pos, float off, vec2 size, int n){
	vec3 num = vec3(0.0);
	float den = 0.0;
	vec3 col = vec3(0.0);
	float weight = 0.001;
	float shift = 0.0;
	float dst=Dist(pos).x;
	for (int i = 0; i < MAX_BLUR && i < n; i++)
	{
		shift = float(i - n/2);
		col = Fetch(pos, vec2(shift, off), size);
		weight = Gauss(dst+shift, hard_pix);
		num += col*weight;
		den += weight;
	}
	return num/den;
}

float Scan(vec2 pos,float off ){
  float dst = Dist(pos).y;
  return Gauss(dst+off,hard_scan);
}

vec3 Blur(vec2 pos, vec2 size){
	vec3 blur = vec3(0.0);
	float shift = 0.0;
	int n =  BLUR_SIZE.length();
	for (int i = 0; i < BLUR_SIZE.length(); i++){
		shift = float(i - n/2);
		blur += HorizontalBlur(pos, shift, size, BLUR_SIZE[i]) * Scan(pos, shift);
	}
	return blur;
}

vec2 Warp(vec2 pos){
  pos = pos*2.0 - 1.0;
  pos *= vec2(1.0 + (pos.y*pos.y) * warp_x, 1.0 + (pos.x*pos.x) * warp_y);
  return pos*0.5 + 0.5;
}

vec3 Mask(vec2 pos, vec2 size){
  pos.x += pos.y * MASK_SHAPE.x;
  pos.x = fract(pos.x/MASK_SHAPE.y);
  vec3 mask = vec3(mask_dark, mask_dark, mask_dark);
  mask[int(pos.x * 3.0)] = mask_light;
  return mask;
}

// The code we want to execute in each invocation
void fragment()  {
	vec2 uv = SCREEN_UV/SCREEN_PIXEL_SIZE;
	vec2 size = vec2(1.0)/SCREEN_PIXEL_SIZE;

	if (uv.x >= size.x || uv.y >= size.y) {
		discard;
	}

	vec4 color = texture(screen_texture, SCREEN_UV);

	vec2 pos = Warp(SCREEN_UV);
	color.rgb = Blur(pos, size);
	color.rgb *= Mask(uv, size);

	COLOR = color;
}
