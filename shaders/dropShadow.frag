#pragma header

uniform vec4 uFrameBounds;

uniform float ang;
uniform float dist;
uniform float str;
uniform float thr;

uniform float angOffset;

uniform sampler2D altMask;
uniform bool useMask;
uniform float thr2;

uniform vec3 dropColor;

uniform float hue;
uniform float saturation;
uniform float brightness;
uniform float contrast;

uniform vec2 scale;

uniform float AA_STAGES;

const vec3 grayscaleValues = vec3(0.3098039215686275, 0.607843137254902, 0.0823529411764706);
const float e = 2.718281828459045;

vec3 applyHueRotate(vec3 aColor, float aHue){
    float angle = radians(aHue);

    mat3 m1 = mat3(0.213, 0.213, 0.213, 0.715, 0.715, 0.715, 0.072, 0.072, 0.072);
    mat3 m2 = mat3(0.787, -0.213, -0.213, -0.715, 0.285, -0.715, -0.072, -0.072, 0.928);
    mat3 m3 = mat3(-0.213, 0.143, -0.787, -0.715, 0.140, 0.715, 0.928, -0.283, 0.072);
    mat3 m = m1 + cos(angle) * m2 + sin(angle) * m3;

    return m * aColor;
}

vec3 applySaturation(vec3 aColor, float value){
    if(value > 0.0){ value = value * 3.0; }
    value = (1.0 + (value / 100.0));
    vec3 grayscale = vec3(dot(aColor, grayscaleValues));
    return clamp(mix(grayscale, aColor, value), 0.0, 1.0);
}

vec3 applyContrast(vec3 aColor, float value){
    value = (1.0 + (value / 100.0));
    if(value > 1.0){
        value = (((0.00852259 * pow(e, 4.76454 * (value - 1.0))) * 1.01) - 0.0086078159) * 10.0; //Just roll with it...
        value += 1.0;
    }
    return clamp((aColor - 0.25) * value + 0.25, 0.0, 1.0);
}

vec3 applyHSBCEffect(vec3 color){
    color = color + ((brightness) / 255.0);
    color = applyHueRotate(color, hue);
    color = applyContrast(color, contrast);
    color = applySaturation(color, saturation);
    return color;
}

vec2 imageRatio = vec2(1.0, 1.0);

float getMyFuckingAntialiasBro(float intensity) {
    if (AA_STAGES < 1.0) {
        return sign(max(intensity - thr, 0.0));
    }
    float fuck = pow(AA_STAGES, e) + sqrt(2.1);
    float real = clamp((intensity - thr) * fuck, 0.0, 1.0);
    return real; // shurtcut, since sign(0.0) returns 0.0 and sign(anything > 0) is 1.0
}

vec4 m(sampler2D b, vec2 u) {
    if (u != clamp(u, 0.0, 1.0)) {
        return vec4(0.0);
    }
    return textureCam(b, u);
}

vec4 applyDropBullshit(vec4 col, vec2 uv) {
    vec2 se = 1.0 / (_camSize.zw * scale);
    imageRatio.x = se.x; imageRatio.y = se.y;
    float intensity = dot(col.rgb, grayscaleValues);
    vec2 offsetUV = vec2(uv.x + (dist * cos(ang + angOffset) * imageRatio.x), uv.y - (dist * sin(ang + angOffset) * imageRatio.y));
    vec4 offsetBitmap = m(bitmap, offsetUV);
    if (intensity < thr) offsetBitmap.a = 1.0;
    float aaBullshit = getMyFuckingAntialiasBro(intensity);

    col = vec4(applyHSBCEffect(col.rgb / col.a), 1.0);
    col.rgb += dropColor * (1.0 - offsetBitmap.a) * col.a * str * aaBullshit;
    
    return col;
}

void main()
{
    vec2 uv = getCamPos(openfl_TextureCoordv);
    vec4 col = textureCam(bitmap, uv);
    gl_FragColor = applyDropBullshit(col, uv) * col.a;
}
