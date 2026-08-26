#pragma header

#define sharpen 0.9
#define resolution_ratio 360.0

/*
    Hello, this is HEIHUA.
    This shader includes:
    * Color reduction
    * Resolution scaled down to 1/4 of the original
    * Restoration of the YUV 4:2:0 video format
    * Color shifting for an aged look
    * Sharpening effects to enhance the vintage feel
    * Block artifacts "simulating heavy compression" to mimic the distorted appearance of highly compressed video
    * 480p, which drastically reduced GPU usage.
    That's the full explanation of this shader.


    This shader is actually composed of 5 separate shaders, which are:
    * lowquality_0_reduce.frag
    * lowquality_1_sharpen.frag
    * lowquality_2_blockEffect.frag
    * lowquality_3_main.frag
    * lowquality_4_amplification.frag

    Additionally, you can disable any of the fragment shaders except lowquality_0_reduce.frag and lowquality_4_amplification.frag. The purpose of each shader is described in its filename:
    * lowquality_1_main.frag: Core processing "color reduction, YUV conversion".
    * lowquality_2_sharpen.frag: Sharpening effect "enhances edges for a 'crunchy' retro look".
    * lowquality_3_blockEffect.frag: Simulates block artifacts by merging 8x8 pixel blocks in areas with minimal color variation.

    Feel free to experiment with disabling these shaders to observe their individual effects.
    Note: The blockEffect shader's impact is subtle by design-it specifically targets flat color regions to mimic the "chunkiness" of heavily compressed video.

    PS: Please do not delete these notes --- HEIHUA.
*/

mat3 YUVFromRGB = mat3(
   0.299, -0.14713, 0.615,
   0.587, -0.28886, -0.51499,
   0.114, 0.436, -0.10001
);

mat3 RGBFromYUV = mat3(
    1.0, 1.0, 1.0,
    0.0, -0.394, 2.03211,
    1.13983, -0.580, 0.0
);

float extractLuma(vec3 c)
{
    return dot(c, vec3(0.299, 0.587, 0.114));
}

vec4 textureCustom(vec2 uv)
{
    if (uv.x >= 0.0 && uv.y >= 0.0 && uv.x <= 1.0 && uv.y <= 1.0)
        return texture2D(bitmap, uv);
}

void main()
{
    float textureScale = openfl_TextureSize.y / resolution_ratio;
    vec2 uv = openfl_TextureCoordv * textureScale;
    
    if (all(lessThanEqual(uv, vec2(1.0)))) {
        vec4 s = texture2D(bitmap, openfl_TextureCoordv);
        vec3 yuv = YUVFromRGB * s.rgb;

        vec2 imgSize = openfl_TextureSize / textureScale;
        float accumY = 0.0;

        for (int i = -1; i <= 1; ++i) {
            for (int j = -1; j <= 1; ++j) {
                vec2 offset = vec2(i, j) / imgSize;
                float s = extractLuma(textureCustom(openfl_TextureCoordv + offset).rgb);
                accumY += s * (9.0 - min(float(i * i + j * j), 1.0) * 10.0);
            }
        }

        accumY /= 9.0;
        float a = accumY;
        float gain = 0.9;
        accumY = (accumY * sharpen + yuv.x) * gain;

        gl_FragColor = vec4(RGBFromYUV * vec3(accumY, yuv.y, yuv.z), s.a + clamp(a, 0.0, 1.0));
    }
}