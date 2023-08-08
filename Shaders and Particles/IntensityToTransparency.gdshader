shader_type canvas_item;
render_mode unshaded;

uniform vec3 color : source_color = vec3(0.0, 0.0, 0.0);

void fragment() {
	COLOR = vec4(color, 1.0 - COLOR.r);
}
