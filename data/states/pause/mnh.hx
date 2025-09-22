import openfl.display.BlendMode;
import funkin.ui.FunkinText;
import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle;
import flixel.util.FlxAxes;
var pixelScript:Script;
var pauseCam = new FlxCamera();
var bg:FlxSprite;
var paper = [new FlxSprite(), new FlxSprite()];
var texts:Array<FlxText> = [];
var songColor = CoolUtil.getColorFromDynamic(PlayState.SONG.meta.color ?? '#717171');
var whiteColor = 0xffffff;
var blackColor = 0x000000;

function red(col) {
	return (col >> 16) & 0xff;
}

function green(col) {
	return (col >> 8) & 0xff;
}

function blue(col) {
	return (col & 0xff);
}

function col232(col) {
	return (col & 0xffffff) + 0xff000000;
}

var col = songColor;
var luminance = (0.2126 * (red(col) / 255) + 0.7152 * (green(col) / 255) + 0.0722 * (blue(col) / 255));
var brightestLuminance:Float = 2 / 3;
var dark = luminance >= brightestLuminance;

function create(event) {
	// cancel default pause menu!!
	event.cancel();
	event.music = 'breakfast-mnh';

	whiteColor = FlxColor.interpolate(songColor, FlxColor.WHITE, 0.9);
	blackColor = FlxColor.interpolate(songColor, FlxColor.BLACK, 0.75);
	blackColor = FlxColor.fromRGB(Std.int(red(blackColor) * (7 / 3)), Std.int(green(blackColor) * (5 / 3)), Std.int(blue(blackColor) * (9 / 3)), 255);

	cameras = [];

	// pixelScript = game.scripts.getByName("pixel.hx");
	// pixelScript.call("pixelCam", [pauseCam]);

	FlxG.cameras.add(pauseCam, false);
	pauseCam.bgColor = 0;

	bg = new FlxSprite().makeSolid(pauseCam.width, pauseCam.height, getInverted(FlxColor.interpolate(songColor, 0xff443344, 2 / 3)));
	bg.cameras = [pauseCam];
	bg.blend = BlendMode.SUBTRACT;
	add(bg);

	for (a => b in ['bottom', 'top']) {
		var pap = paper[a];
		add(pap);
		pap.frames = Paths.getSparrowAtlas('ui/mnh/pause');
		pap.animation.addByPrefix('idle', b, 3, true);
		pap.animation.play('idle', true);
		pap.updateHitbox();
		pap.setPosition(0, FlxG.height - pap.height);
		pap.color = FlxColor.interpolate(dark ? blackColor : whiteColor, songColor, 0.3);
	}

	var i = 0;
	for (e in menuItems) {
		text = new FlxText(0, (FlxG.height - 50 - (menuItems.length * 60)) + (i * 60), 0, ' ' + e.toLowerCase(), 50, false);
		confText(text);
		add(text);
		texts.push(text);
		text.angle = 3;
		text.ID = i;
		if (mobile) {
			text.angle = 0;
			text.size *= 1.5;
			text.borderSize *= 1.5;
			text.y = (FlxG.height - 80 - (menuItems.length * 72)) + (i * 72);
			text.updateHitbox();
			text.origin.x = 0;
		}
		i++;
	}
	songText = new FlxText(0, 7, -1, PlayState.SONG.meta.displayName.toLowerCase(), 80, false);
	confText(songText);
	songText.alignment = 'right';
	add(songText);
	songText.color = songColor;

	var composer = 'Unknown';
	if (PlayState.SONG.meta.customValues != null && PlayState.SONG.meta.customValues.composer != null) {
		composer = PlayState.SONG.meta.customValues.composer;
	}

	compText = new FlxText(0, 40, -1, composer.toLowerCase(), 30, false);
	confText(compText);
	compText.alignment = 'right';
	add(compText);
	compText.color = dark ? whiteColor : blackColor;

	deathText = new FlxText(0, 100, -1, '(' + PlayState.deathCounter + ' fails)', 30, false);
	confText(deathText);
	deathText.alignment = 'right';
	add(deathText);
	deathText.color = 0xff3366;

	for (i in [songText, compText, deathText]) {
		i.borderColor = dark ? blackColor : whiteColor;
		i.x = FlxG.width - i.width - 50;
	}
	compText.x -= songText.width + 10;
	paper[1].x = compText.x - 50;
	paper[1].y = 0;

	cameras = [pauseCam];
	changeSelection(0);

	enterAnim();
}

function confText(text) {
	text.font = Paths.font('sillyfont.ttf');
	text.updateHitbox();
	text.x = 30;
	text.borderSize = 3.5;
	text.borderStyle = FlxTextBorderStyle.OUTLINE;
	text.color = songColor;
	text.borderColor = dark ? blackColor : whiteColor;
	text.origin.x = 0;
	text.antialiasing = true;
}

