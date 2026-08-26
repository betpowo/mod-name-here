var self = this;
var initialX, initialY = 0;
var toAdd:Bool = true; // Using this just to make sure

function update(elapsed) {
	if (toAdd) {
		initialX = self.x;
		initialY = self.y;
	}

	if (getAnimName() == 'idle')
		idleTime += elapsed;

	var mul = elapsed * 100;
	self.x += FlxG.random.float(-mul * 1.01, mul) * Math.max(idleTime * 3, 0);
	self.y += FlxG.random.float(-mul * 1.01, mul) * Math.max(idleTime * 3, 0);

	if (!isOnScreen(camera)) {
		setPosition(initialX, initialY);
	}
}

var idleTime = -1;

function onPlaySingAnim(e) {
	idleTime = -1;
}

function onJPEGSetup(e) {
	e.cancel();
}
