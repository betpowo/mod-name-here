//SHADERTOY PORT FIX
#pragma header
//SHADERTOY PORT FIX
uniform float borderSize;
uniform vec3 borderColor;

float _min(float a, float b) {
	if (b < a) return b;
	return a;
}

void main() {
	vec2 uv = openfl_TextureCoordv;
	// Outline bullshit?
	vec4 og = textureCam(bitmap, getCamPos(uv));
	vec4 color = textureCam(bitmap, getCamPos(uv));
	vec4 clor = vec4(0.0, 0.0, 0.0, 0.0);

	if (borderSize <= 0.0) {
		gl_FragColor = og;
		return;
	}

	float w = borderSize / openfl_TextureSize.x;
	float h = borderSize / openfl_TextureSize.y;
	
	vec4 offRIGHT = flixel_texture2D(bitmap, vec2(openfl_TextureCoordv.x + w, openfl_TextureCoordv.y));
	vec4 offLEFT = flixel_texture2D(bitmap, vec2(openfl_TextureCoordv.x - w, openfl_TextureCoordv.y));
	vec4 offUP = flixel_texture2D(bitmap, vec2(openfl_TextureCoordv.x, openfl_TextureCoordv.y + h));
	vec4 offDOWN = flixel_texture2D(bitmap, vec2(openfl_TextureCoordv.x, openfl_TextureCoordv.y - h));

	clor[3] += offRIGHT.a;
	clor[3] += offLEFT.a;
	clor[3] += offDOWN.a;
	clor[3] += offUP.a;
	clor[3] = _min(clor[3], 1.0);
	color = vec4(borderColor[0] * clor[3], borderColor[1] * clor[3], borderColor[2] * clor[3], clor[3]);
	color -= og.a;

	gl_FragColor = mix(color, og, og.a);
}