#pragma header

#define lossless_level 5.0 // infinity
#define blockSize vec2(6.0)
#define resolution_ratio 720.0

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

float luma(vec4 color) {
    return dot(color.rgb, vec3(0.299, 0.587, 0.114)); 
}

float colorDistanceLuma(vec4 color1, vec4 color2) {
    float rgbDiff = abs(luma(color1) - luma(color2));
    float alphaDiff = abs(color1.a - color2.a);
    return max(rgbDiff, alphaDiff);
}


void main()
{
    float textureScale = openfl_TextureSize.y / resolution_ratio;
    vec2 uv = openfl_TextureCoordv * textureScale;
    
    if (all(lessThanEqual(uv, vec2(1.0)))) {
        vec2 blockPos = floor(openfl_TextureCoordv * openfl_TextureSize / blockSize) / openfl_TextureSize * blockSize;
        
        vec4 colorBlock1 = texture2D(bitmap, blockPos + vec2(-0.5, 0.5) / openfl_TextureSize);
        vec4 colorBlock2 = texture2D(bitmap, blockPos + vec2(-0.5 + blockSize.x, 0.5) / openfl_TextureSize);
        vec4 colorBlock3 = texture2D(bitmap, blockPos + vec2(-0.5, 0.5 + blockSize.y) / openfl_TextureSize);
        vec4 colorBlock4 = texture2D(bitmap, blockPos + vec2(-0.5 + blockSize.x, 0.5 + blockSize.y) / openfl_TextureSize);
        
        vec2 fuv = (openfl_TextureCoordv * openfl_TextureSize - blockPos * openfl_TextureSize) / blockSize;

        vec4 colorBlock = mix(
            mix(colorBlock1, colorBlock2, fuv.x),
            mix(colorBlock3, colorBlock4, fuv.x), fuv.y
        );

        vec4 colorBlocks = (colorBlock1 + colorBlock2 + colorBlock3 + colorBlock4) / 4.0;

        vec4 color = texture2D(bitmap, openfl_TextureCoordv);

        gl_FragColor = mix(colorBlock, color, clamp(colorDistanceLuma(color, colorBlocks) * lossless_level, 0.0, 1.0));
    }
}