#pragma header

uniform vec4 black;
uniform vec4 white;
uniform float mult;
const vec3 grayscaleValues = vec3(0.2126, 0.7152, 0.0722);
vec4 flixel_texture2DCustom(sampler2D bitmap, vec2 coord) {
    vec4 color = flixel_texture2D(bitmap, coord);
    if (!hasTransform || color.a == 0.0 || mult == 0.0) {
        return color;
    }

    vec4 newColor = vec4(0.0);
    newColor.rgb = vec3(dot(color.rgb / color.aaa, grayscaleValues.rgb));
    newColor = mix(black, white, vec4(newColor.g));
    newColor *= color.a;

    color = mix(color, newColor, mult);
    
    if(color.a > 0.0) {
        return color;
    }
    return vec4(0.0, 0.0, 0.0, 0.0);
}

void main() {
    gl_FragColor = flixel_texture2DCustom(bitmap, openfl_TextureCoordv);
}