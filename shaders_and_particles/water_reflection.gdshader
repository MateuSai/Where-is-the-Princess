shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
// Texture:2
	vec4 ref = texture(SCREEN_TEXTURE, vec2(SCREEN_UV.x, 1.0 - SCREEN_UV.y - 0.13));
	vec4 ice = texture(TEXTURE, UV.xy);

// Output:0
	COLOR = ice + ref/2.0;
}