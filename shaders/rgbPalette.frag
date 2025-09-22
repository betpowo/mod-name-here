#pragma header

uniform vec3 r;
uniform vec3 g;
uniform vec3 b;

uniform float mult;

void main() {
	vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);

	if (color.a <= 0.0) {
		gl_FragColor = vec4(0.0);
		return;
	}

	if (mult > 0.0) {
		vec4 newColor = vec4(vec3(r * color.r + g * color.g + b * color.b), color.a);

		color = mix(color, newColor, mult);
	}

	gl_FragColor = color;
}