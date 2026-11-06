shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float thickness : hint_range(0.01, 0.1) = 0.035;
uniform vec3 frame_color: source_color = vec3(0.05, 0.08, 0.1);

void fragment() {
	vec2 uv = SCREEN_UV;
	vec4 col = texture(SCREEN_TEXTURE, uv);

	float border =
		step(uv.x, thickness) +
		step(uv.y, thickness) +
		step(1.0 - uv.x, thickness) +
		step(1.0 - uv.y, thickness);

	border = clamp(border, 0.0, 1.0);

	col.rgb = mix(col.rgb, frame_color, border * 0.7);
	COLOR = col;
}
