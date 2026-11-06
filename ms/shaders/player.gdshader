shader_type canvas_item;

uniform float hit_amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);

	// Strong white flash
	vec3 flash = tex.rgb + vec3(hit_amount * 1.2);
	flash = clamp(flash, 0.0, 1.0);

	// Optional outline-ish contrast boost
	flash = mix(flash, vec3(1.0), hit_amount * 0.3);

	COLOR = vec4(flash, tex.a);
}
