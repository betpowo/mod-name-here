import hxvlc.flixel.FlxVideoSprite;
import openfl.display.BlendMode;

if (PlayState.difficulty != 'pico') {
	disableScript();
} else {
	playCutscenes = true;
}
var pico = new FlxSprite(0, 0, Paths.image('picoPiss'));

pico.setGraphicSize(FlxG.width, FlxG.height);
pico.screenCenter();
function postCreate() {
	pico.camera = camHUD;
	insert(0, pico);
	pico.alpha = 0.001;

	video = new FlxVideoSprite();
	video.load(Paths.file('songs/bruj/pico-end-cutscene.mp4'));
	insert(0, video);
	video.scrollFactor.set();
	// trace(Reflect.fields(video.bitmap));
	video.bitmap.onFormatSetup.add(() -> {
		video.setGraphicSize(FlxG.width, FlxG.height);
		video.updateHitbox();
		video.screenCenter();
	});
	video.bitmap.onEndReached.add(() -> {
		endSong();
	});
	video.autoVolumeHandle = false;
	video.camera = camHUD;
}

var time = 0.0;

function boom() {
	zoomOffsets[0] += 0.07;
	zoomOffsets[1] += 0.12;
	pico.alpha = 1;
	pico.flipX = FlxG.random.bool(33);
	pico.flipY = FlxG.random.bool(33);
	time = -0.4;
	defaultCamZoom += 0.05;
	defaultHudZoom += 0.03;
}

function update(elapsed) {
	time += elapsed;
	pico.alpha = Math.max(pico.alpha - (elapsed * time), 0.001);
}

var seen = false;

function onSongEnd(e) {
	if (seen)
		return;

	e.cancel();
	video.play();

	inCutscene = true;
	seen = true;
}
