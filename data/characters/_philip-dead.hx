var retry = new FunkinSprite();

function create(e) {
	// angle += 180;
	e.lossSFX = 'fnf_loss_sfx-pico';
	e.gameOverSong = 'gameOver-pico';
	e.retrySFX = 'gameOverEnd-pico';
}

function postCreate() {
	retry.frames = character.frames;
	retry.animation.addByPrefix('idle', 'retry-text-loop', 24, true);
	retry.animation.play('idle', true);
	retry.antialiasing = true;
	retry.updateHitbox();
	insert(900, retry);
	retry.alpha = 0.001;

	character.animation.callback = function(a, b, c) {
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
	}
}

var time:Float = 0.0;

function update(elapsed) {
	time += elapsed;

	if (!isEnding) {
		var mid = character.getGraphicMidpoint();
		retry.setPosition(mid.x, mid.y);
		retry.x -= retry.width * .5;
		retry.y -= retry.height * .5;

		retry.x += -20;
		retry.y += 250;

		retry.y += FlxMath.fastSin(time * 1.5) * 20;
		retry.angle = FlxMath.fastSin(time * 2) * 3;
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
