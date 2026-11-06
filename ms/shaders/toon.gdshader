shader_type canvas_item;

// ===== UNIFORMS =====
uniform float rgb_shift : hint_range(0.0, 0.05) = 0.02;    // RGB chromatic effect
uniform float wave_amplitude : hint_range(0.0, 20.0) = 4.0; // Wavy distortion strength
uniform float wave_frequency : hint_range(0.0, 20.0) = 8.0; // Wavy distortion frequency
uniform float pulse_strength : hint_range(0.0, 1.0) = 0.15; // Glowing pulse
uniform float speed : hint_range(0.0, 5.0) = 1.5;          // Animation speed

void fragment() {
    vec2 uv = FRAGCOORD.xy / vec2(TEXTURE_PIXEL_SIZE.xy);

    // ---- WAVE DISTORTION ----
    uv.y += sin(uv.x * wave_frequency + TIME * speed) * wave_amplitude / TEXTURE_PIXEL_SIZE.y;
    uv.x += cos(uv.y * wave_frequency + TIME * speed) * wave_amplitude / TEXTURE_PIXEL_SIZE.x;

    // ---- RGB SHIFT ----
    float r = texture(TEXTURE, uv + vec2(rgb_shift, 0.0)).r;
    float g = texture(TEXTURE, uv).g;
    float b = texture(TEXTURE, uv - vec2(rgb_shift, 0.0)).b;

    vec4 col = vec4(r, g, b, 1.0);

    // ---- PULSING GLOW ----
    float pulse = 0.5 + 0.5 * sin(TIME * speed);
    col.rgb += pulse * pulse_strength;

    COLOR = col;
}
