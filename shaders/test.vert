#pragma header

attribute float alpha;
attribute vec4 colorMultiplier;
attribute vec4 colorOffset;
uniform bool hasColorTransform;

uniform vec2 _targetdump;
uniform vec2 target;
uniform float nyoom;
uniform float zoom;

void postTransform(void) {
    //gl_Position.xy *= _targetdump.xy;
    //gl_Position.w = 0.5;
    // gl_Position.w = lerp(gl_Position.w, 2.0, gl_Position.y);
    //gl_Position.w += 0.5 * nyoom;
    // gl_Position.x = 1.0;

    //if (gl_Position.y >= openfl_TextureSize.y) gl_Position.y = -1.5;
    /*gl_Position.w += (gl_Position.y + 0.5) * nyoom;
    gl_Position.y *= 0.5;*/

    gl_Position = openfl_Matrix * openfl_Position;
    /*gl_Position.w = 0.5 + ((gl_Position.y * nyoom) / zoom);
    gl_Position.w += 0.5 / zoom;
    gl_Position.y -= gl_Position.w * 0.25;
    gl_Position.x /= zoom * nyoom;
    gl_Position.y += target.y * 0.02;*/

    //gl_Position.xy += target.xy;

    if ((1.0 - (target.y - gl_Position.y)) >= 0.5) {
        gl_Position.w = 0.5 + nyoom;
        gl_Position.y *= (zoom / nyoom) * 2;
    }
}

void main(void)
{
    #pragma body
    
    openfl_Alphav = openfl_Alpha * alpha;
    
    if (hasColorTransform)
    {
        openfl_ColorOffsetv = colorOffset / 255.0;
        openfl_ColorMultiplierv = colorMultiplier;
    }

    postTransform();
}