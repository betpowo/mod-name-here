	// https://www.shadertoy.com/view/4st3WX ; comment by coyote on 2016-01-15

#pragma header
uniform float iTime;
uniform vec2 offset;
void main()
{
    vec2 uv = openfl_TextureCoordv;
    vec2 U = uv + offset;
    vec4 f = openfl_TextureSize.xyxy;
    f = length(U += U - f.xy) / f;
    f = vec4(sin(6.0 / f + atan(U.x, U.y) * 4.0 - iTime).w < 0.0);
    f *= sin(2.0 * length(U) - 0.1);

    float col = f.r / f.a;
    gl_FragColor = applyFlixelEffects(vec4(col, col, col, 1.0) * f.a);
}