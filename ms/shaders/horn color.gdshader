shader_type canvas_item;

uniform vec4 tint_color : source_color = vec4(1.0);
uniform float saturation = 1.0;
uniform float brightness = 1.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    // Convert to grayscale
    float gray = dot(tex.rgb, vec3(0.299, 0.587, 0.114));

    // Apply saturation
    vec3 color = mix(vec3(gray), tex.rgb, saturation);

    // Apply tint and brightness
    color *= tint_color.rgb * brightness;

    COLOR = vec4(color, tex.a);
}
