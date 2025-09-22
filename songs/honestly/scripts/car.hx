// playCutscenes = true;

var strums = strumLines.members[3];
var car = strums.characters[0];
var yeeted = false;
var ballsShader = new FunkinShader('
    #pragma header
    
    uniform vec2 offset;
    uniform float coolMix;
	float _min(float a, float b) {
		if (b < a) return b;
		return a;
	}
    void main()
    {
        if (coolMix <= 0.0) {
			gl_FragColor = textureCam(bitmap, getCamPos(openfl_TextureCoordv));
			return;
		}
        vec4 dump_FragColor = gl_FragColor;

        vec4 ogcolor = textureCam(bitmap, getCamPos(openfl_TextureCoordv));
        ogcolor = mix(ogcolor, textureCam(bitmap, getCamPos(openfl_TextureCoordv + vec2(0.01, 0.0))), 0.5);
        ogcolor.b *= 4.0;

        vec4 color = vec4(0.0);
        color = mix(ogcolor * 4.0, floor(ogcolor * 2.0), 0.6);
        color = mix(color, textureCam(bitmap, getCamPos(openfl_TextureCoordv + offset)), 0.2);
        gl_FragColor = color;
        gl_FragColor = mix(gl_FragColor, gl_FragColor + dump_FragColor, 0.2);
        gl_FragColor = mix(textureCam(bitmap, getCamPos(openfl_TextureCoordv)), gl_FragColor, (_min((getCamPos(openfl_TextureCoordv).x * 1.4) + 0.2, 1.5)) * coolMix);
    }
');
var cake = new FlxSprite(1400, 600);

cake.frames = Paths.getFrames('dialogue/cake');
cake.animation.addByPrefix('idle', 'cake', 12, true);
cake.animation.play('idle', true);
cake.antialiasing = true;
if (PlayState.difficulty != 'normal')
	playCutscenes = true;
function postCreate() {
	car.x += 1800;
	strums.cameras = [camGame];
	for (i in strums.members) {
		i.scrollFactor.set(1, 1);
		i.setPosition(i.x + 60, i.y + 420);
		FlxTween.cancelTweensOf(i);
		i.alpha = 1;
	}

	camGame.addShader(ballsShader);
	ballsShader.coolMix = 0;
	ballsShader.offset = [0, 0];

	add(cake);
	cake.draw();
	cake.visible = false;

	dad.scripts.call('initLaser');
}

function postUpdate() {
	if (!yeeted) {
		for (i in strums.members) {
			i.setPosition(car.x + car.globalOffset.x + (Note.swagWidth * i.ID * strums.strumScale) - 70, car.y + car.globalOffset.y - 100);
		}
	} else {
		if (ballsShader.coolMix > 0) {
			ballsShader.offset = [FlxG.random.float(-1, 1) * 0.05, FlxG.random.float(-1, 1) * 0.05];
		}
	}
}

function theguyinthecar() {
	FlxTween.tween(car, {x: car.x - 1550}, 3, {ease: FlxEase.expoOut});
	new FlxTimer().start(1.0, (_) -> {
		boyfriend.flipX = !boyfriend.flipX;
		boyfriend.swapLeftRightAnimations();
	});
}

function killhim() {
	yeeted = true;

	car.playAnim('die', true);
	car.moves = true;
	car.velocity.x = 126;

	camGame.shake(0.005, 1.5);
	camHUD.shake(0.0025, 1.5);

	curCameraTarget = -1;

	for (i in strums.members) {
		i.moves = true;
		i.acceleration.y = 600;
		i.velocity.set(FlxG.random.float(200, 800), FlxG.random.float(-250, -500));
		i.angularVelocity = FlxG.random.float(-1, 1) * 30;
		i.noteAngle = 0;
	}

	ballsShader.coolMix = 1;

	FlxTween.num(ballsShader.coolMix, 0, 4, {startDelay: 1, ease: FlxEase.sineOut}, (num) -> {
		ballsShader.coolMix = num;
	});
	new FlxTimer().start(1.8, (_) -> {
		boyfriend.flipX = !boyfriend.flipX;
		boyfriend.swapLeftRightAnimations();
	});

	dad.script.get('laser').angle = -3;
	dad.scripts.call('shoot');
}

function toggleCake() {
	cake.visible = !cake.visible;
}
