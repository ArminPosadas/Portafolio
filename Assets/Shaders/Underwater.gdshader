shader_type canvas_item;

uniform vec3 water: source_color = vec3(0.4, 0.6, 0.8);
uniform float speed: hint_range(0.0, 4.0, 0.01) = 1.0;
uniform float wave: hint_range(0.0, 100.0, 0.01) = 20.0;
uniform float warp: hint_range(0.1, 20.0, 0.01) = 5.0;

void fragment() {
	vec2 uv = UV;
	float time = TIME * speed;
	vec2 s = uv * wave + time;
	uv.x += sin(s.x - s.y) * warp * 1e-3 * sin (s.y);
	COLOR = texture(TEXTURE, uv) * vec4(water,1.0);
}
