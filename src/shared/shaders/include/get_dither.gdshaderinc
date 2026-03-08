ivec2 pos = ivec2(SCREEN_UV.xy*VIEWPORT_SIZE.xy);
float dit = float( dither_mat[ (pos.x % 4) + (pos.y % 4)*4 ] );