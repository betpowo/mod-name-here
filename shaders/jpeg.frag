#pragma header
const vec3 grayscaleValues = vec3(0.2126, 0.7152, 0.0722);
void main() {
    vec4 og_color = textureCam(bitmap, getCamPos(openfl_TextureCoordv));
    vec4 color = og_color;

    color.r = mix(1.0, color.r, color.a);
    color.g = mix(1.0, color.g, color.a);
    color.b = mix(1.0, color.b, color.a);
    if (color.a > 0.0) {
        color /= og_color.a;
    }

    vec2 grid_size = openfl_TextureSize / 8.0;
    vec4 grid_color = textureCam(bitmap, getCamPos(floor((openfl_TextureCoordv * grid_size) + 0.5) / grid_size));
    if (grid_color.a > 0.0) {
        grid_color /= grid_color.a;
    }

    vec4 og_grid = grid_color;

    //grid_color.a *= grid_color.a * grid_color.a; // cube
    grid_color.rgb = vec3(0.941);
    if (grid_color.a > 0.0) grid_color.a = 1.0;

    color = mix(grid_color, color, floor(color.a * 10.0) / 10.0);

    if (color.a <= 0.0) {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
        return;
    }

    float fuck = mix(0.3, 4.7, grid_color.a * grid_color.a);
    color.rgb = floor(color.rgb * vec3(fuck)) / vec3(fuck);

    color.rgb = mix(color.rgb, color.rgb * 1.333, ((color.r+color.g+color.b) / 3.0));

    float average = dot(color.rgb, grayscaleValues);
    float grid_average = dot(og_grid.rgb, grayscaleValues);

    color.rgb = mix(color.rgb, vec3(average), 0.1);
    
    if (grid_average <= 0.21 || grid_average >= 0.89) {
        color.rgb = vec3(average);
    }

    gl_FragColor = color;
}  