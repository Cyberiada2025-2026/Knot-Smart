shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

const vec2 res = vec2(320, 240);

/**  Hardness of scanline */
uniform float hardScan: hint_range(-16.0, -8.0) = -8.0;

/** Hardness of pixels in scanline */
uniform float hardPix: hint_range(-4.0, -2.0)=-2.5;

/** Warping screen along x */
uniform float warpX: hint_range(0.0, 0.125) = 0.03125;
/** Warping screen along y */
uniform float warpY: hint_range(0.0, 0.125) = 0.041667;

/** Strength of darker grid */
uniform float maskDark: hint_range(0.25, 3.0) = 0.75;
/** Strength of lighter points */
uniform float maskLight: hint_range(0.25, 3.0) = 1.75;

vec3 Fetch(vec2 pos, vec2 off, vec2 size)
{
  pos = (pos.xy*res.xy + off)/res;
  if(max(abs(pos.x-0.5),abs(pos.y-0.5))>0.5)return vec3(0.0,0.0,0.0);
  //pos *= size;
  return  texture(screen_texture, pos.xy).rgb;
}

vec2 Dist(vec2 pos)
{
	pos *= res;
	return -(pos-floor(pos))-vec2(0.5);
}

float Gaus(float pos, float scale) { return exp2(scale*pos*pos); }

vec3 Horz3(vec2 pos,float off, vec2 size){
  vec3 b=Fetch(pos,vec2(-1.0,off), size);
  vec3 c=Fetch(pos,vec2( 0.0,off), size);
  vec3 d=Fetch(pos,vec2( 1.0,off), size);
  float dst=Dist(pos).x;
  // Convert distance to weight.
  float scale=hardPix;
  float wb=Gaus(dst-1.0,scale);
  float wc=Gaus(dst+0.0,scale);
  float wd=Gaus(dst+1.0,scale);
  // Return filtered sample.
  return (b*wb+c*wc+d*wd)/(wb+wc+wd);
}

vec3 Horz5(vec2 pos,float off , vec2 size){
  vec3 a=Fetch(pos,vec2(-2.0,off), size);
  vec3 b=Fetch(pos,vec2(-1.0,off), size);
  vec3 c=Fetch(pos,vec2( 0.0,off), size);
  vec3 d=Fetch(pos,vec2( 1.0,off), size);
  vec3 e=Fetch(pos,vec2( 2.0,off), size);
  float dst=Dist(pos).x;
  // Convert distance to weight.
  float scale=hardPix;
  float wa=Gaus(dst-2.0,scale);
  float wb=Gaus(dst-1.0,scale);
  float wc=Gaus(dst+0.0,scale);
  float wd=Gaus(dst+1.0,scale);
  float we=Gaus(dst+2.0,scale);
  // Return filtered sample.
  return (a*wa+b*wb+c*wc+d*wd+e*we)/(wa+wb+wc+wd+we);}

float Scan(vec2 pos,float off ){
  float dst=Dist(pos).y;
  return Gaus(dst+off,hardScan);}

vec3 Tri(vec2 pos , vec2 size){
  vec3 a=Horz3(pos,-1.0, size);
  vec3 b=Horz5(pos, 0.0, size);
  vec3 c=Horz3(pos, 1.0, size);
  float wa=Scan(pos,-1.0);
  float wb=Scan(pos, 0.0);
  float wc=Scan(pos, 1.0);
  return a*wa+b*wb+c*wc;}

vec2 Warp(vec2 pos){
  pos=pos*2.0-1.0;
  pos*=vec2(1.0+(pos.y*pos.y)*warpX,1.0+(pos.x*pos.x)*warpY);
  return pos*0.5+0.5;}

vec3 Mask(vec2 pos, vec2 size)
{
  pos.x+=pos.y*3.0;
  pos.x=fract(pos.x/6.0);
  vec3 mask=vec3(maskDark,maskDark,maskDark);
  if(pos.x<0.333)mask.r=maskLight;
  else if(pos.x<0.666)mask.g=maskLight;
  else mask.b=maskLight;
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
	color.rgb=Tri(pos, size);
	color.rgb *= Mask(uv, size);
	COLOR = color;
	//COLOR.rgb = Mask(SCREEN_UV*res);
}
