#pragma header


#define YUV_pixel_offset vec2(2.0, 0.0)
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

vec3 rgbToYuv(vec3 rgb) {
    float Y = dot(rgb, vec3(0.299, 0.587, 0.114));
    float U = dot(rgb, vec3(-0.169, -0.331, 0.5)) + 0.5;
    float V = dot(rgb, vec3(0.5, -0.419, -0.081)) + 0.5;
    return vec3(Y, U, V);
}

vec3 yuvToRgb(float Y, float U, float V) {
    U = clamp(U - 0.5, -0.5, 0.5);
    V = clamp(V - 0.5, -0.5, 0.5);
    return vec3(
        Y + 1.402 * V,
        Y - 0.344 * U - 0.714 * V,
        Y + 1.772 * U
    );
}


void main() {
    float textureScale = openfl_TextureSize.y / resolution_ratio;
    vec2 uv = openfl_TextureCoordv * textureScale;

    if (all(lessThanEqual(uv, vec2(1.0))))
    {
        vec2 blockCoord = floor(openfl_TextureCoordv * openfl_TextureSize / 2.0) / openfl_TextureSize * 2.0;

        vec3 yuv[4];
        yuv[0] = rgbToYuv(texture2D(bitmap, blockCoord + (vec2(0.5, 0.5) + YUV_pixel_offset) / openfl_TextureSize).rgb);
        yuv[1] = rgbToYuv(texture2D(bitmap, blockCoord + (vec2(1.5, 0.5) + YUV_pixel_offset) / openfl_TextureSize).rgb);
        yuv[2] = rgbToYuv(texture2D(bitmap, blockCoord + (vec2(0.5, 1.5) + YUV_pixel_offset) / openfl_TextureSize).rgb);
        yuv[3] = rgbToYuv(texture2D(bitmap, blockCoord + (vec2(1.5, 1.5) + YUV_pixel_offset) / openfl_TextureSize).rgb);


        vec2 fuv = (openfl_TextureCoordv * openfl_TextureSize - blockCoord * openfl_TextureSize) / vec2(2.0);

        vec3 UV_avg = mix(
            mix(yuv[0], yuv[1], fuv.x),
            mix(yuv[2], yuv[3], fuv.x), fuv.y
        );

        vec4 col = texture2D(bitmap, openfl_TextureCoordv);
        float Y_current = rgbToYuv(col.rgb).x;

        gl_FragColor = vec4(clamp(yuvToRgb(Y_current, UV_avg.y, UV_avg.z), 0.0, 1.0), col.a + 0.0001);
    }
}