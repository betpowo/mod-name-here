import openfl.display.BlendMode;
import funkin.ui.FunkinText;
import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle;
import flixel.util.FlxAxes;
var pixelScript:Script;
var pauseCam = new FlxCamera();
var bg:FlxSprite;
var texts:Array<FlxText> = [];

function create(event) {
	// cancel default pause menu!!
	event.cancel();

	if (PlayState.difficulty.toLowerCase() == 'pico')
		event.music = 'breakfast-pico';

	cameras = [];

	// pixelScript = game.scripts.getByName("pixel.hx");
	// pixelScript.call("pixelCam", [pauseCam]);

	FlxG.cameras.add(pauseCam, false);
	pauseCam.bgColor = 0;

	bg = new FlxSprite().makeSolid(pauseCam.width, pauseCam.height, 0xFF000000);
	bg.cameras = [pauseCam];
	bg.alpha = 0.6;
	add(bg);

	for (i => v in menuItems) {
		var t = new FunkinText();
		var pixelSize = 8;
		t.size = 40;
		t.setPosition(20, (FlxG.height - (menuItems.length * t.size * 2)) + (50 + ((t.size + (t.size / pixelSize)) * i)));
		t.text = ' ' + v.toLowerCase();
		t.font = Paths.font('pixel.otf');
		texts.push(t);
		t.borderStyle = FlxTextBorderStyle.SHADOW;
		t.borderColor = 0xFFff0000;
		t.shadowOffset.set(t.size / pixelSize, t.size / pixelSize);
		add(t);

		unselectedFormat(t);
	}
	var songText = new FlxText(0, 7, FlxG.width, PlayState.SONG.meta.displayName, 80, false);
	songText.font = Paths.font('comic.ttf');
	songText.alignment = 'right';
	songText.updateHitbox();
	add(songText);

	var composer = 'Unknown';
	if (PlayState.SONG.meta.customValues != null && PlayState.SONG.meta.customValues.composer != null) {
		composer = PlayState.SONG.meta.customValues.composer;
	}

	compText = new FlxText(0, 0, FlxG.width, composer, 30, false);
	compText.font = Paths.font('comic.ttf');
	compText.alignment = 'right';
	add(compText);

	deathText = new FlxText(0, 0, FlxG.width, 'epic fails x' + PlayState.deathCounter, 30, false);
	deathText.font = Paths.font('comic.ttf');
	deathText.alignment = 'right';
	add(deathText);
	deathText.color = CoolUtil.getColorFromDynamic(PlayState.SONG.meta.color);

	compText.y = songText.y + songText.height - 25;
	deathText.y = compText.y + compText.height + 5;

	cameras = [pauseCam];
	changeSelection(0);
}

function unselectedFormat(t) {
	t.color = 0xffffff;
	t.shadowOffset.set(0, 0);
}

function selectedFormat(t) {
	var pixelSize = 8;
	t.color = 0xffff00;
	t.shadowOffset.set(t.size / pixelSize, t.size / pixelSize);
}

function destroy() {
	if (FlxG.cameras.list.contains(pauseCam))
		FlxG.cameras.remove(pauseCam);
}

function update(elapsed) {
	if (controls.DOWN_P)
		changeSelection(1);
	if (controls.UP_P)
		changeSelection(-1);

	if (controls.ACCEPT) {
		selectOption();
	}
}

function changeSelection(ch) {
	unselectedFormat(texts[curSelected]);
	curSelected = FlxMath.wrap(curSelected + ch, 0, menuItems.length - 1);
	selectedFormat(texts[curSelected]);

	CoolUtil.playMenuSFX(0, 0.7);
}