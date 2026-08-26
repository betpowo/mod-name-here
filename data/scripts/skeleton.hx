var skeleton = new FunkinSprite();
var yeah = FlxG.sound.load(Paths.music('skeletonBGSound'), 0.5);
var peakPoint = 0;
function postCreate() {
	skeleton.loadGraphic(Paths.image('did you guys see that'), true, 148, 200);
	skeleton.animation.add('run', [for (i in 0...11) i], 33, true);
	skeleton.playAnim('run', true);
	skeleton.scale.set(3, 3);
	skeleton.updateHitbox();
	skeleton.setSize(0, 0);
	skeleton.frameOffset.set(skeleton.frameWidth * 0.5, skeleton.frameHeight * 0.5);
	skeleton.screenCenter();
	skeleton.scrollFactor.y = 0.0;
	add(skeleton);

	peakPoint = inst.length * FlxG.random.float(0.5, 0.9);
}
function onSongStart() {
	yeah.play();
	yeah.looped = true;
	yeah.volume = 0;

	// ???
	inst.pan = 0;
	for (i in strumLines.members) {
		if (i.vocals != null) i.vocals.pan = 0;
	}
	vocals?.pan = 0;
}
var trackedBPM = -1;
function update(elapsed) {
	skeleton.x = ((Conductor.songPosition - peakPoint) * 1.5) + camGame.width * 0.5;
	if (yeah.playing) {
		if (trackedBPM != (trackedBPM = Conductor.bpm)) {
			yeah.pitch = trackedBPM / 105;
			// todo: resync
		}

		var screenDistX = skeleton.x - (camGame.scroll.x * skeleton.scrollFactor.x);
		screenDistX -= camGame.width * 0.5;
		screenDistX /= camGame.width * 0.5;
		yeah.pan = screenDistX * 0.67;
		yeah.volume = (1 - Math.abs(screenDistX * 0.3)) * 0.67;
	}
}