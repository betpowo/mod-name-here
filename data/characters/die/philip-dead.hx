if (PlayState.instance == null) {
	return disableScript();
}

var retry = new FunkinSprite();

function postCreate() {
	var game = GameOverSubstate.instance;
	game.lossSFXName += '-pico';
	game.gameOverSong += '-pico';
	game.retrySFX += '-pico';
	
	retry.frames = this.frames;
	retry.animation.addByPrefix('idle', 'retry-text-loop', 24, true);
	retry.animation.play('idle', true);
	retry.antialiasing = true;
	retry.updateHitbox();
	retry.alpha = 0.001;

	this.animation.onFrameChange.add(function(a, b, c) {
		if (a == 'firstDeath') {
			if (b == 34) {
				retry.alpha = 1;
				retry.scale.set(1.1, 1.1);
				retry.offset.set(0, 20);
			} else if (b == 36) {
				retry.scale.set(1, 1);
				retry.offset.set();
			}
		}
	});
}

var time:Float = 0.0;
var done = false;
function postDraw(_) {
	retry.draw();
}

function update(elapsed) {
	time += elapsed;
	retry.update(elapsed);

	if (!GameOverSubstate.instance.isEnding) {
		var mid = this.getMidpoint();
		retry.setPosition(mid.x, mid.y);
		retry.x -= retry.width * .5;
		retry.y -= retry.height * .5;

		retry.x += -20;
		retry.y += 250;

		retry.y += FlxMath.fastSin(time * 1.5) * 20;
		retry.angle = FlxMath.fastSin(time * 2) * 3;
	} else {
		if (done != (done = true)) {
			onEnd();
		}
	}
}

function onEnd() {
	retry.angle = 0;
	retry.scale.set(1.3, 1.3);
	retry.y -= 40;

	retry.setColorTransform(0, 0, 0, 1, 255, 255, 210);

	new FlxTimer().start(2 / 24, (_) -> {
		retry.scale.set(1.2, 1.2);
		retry.y += 10;
		retry.setColorTransform(0.4, 0.4, 0.4, 1, 160, 200, 90);
	});
}
