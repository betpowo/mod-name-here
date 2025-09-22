function create() {
	camGame.bgColor = -1;
}

function postCreate() {
	for (i in [floor, ceiling, bgwall, sky]) {
		// i.makeSolid(2500, 1440, i.color);
		// i.updateHitbox();
		// i.color = 0xffffff;
		i.forceIsOnScreen = true;
	}
	couch.forceIsOnScreen = true;
	wall.origin.x = 0;
}

function update(e) {
	final skewTo = (camGame.scroll.y + (camGame.height * 0.5)) - (wall.y + wall.origin.y);
	wall.skew.y = -9 + skewTo * -0.06;
	wall.scale.x = wall.scale.y + (((camGame.scroll.x + (camGame.width * 0.5)) - (wall.x)) * -0.0005);

	mat.angle = (wall.skew.y * -33 * (Math.PI / 180)) - 10;

	// camGame.targetOffset.y += FlxG.mouse.wheel * -100;
}

function onPostGameOver() {
	FlxG.camera.bgColor = 0xFF330066;
}
