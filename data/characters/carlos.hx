import flixel.FlxObject;

var self = this;
var playerSpr = new FlxSprite();
var initialX, initialY = 0;

function initAnimations() {
	playerSpr.loadGraphic(Paths.image('characters/carlos'), true, 50, 50);
	playerSpr.animation.add('idle', [0], 0, true);
	playerSpr.animation.add('sing', [1, 2, 3, 4], 0, true);

	playerSpr.animation.play('idle', true);

	playerSpr.scale.set(3, 3);
	playerSpr.updateHitbox();
}

function postCreate() {
	initAnimations();
	alpha = 0.001;
	scale.set(0, 0);
}

var toAdd:Bool = true; // Using this just to make sure

function update(elapsed) {
	if (toAdd) {
		toAdd = false;
		PlayState.instance.insert(PlayState.instance.members.indexOf(self) + 1, playerSpr);
		// PlayState.instance.add(no);

		playerSpr.setPosition(self.x
			+ self.globalOffset.x
			+ (self.width * 0.5)
			- (playerSpr.width * 0.5),
			self.y
			+ self.globalOffset.y
			+ self.height
			- playerSpr.height);
		initialX = self.x;
		initialY = self.y;
	}
	// playerSpr.setPosition(self.getMidpoint().x - playerSpr.width * 0.5, self.y + self.height + self.globalOffset.y - 111);
	playerSpr.scrollFactor.set(self.scrollFactor.x, self.scrollFactor.y);

	playerSpr.setPosition(self.x
		+ self.globalOffset.x
		+ (self.width * 0.5)
		- (playerSpr.width * 0.5),
		self.y
		+ self.globalOffset.y
		+ self.height
		- playerSpr.height);

	if (playerSpr.animation.name == 'idle')
		idleTime += elapsed;

	var mul = elapsed * 100;
	self.x += FlxG.random.float(-mul * 1.01, mul) * Math.max(idleTime * 3, 0);
	self.y += FlxG.random.float(-mul * 1.01, mul) * Math.max(idleTime * 3, 0);

	if (!playerSpr.isOnScreen(camera)) {
		setPosition(initialX, initialY);
	}
}

var idleTime = -1;

function onPlaySingAnim(e) {
	playerSpr.animation.play('sing', true, false, e.direction);
	idleTime = -1;
}

function onPlayAnim(e) {
	if (e.animName == 'idle' && playerSpr.animation.name != 'idle') {
		playerSpr.animation.play('idle', true);
	}
}
