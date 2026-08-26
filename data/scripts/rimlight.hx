public function identity4x4() {
	/*
		the 4th column can act as the add blend mode
		if the other columns arent 0 btw
	*/
	return [
		1, 0, 0, 0,
		0, 1, 0, 0,
		0, 0, 1, 0,
		0, 0, 0, 1
	];
}

public function hueMatrix(v:Float, ?matrix:Array) {
    var cosHue = Math.cos(v * Math.PI / 180);
    var sinHue = Math.sin(v * Math.PI / 180);
	matrix ??= identity4x4();
    matrix[0] = 0.213 + cosHue * 0.787 - sinHue * 0.213;
    matrix[1] = 0.715 - cosHue * 0.715 - sinHue * 0.715;
    matrix[2] = 0.072 - cosHue * 0.072 + sinHue * 0.928;
    matrix[4] = 0.213 - cosHue * 0.213 + sinHue * 0.143;
    matrix[5] = 0.715 + cosHue * 0.285 + sinHue * 0.140;
    matrix[6] = 0.072 - cosHue * 0.072 - sinHue * 0.283;
    matrix[8] = 0.213 - cosHue * 0.213 - sinHue * 0.787;
    matrix[9] = 0.715 - cosHue * 0.715 + sinHue * 0.715;
    matrix[10] = 0.072 + cosHue * 0.928 + sinHue * 0.072;
    return matrix;
}

public function tintMatrix(v:FlxColor, ?reset:Bool, ?matrix:Array) {
	reset ??= true;
    var col = getRGBArray(v);
	var alpha = 1;
	if (col.lentgh > 3) alpha = col.pop();
	matrix ??= identity4x4();
	for (a in 0...col.length) {
		for (b in 0...3) {
			matrix[b + (a * 4)] = FlxMath.lerp(matrix[b + (a * 4)], col[a], alpha);
			if (reset && (b / 4) != a) matrix[b + (a * 4)] = 0;
		}
	}
    return matrix;
}

public function setAddColorMatrix(v:FlxColor, ?matrix:Array) {
    var col = getRGBArray(v);
	var alpha = 1;
	if (col.lentgh > 3) alpha = col.pop();
	matrix ??= identity4x4();
	for (a in 0...col.length) {
		matrix[((a + 1) * 4) - 1] = col[a] * alpha;
	}
    return matrix;
}

public function rimlight(i:FlxSprite) {
	var shad = new CustomShader('rimlight');
	shad.matrixA = identity4x4();
	shad.matrixB = identity4x4();
	shad.threshold = 0.1;
	shad.distance_offset = 15;
	shad.distance_angle = 90;
	shad.inner = false;
	shad.knockout = false;
	shad.smoothing = true;

    var i = i;
    if (i == null) return shad;
	if (i is FunkinSprite) i.useRenderTexture = true;
    i.shader = shad;
    i.animation.callback = function() {
        i.shader._uFrameBounds = [i.frame.uv.x,i.frame.uv.y,i.frame.uv.width,i.frame.uv.height];
        i.shader._angOffset = i.frame.angle * (Math.PI / 180);
    }
    i.animation.callback();

	return shad;
}