function destroy() {
	if (FlxG.cameras.list.contains(pauseCam))
		FlxG.cameras.remove(pauseCam);
}

var canDoShit = true;
var time:Float = 0;

function update(elapsed) {
	// pixelScript.call("postUpdate", [elapsed]);

	time += elapsed;

	if (!canDoShit)
		return;
	var oldSec = curSelected;
	if (controls.DOWN_P)
		changeSelection(1);
	if (controls.UP_P)
		changeSelection(-1);

	if (mobile) {
		var overlapping = false;
		var screen = FlxG.mouse.getScreenPosition(pauseCam);
		if (screen.y >= texts[0].y && screen.x <= FlxG.width * 0.5) {
			overlapping = true;
			var target = Math.min(texts.length - 1, Math.floor((screen.y - texts[0].y + 10) / (texts[0].size)));
			if (curSelected != target) {
				curSelected = 0;
				changeSelection(target);
			}
		}
		screen.put();
		/*for (i in texts) {
			if (FlxG.mouse.overlaps(i, pauseCam)) {
				curSelected = 0;
				changeSelection(i.ID);
				overlapping = true;
				break;
			}
		}*/
		if (!overlapping && curSelected != -1) {
			curSelected = -1;
		}
	}

	if (oldSec != curSelected && curSelected != -1) {
		CoolUtil.playMenuSFX();
	}

	if (controls.ACCEPT || (mobile && (curSelected != -1 && FlxG.mouse.justReleased))) {
		canDoShit = false;
		FlxG.sound.play(Paths.sound('pixel/clickText'));
		var option = menuItems[curSelected];
		if (option == 'Change Controls') {
			selectOption();
			canDoShit = true;
			return;
		}
		new FlxTimer().start(exitAnim(), (_) -> selectOption());
	}
}

var curText:FlxText;

function changeSelection(change) {
	curSelected += change;

	if (curSelected < 0)
		curSelected = menuItems.length - 1;
	if (curSelected >= menuItems.length)
		curSelected = 0;

	if (curText != null) {
		FlxTween.cancelTweensOf(curText.scale);
		FlxTween.tween(curText.scale, {x: 1, y: 1}, 0.5, {ease: FlxEase.elasticOut});
	}
	swap();
	curText = texts[curSelected];
	swap();
	if (curText != null) {
		FlxTween.cancelTweensOf(curText.scale);
		FlxTween.tween(curText.scale, {x: 1.2, y: 1.2}, 0.4, {ease: FlxEase.elasticOut});
	}
}

function swap() {
	if (curText != null) {
		var col = curText.color;
		curText.color = curText.borderColor;
		curText.borderColor = (col & 0xffffff) + 0xff000000; // preserve alpha value
	}
}

function getInverted(inp) {
	var out = ((FlxColor.WHITE - inp) & 0xffffff) + (inp & 0xff000000);
	return out;
}

function stepped(st = 5) {
	var steps = st;
	return (t) -> {
		return Math.floor(t * steps) / steps;
	}
}

function enterAnim() {
	for (i in [songText, compText, deathText, paper[1]]) {
		var ogx = i.x;
		i.x += songText.width + compText.width + 110;
		FlxTween.tween(i, {x: ogx}, 0.25, {ease: stepped(8), startDelay: 0.2});
	}

	for (i in texts) {
		var ogx = i.x;
		i.x -= FlxG.width / 2;
		FlxTween.tween(i, {x: ogx}, 0.25, {ease: stepped(8)});
	}

	var bottom = paper[0];
	bottom.x -= FlxG.width / 2;
	FlxTween.tween(bottom, {x: 0}, 0.25, {ease: stepped(8)});

	bg.alpha = 0;
	FlxTween.tween(bg, {alpha: 1}, 0.1, {ease: stepped(9), startDelay: 0.15});
}

function exitAnim() {
	for (i in [songText, compText, deathText, paper[1]]) {
		FlxTween.cancelTweensOf(i, ['x']);
		FlxTween.tween(i, {x: (i.x + songText.width + compText.width + 110)}, 0.1, {ease: stepped(6)});
	}

	for (i in texts) {
		FlxTween.cancelTweensOf(i, ['x']);
		FlxTween.tween(i, {x: (i.x - FlxG.width)}, 0.1, {ease: stepped(6), startDelay: 0.2});
	}

	FlxTween.cancelTweensOf(paper[0], ['x']);
	FlxTween.tween(paper[0], {x: (paper[0].x - FlxG.width)}, 0.25, {ease: stepped(6), startDelay: 0.2});

	FlxTween.cancelTweensOf(bg, ['alpha']);
	FlxTween.tween(bg, {alpha: 0}, 0.2, {ease: stepped(9), startDelay: 0.15});

	return 0.4;
}