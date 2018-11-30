shader_type spatial;
render_mode unshaded;

uniform bool enabled;
uniform vec3 base_color;
uniform vec3 glow_color;
uniform float time_scale;

void fragment()
{
	float rad = mod(TIME * time_scale, 2.0 * 3.14);
	float scale = -1.0 * 0.5 * cos(rad) + 0.5;
	
	if(enabled == false) { scale = 0.0; }
	
	ALBEDO = mix(base_color, glow_color, scale);
	ALPHA = 0.5;
}