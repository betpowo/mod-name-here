function postCreate() {
	dad.scale.set(0.02, 0.1);
	dad.y += 180;
	cpuStrums.cameras = [camGame];
	for (i in cpuStrums.members) {
		i.scrollFactor.set(1, 1);
		i.setPosition(i.x + 60, i.y + 420);
		FlxTween.cancelTweensOf(i);
		i.alpha = 1;
	}
}

var spin = false;

function speen() {
	spin = !spin;
}

function update(elapsed) {
	if (spin)
		camGame.angle += elapsed * 4000;
	else
		camGame.angle = 0;
}

function do144p() {
	boyfriend.shader = new CustomShader('jpeg');
}
