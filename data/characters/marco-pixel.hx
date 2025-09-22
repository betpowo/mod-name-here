import flixel.FlxObject;

var self = this;
var playerSpr = new FunkinSprite();

var states = {
	// idle: true,  // idle
	move: false, // left, right
	crouch: false, // crouch (down)
	jump: false, // jump (up)
};

var initialX:Float = 0;

function initAnimations() {
	var fps:Float = 16;
	playerSpr.loadGraphic(Paths.image('characters/marco-pixel'), true, 32, 32);
	playerSpr.animation.add('idle', [0], fps, true);
	playerSpr.animation.add('move', [1, 2, 3], fps, true);
	playerSpr.animation.add('jump', [4], fps, true);
	playerSpr.animation.add('crouch', [5], fps, true);
	playerSpr.animation.add('kill', [6, 7] /* :D */, fps, true);
	playerSpr.animation.add('luis', [8], fps, true);
	playerSpr.animation.add('stare', [9, 10], fps, false);

	playerSpr.animation.play('idle', true);

	playerSpr.scale.set(6, 6);
	playerSpr.updateHitbox();
}

function postCreate() {
	initAnimations();

	// playerSpr.moves = true;
	playerSpr.acceleration.set(0, 4000);
	playerSpr.maxVelocity.x = 300;
	playerSpr.drag.x = 3200;
	playerSpr.colorTransform = this.colorTransform;

	/*alpha = 0.001;
		scale.set(0, 0); */
}

var toAdd:Bool = true; // Using this just to make sure
var groundLevel = 0.0;
var __lastX = 0;

function update(elapsed) {
	initialX = Math.round(self.x + self.globalOffset.x + (self.width * 0.5));
	if (__lastX != initialX) {
		__lastX = initialX;

		inPosition = false;
	}
	if (toAdd) {
		toAdd = false;

		playerSpr.setPosition(initialX, self.y + self.globalOffset.y);
		playerSpr.y = -500;
		groundLevel = self.y + self.height + self.globalOffset.y - 30;
	}

	playerSpr.scrollFactor.set(self.scrollFactor.x, self.scrollFactor.y);
	playerSpr.update(elapsed);

	// using this as an "apply physics" variable
	// keeping "moves" as false cus then it would updateMotion twice
	if (!playerSpr.skipNegativeBeats) {
		updateState(elapsed);
		updatePhysics(elapsed);
	}
}

function onPlaySingAnim(e) {
	// playerSpr.angle = 45;
	// trace(e.animName);
	switch (e.animName) {
		case 'singLEFT':
			onHitLeft();
		case 'singDOWN':
			onHitDown();
		case 'singUP':
			onHitUp();
		case 'singRIGHT':
			onHitRight();
	}
}

/*
	⚫⚫🟣⚫⚫
	⚫🟣🟣🟣🟣
	🟣🟣🟣🟣🟣
	⚫🟣🟣🟣🟣
	⚫⚫🟣⚫⚫
 */
function onHitLeft() {
	if (states.jump || !states.crouch) {
		states.move = true;
		moveTime = Conductor.stepCrochet / 500;
		moveMult = -1;
		if (!states.jump) {
			playerSpr.animation.play('move');
			playerSpr.flipX = true;
		}
		inPosition = false;
	}
}

/*
	⚫🔵🔵🔵⚫
	⚫🔵🔵🔵⚫
	🔵🔵🔵🔵🔵
	⚫🔵🔵🔵⚫
	⚫⚫🔵⚫⚫
 */
function onHitDown() {
	if (!states.jump) {
		states.crouch = true;
		crouchTime = Conductor.stepCrochet / 888;
		playerSpr.animation.play('crouch', true);
		if (states.move) {
			moveTime = 0;
		}
	}
}

/*
	⚫⚫🟢⚫⚫
	⚫🟢🟢🟢⚫
	🟢🟢🟢🟢🟢
	⚫🟢🟢🟢⚫
	⚫🟢🟢🟢⚫
 */
function onHitUp() {
	if (!states.jump) {
		states.jump = true;
		playerSpr.velocity.y = -700 * (states.crouch ? (2 / 3) : 1);
		playerSpr.y -= 3;
		if (!states.crouch)
			playerSpr.animation.play('jump', true);
	}
}

