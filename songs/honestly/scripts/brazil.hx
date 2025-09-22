if (PlayState.difficulty != 'normal') {
	disableScript();
}

var enabled = false;
var ccShader = new CustomShader('adjustColor');
var vig = new FunkinShader('
#pragma header

void main() {
    vec2 uv = getCamPos(openfl_TextureCoordv);
    vec2 dest = vec2(0.5, 0.5);

    gl_FragColor = textureCam(bitmap, uv);

    float d = distance(mix(uv, dest, -0.2), dest);
    d = 1.0 - (1.0 - (d * d));

    gl_FragColor.rgb -= d;
}
');
function brazil() {
    enabled = !enabled;
    if (!Options.gameplayShaders) {
        enabled = false;
        return;
    }
    if (enabled) {
        camGame.addShader(ccShader);
        camGame.addShader(vig);
        ccShader.saturation = -80;
        ccShader.brightness = -50;
        ccShader.contrast = 200;
    } else {
        camGame.removeShader(ccShader);
        camGame.removeShader(vig);

        for (i in [camGame, camHUD]) {
            i.setPosition(0, 0);
            i.angle = 0;
        }
    }
}

function update(elapsed) {
    if (enabled) {
        var offset = FlxPoint.get(0, 1);
        offset.length = (zoomOffsets[1] * 40) + (defaultCamZoom / 1.3);
        for (i in [camGame, camHUD]) {
            offset.degrees = FlxG.random.float(-180, 180);
            i.x = offset.x * 4;
            i.y = offset.y * 4;
            i.angle = FlxG.random.float(-1, 1) * (offset.length * 0.75);
        }
        offset.put();
    }
}