import funkin.backend.MusicBeatState;

if (!FlxG.random.bool(1)) {
	disableScript();
	return;
}
var foxy = new FunkinSprite();
var jumpscare = FlxG.sound.load(Paths.sound('fred'));

function postCreate() {
	foxy.loadSprite(Paths.image('freeplay/foxy'));
	foxy.addAnim('a', 'jumpscare ', 19, false);
	foxy.playAnim('a');
	foxy.setGraphicSize(FlxG.width, FlxG.height);
	foxy.updateHitbox();
	foxy.antialiasing = true;
	foxy.scrollFactor.set();
	foxy.zoomFactor = 0;
	foxy.screenCenter();
	foxy.animation.finishCallback = function() {
		jumpscare.stop();
		endSong();
		MusicBeatState.skipTransIn = MusicBeatState.skipTransOut = true;
		camGame.visible = camHUD.visible = false;
	};
	foxy.camera = camHUD;

	foxy.drawComplex(camHUD);
}

function releaseHim() {
	add(foxy);
	jumpscare.play();
	inst.volume = 0;
}