/*
	⚫⚫🔴⚫⚫
	🔴🔴🔴🔴⚫
	🔴🔴🔴🔴🔴
	🔴🔴🔴🔴⚫
	⚫⚫🔴⚫⚫
 */
function onHitRight() {
	if (states.jump || !states.crouch) {
		states.move = true;
		moveTime = Conductor.stepCrochet / 500;
		moveMult = 1;
		if (!states.jump) {
			playerSpr.animation.play('move');
			playerSpr.flipX = false;
		}
		inPosition = false;
	}
}

/*
	⚫🟡🟡🟡⚫
	🟡🟡⚫🟡🟡
	🟡⚫🟡⚫🟡
	🟡🟡⚫🟡🟡
	⚫🟡🟡🟡⚫
 */
// I HATE FLIXEL
function updatePhysics(elapsed) {
	/*playerSpr.velocity.x += (playerSpr.acceleration.x * elapsed);
		playerSpr.velocity.y += (playerSpr.acceleration.y * elapsed);

		playerSpr.x += (playerSpr.velocity.x * elapsed);
		playerSpr.y += (playerSpr.velocity.y * elapsed); */

	playerSpr.updateMotion(elapsed);

	if ((playerSpr.y + playerSpr.height) > groundLevel) {
		playerSpr.y = groundLevel - playerSpr.height;
		notifyCallback(playerSpr);
	}
}

function notifyCallback(plr) {
	if (states.jump) {
		states.jump = false;
		velocity.y = 0;
		if (!states.crouch)
			plr.animation.play(states.move ? 'move' : 'idle', true);
	}

	if (crouchTime > 0) {
		crouchTime -= FlxG.elapsed;
		if (crouchTime < 0)
			crouchTime = 0;
	} else if (crouchTime == 0) {
		crouchTime = -1;
		states.crouch = false;
		plr.animation.play(states.move ? 'move' : 'idle', true);
	}

	if (states.crouch && plr.animation.name != 'crouch') {
		plr.animation.play('crouch', true);
	}

	// trace(moveTime);
}

var idleTime:Float = 500;
var idling:Bool = true;
var inPosition:Bool = false;

function updateState(elapsed) {
	if (moveTime > 0) {
		moveTime -= elapsed * (states.jump ? 0.4 : 1);
		if (moveTime < 0)
			moveTime = 0;
	} else if (moveTime == 0) {
		moveTime = -1;
		states.move = false;
		if (!states.jump)
			playerSpr.animation.play('idle');
	}

	if (states.move) {
		playerSpr.acceleration.x = 5000 * moveMult;
	} else {
		playerSpr.acceleration.x = 0;
	}

	idling = !(states.move || states.jump || states.crouch);

	if (idling) {
		idleTime += elapsed;
		if (idleTime >= 0.6) {
			var foll:Float = elapsed * playerSpr.maxVelocity.x;
			if (playerSpr.x == initialX && !inPosition) {
				playerSpr.animation.play('idle', true);
				playerSpr.flipX = false;

				inPosition = true;
			}

			if (playerSpr.x > initialX) {
				playerSpr.x = Math.max(playerSpr.x - foll, initialX);
				playerSpr.flipX = true;
				if (playerSpr.animation.name != 'move')
					playerSpr.animation.play('move', true);
			}

			if (playerSpr.x < initialX) {
				playerSpr.x = Math.min(playerSpr.x + foll, initialX);
				playerSpr.flipX = false;
				if (playerSpr.animation.name != 'move')
					playerSpr.animation.play('move', true);
			}
		}
	} else {
		idleTime = 0;
	}

	/*PlayState.instance.camGame.focusOn(FlxPoint.weak(playerSpr.x, playerSpr.y));
		PlayState.instance.camFollow.setPosition(playerSpr.x, playerSpr.y); */
}

var crouchTime:Float = -1;
var moveTime:Float = -1;
var moveMult:Floar = 0;

function onGetCamPos(e) {
	e.x = FlxMath.lerp(e.x, playerSpr.x + (playerSpr.width * 0.5), 0.5);
	e.y = FlxMath.lerp(e.y, playerSpr.y + (playerSpr.height * 0.5), 0.5);
}

function draw(e) {
	e.cancel();
	playerSpr.draw();
}
