shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float contrast : hint_range(0.8, 1.4) = 1.05;
uniform float saturation : hint_range(0.5, 1.5) = 1.08;
uniform float brightness : hint_range(-0.2, 0.2) = 0.02;

void fragment() {
	vec4 col = texture(SCREEN_TEXTURE, SCREEN_UV);

	// Brightness
	col.rgb += brightness;

	// Contrast
	col.rgb = (col.rgb - 0.5) * contrast + 0.5;

	// Saturation
	float gray = dot(col.rgb, vec3(0.299, 0.587, 0.114));
	col.rgb = mix(vec3(gray), col.rgb, saturation);

	COLOR = col;
}
