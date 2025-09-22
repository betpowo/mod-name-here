var laser = null;

function initLaser() {
	laser = new FunkinSprite(0, 0, Paths.image('dialogue/laser-asset'));
	laser.origin.x = 41;
	laser.alpha = 0.001;
	laser.active = false;
	laser.forceIsOnScreen = true;
	laser.antialiasing = true;
	PlayState.instance.insert(PlayState.instance.members.indexOf(this) + 1, laser);
}

function shoot() {
	if (laser == null)
		return;
	laser.alpha = 1;
	laser.active = true;
	FlxG.camera.flash(0xffffffff, 5, null, true);
	new FlxTimer().start(1 / 24, (_) -> {
		FlxG.camera.flash(0xff000033, 5, null, true);
		new FlxTimer().start(1 / 24, (_) -> {
			FlxG.camera.flash(0x33ccffff, 0, null, true);
		});
	});
}

var displacement = 5;
var timeFlip = 0.1;
var _t:Float = 0.0;

function update(elapsed) {
	if (laser == null)
		return;
	laser.setPosition(x + globalOffset.x - 20, y + globalOffset.y - (laser.height / 2) + 200);
	if (laser.active) {
		laser.x += FlxG.random.float(-1, 1) * displacement;
		laser.y += FlxG.random.float(-1, 1) * displacement;
		laser.frameOffsetAngle = FlxG.random.float(-1, 1) * displacement / 1.3;
		_t -= elapsed;
		if (_t <= 0) {
			laser.flipY = !laser.flipY;
			_t = timeFlip;
		}
	}
}

function onPlayAnim(e) {
	if (laser == null)
		return;
	if (['laser', 'laser-loop'].indexOf(e.animName) == -1) {
		laser.active = false;
		laser.alpha = 0.001;
	}
}
