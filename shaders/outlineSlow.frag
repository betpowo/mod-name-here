#pragma header
//SHADERTOY PORT FIX
uniform float borderSize;
uniform vec3 borderColor = vec3(1.0, 1.0, 1.0);

vec2 o = vec2(0.5, 0.5);
vec2 f = vec2(0.5, 0.5);

/*void vertex()
{
	o = VERTEX;
	vec2 uv = (UV - 0.5);
	VERTEX += uv * float(intensity);
	f = VERTEX;
}*/

void main()
{
    vec2 UV = openfl_TextureCoordv;

	vec2 t = openfl_TextureSize;
	vec2 regular_uv;
	regular_uv.x = UV.x + (f.x - o.x)/float(t.x);
	regular_uv.y = UV.y + (f.y - o.y)/float(t.y);
	
	vec4 regular_color = textureCam(bitmap, getCamPos(regular_uv));
	if((regular_uv.x < 0.0 || regular_uv.x > 1.0) || (regular_uv.y < 0.0 || regular_uv.y > 1.0)){
		regular_color = vec4(0.0); 
	}
    if (borderSize <= 0.0) {
        gl_FragColor = regular_color;
        return;
    }
	
	vec2 ps = vec2(borderSize) / t;
	
	vec4 final_color = regular_color;
    for(int x = -1; x <= 1; x += 1){
        for(int y = -1; y <= 1; y += 1){
            //Get the X and Y offset from this
            if (x==0 && y==0)
                continue;
                
            vec2 outline_uv = regular_uv + (normalize(vec2(float(x) * ps.x, float(y) * ps.y)) * ps);
            
            //Sample here, if we are out of bounds then fail
            vec4 outline_sample = textureCam(bitmap, outline_uv);
            if((outline_uv.x < 0.0 || outline_uv.x > 1.0) || (outline_uv.y < 0.0 || outline_uv.y > 1.0)){
                //We aren't a real color
                outline_sample = vec4(0.0);
            }
            
            //Is our sample empty? Is there something nearby?
            if(outline_sample.a > final_color.a){
            final_color = mix(vec4(borderColor.r, borderColor.g, borderColor.b, 1.0) * vec4(outline_sample.a),
                        regular_color, regular_color.a);
            }
        }
    }
	gl_FragColor = vec4(final_color); 
}