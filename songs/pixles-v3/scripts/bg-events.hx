if (Options.lowMemoryMode) {
    return disableScript();
}

import flixel.addons.display.FlxBackdrop;
import flixel.math.FlxAngle;

// i gave up
var bc = new FlxCamera();
var backdrop = new FlxBackdrop(Paths.image('stages/wonder-bg'));
var fuckShader = new FunkinShader('
    #pragma header
    uniform float factor;
    void main() {
        vec2 uv = openfl_TextureCoordv;
        vec4 og = flixel_texture2D(bitmap, uv);
        if (factor <= 0.0) {
            gl_FragColor = og;
            return;
        }
        vec4 color = flixel_texture2D(bitmap, uv - (vec2(0.0075, 0.015) * factor)) * vec4(0.0, 0.0, 0.0, 0.333);

		gl_FragColor = mix(color, og, og.a);
    }
');
fuckShader.data.bitmap.mipFilter = 0;
fuckShader.factor = 0;
function postCreate() {
    bc.bgColor = camGame.bgColor;
    camGame.bgColor = 0;
    bc.height = bc.width;
    bc.setPosition((FlxG.width - bc.width) * 0.5, (FlxG.height - bc.height) * 0.5);
    FlxG.cameras.insert(bc, 0, false);

    backdrop.scrollFactor.set();
    backdrop.scale.set(7, 7);
    insert(0, backdrop);
    backdrop.camera = bc;

    backdrop.alpha = 0.001;
}

function revealBackdrop() {
    camGame.addShader(fuckShader);
    FlxTween.tween(backdrop, {alpha: 0.25}, 2, {ease: FlxEase.sineOut});
    FlxTween.num(fuckShader.factor, 1, 1, {ease: FlxEase.sineOut }, (num) -> {
		fuckShader.factor = num;
	});
}

function postUpdate(elapsed) {
    bc.angle += elapsed * 3;
    var d = Conductor.songPosition * -0.09;
    backdrop.setPosition(
        Math.cos(bc.angle * FlxAngle.TO_RAD) * d,
        Math.sin(bc.angle * FlxAngle.TO_RAD) * d
    );
}