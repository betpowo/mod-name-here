var defaultScale = 1;
var warpSpeed = 1;

function postCreate() {
	defaultScale = scale.x;
}

function update(elpased) {
	final beat = Conductor.curBeatFloat * Math.PI * warpSpeed;
	scale.x = defaultScale + (Math.cos(beat) / defaultScale);
	scale.y = defaultScale + (Math.sin(beat) / defaultScale);
}
