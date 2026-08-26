#pragma header


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

void main() {
    float textureScale = openfl_TextureSize.y / resolution_ratio;
    vec2 uv = openfl_TextureCoordv / textureScale;

    gl_FragColor = texture2D(bitmap, uv);
}