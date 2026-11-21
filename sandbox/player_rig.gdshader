shader_type canvas_item;

uniform float tip_heat : hint_range(0.0, 1.0) = 0.0;
uniform int direction : hint_range(0, 3) = 0; 
uniform float coverage : hint_range(0.05, 1.0) = 0.45; 

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	
	vec2 frame_uv = fract(UV / TEXTURE_PIXEL_SIZE / vec2(textureSize(TEXTURE, 0)));
	vec2 uv_step = fwidth(UV);
	
	float pos = UV.x;
	if (direction == 1) pos = 1.0 - UV.x;
	else if (direction == 2) pos = 1.0 - UV.y;
	else if (direction == 3) pos = UV.y;
	
	float tip_mask = smoothstep(1.0 - coverage, 1.0, pos);
	float flicker = 0.88 + 0.12 * sin(TIME * 45.0);
	
	vec3 spark_color = vec3(1.0, 0.88, 0.15);
	vec3 tinted = mix(tex.rgb, tex.rgb * vec3(1.4, 1.2, 0.2) + spark_color * 0.45 * flicker, tip_mask * tip_heat);
	
	COLOR = vec4(tinted, tex.a);
}