shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float desaturate : hint_range(0.0, 1.0) = 0.6;
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.35;

void fragment() {
	vec4 col = texture(SCREEN_TEXTURE, SCREEN_UV);

	// ---- DESATURATION ----
	float luma = dot(col.rgb, vec3(0.299, 0.587, 0.114));
	col.rgb = mix(col.rgb, vec3(luma), desaturate);

	// ---- VIGNETTE ----
	vec2 uv = SCREEN_UV * 2.0 - 1.0;
	float vignette = 1.0 - dot(uv, uv);
	vignette = clamp(vignette, 0.0, 1.0);

	col.rgb *= mix(1.0 - vignette_strength, 1.0, vignette);

	COLOR = col;
}
