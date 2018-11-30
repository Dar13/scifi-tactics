shader_type spatial;
render_mode unshaded, world_vertex_coords;

uniform sampler2D image;
uniform sampler2D flicker_image;
uniform vec3 color_influence;
uniform float alpha;

void fragment()
{
	float pos_scale = (inverse(INV_CAMERA_MATRIX) * vec4(VERTEX, 1.0)).x / 20.0;
	pos_scale = pos_scale + (inverse(INV_CAMERA_MATRIX) * vec4(VERTEX, 1.0)).z / 20.0;
	pos_scale = pos_scale * 1.0;
	float scaled_time = TIME / 2.0;
	float scaled_uv = scaled_time + pos_scale;
	vec3 img_color = texture(image, UV).xyz * color_influence;
	
	vec4 flicker_color = texture(flicker_image, vec2(scaled_uv, 0));
	vec3 flicker_influence = flicker_color.xyz;
	//flicker_influence = vec3(1.0);
	
	ALBEDO = img_color + flicker_influence;
	ALPHA = alpha;
}