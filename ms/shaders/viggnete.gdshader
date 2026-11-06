shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float strength : hint_range(0.0, 1.0) = 0.25;

void fragment() {
	vec4 col = texture(SCREEN_TEXTURE, SCREEN_UV);

	vec2 uv = SCREEN_UV * 2.0 - 1.0;
	float vignette = 1.0 - dot(uv, uv);
	vignette = clamp(vignette, 0.0, 1.0);

	col.rgb *= mix(1.0 - strength, 1.0, vignette);

	COLOR = col;
}
