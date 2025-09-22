import flixel.addons.text.FlxTypeText;
import flixel.graphics.FlxGraphic;
import flixel.FlxObject;
import openfl.ui.Mouse;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import hxvlc.flixel.FlxVideoSprite;
import Xml;
import Sys;

var creds = [
	{
		name: 'fallback credit',
		desc: 'what have you done bruh',
		lines: [
			{
				text: 'oh my god bruh',
				anim: 'idle'
			}
		],
		icon: '_default',
		color: '#ffffcc',
		url: 'https://betpowo.github.io/'
	}
];

var curSelected = 0;
var curLines = [];
var music = FlxG.sound.load(Paths.music('misc/wacky'));

function create() {
	FlxG.camera.bgColor = 0;
	CoolUtil.playMenuSong();
	shit = new FlxBackdrop(FlxGridOverlay.createGrid(1, 1, 2, 2, true, 0, 0xFF030600));
	shit.scale.set(60, 60);
	shit.updateHitbox();
	shit.screenCenter();
	shit.scrollFactor.set(0.4, 0.4);
	shit.velocity.y = 16;
	shit.blend = 14;
	add(shit);

	var xmlPath = Paths.xml('config/credits');
	var xml = null;

	try {
		xml = Xml.parse(Assets.getText(xmlPath)).firstElement();

		for (node in xml.elements()) {
			var lines = [];
			for (l in node.elementsNamed('line')) {
				lines.push({
					text: StringTools.trim(l.firstChild().nodeValue),
					anim: l.get('anim') ?? 'idle'
				});
			}
			var anims = [];
			for (a in node.elementsNamed('anim')) {
				if (a.get('name') == null)
					continue;

				var min = Std.parseInt(a.get('offset') ?? '0');
				var max = min + Std.parseInt(a.get('length') ?? '1');

				anims.push({
					name: a.get('name'),
					frames: [for (i in min...max) i],
					loop: (a.get('loop') ?? 'true') == 'true'
				});
			}
			creds.push({
				name: node.get('name') ?? 'unknown',
				desc: node.get('desc') ?? 'what ???',
				speaker: node.get('speaker') ?? 'betty',
				speakerName: node.get('spkname') ?? node.get('speaker') ?? 'betty',
				color: node.get('color') ?? '#717171',
				x: Std.parseFloat(node.get('x') ?? '0'),
				y: Std.parseFloat(node.get('y') ?? '0'),
				url: node.get('url') ?? 'https://deltarune.com/lancer',
				anims: anims,
				lines: lines
			});
		}

		// remove fallback credit
		creds.shift();
	} catch (e:Dynamic) {
		trace('Error while parsing credits.xml: ' + Std.string(e));
	}

	nameTxt = new FunkinText(0, 0, -1, 'a', 48);
	nameTxt.font = Paths.font('sillyfont.ttf');
	nameTxt.borderSize = 0;
	nameTxt.color = 0x660033;
	nameTxt.borderColor = 0x00010057;
	add(nameTxt);

	descTxt = new FunkinText(0, 0, -1, 'a', 24);
	descTxt.font = Paths.font('sillyfont.ttf');
	descTxt.borderSize = 0;
	descTxt.color = 0x660033;
	descTxt.borderColor = 0x00010057;
	add(descTxt);
	descTxt._defaultFormat.leading = -8;
	descTxt.updateDefaultFormat();

	board = new FunkinSprite();
	board.loadSprite(Paths.image('credits/assets'));
	board.animation.addByPrefix('idle', 'board', 12, true);
	board.animation.play('idle', true);
	board.updateHitbox();
	insert(1, board);
	board.screenCenter(0x10);
	board.x = 50;

	var brah = new FunkinSprite();
	brah.antialiasing = true;
	brah.loadSprite(Paths.image('menus/separator'));
	brah.updateHitbox();
	add(brah);
	brah.setPosition(FlxG.width - brah.width - 30, 30);
	brah.onDraw = (b) -> {
		brah.x -= (brah.width + 10) * creds.length;
		for (i in 0...creds.length) {
			brah.x += brah.width + 10;
			brah.alpha = (i == curSelected) ? 1 : 0.4;
			b.draw();
		}
	};

	bubble = new FunkinSprite();
	bubble.loadSprite(Paths.image('credits/assets'));
	bubble.animation.addByPrefix('idle', 'bubble', 12, true);
	bubble.animation.play('idle', true);
	bubble.updateHitbox();
	insert(2, bubble);
	bubble.screenCenter(0x10);
	bubble.x = FlxG.width - bubble.width - 50;

	image = new FunkinSprite();
	image.loadSprite(Paths.image('credits/assets'));
	image.antialiasing = false;
	insert(3, image);

	nameTxt.setPosition(board.x + 75, board.y + board.height - 225);
	descTxt.setPosition(board.x + 75, board.y + board.height - 150);

	text = new FlxTypeText(bubble.x + 70, bubble.y + 60);
	text.color = 0xFF996666;
	text.delay = 0.04;
	text.completeCallback = () -> {
		reading = false;
	};
	text.sounds = [FlxG.sound.load(Paths.sound('mnh-dialogue'))];
	text.font = Paths.font('sillyfont.ttf');
	text.size = 36;
	insert(500, text);
	text.fieldWidth = bubble.width - 100;
	text._defaultFormat.leading = -13;
	text.updateDefaultFormat();

	spkTxt = new FunkinText(0, 0, -1, 'a', 64);
	spkTxt.font = Paths.font('sillyfont.ttf');
	spkTxt.borderSize = 5;
	spkTxt.color = 0xffffcc;
	spkTxt.borderColor = 0xFF996666;
	add(spkTxt);
	spkTxt.setPosition(bubble.x + 35, bubble.y - 20);
	spkTxt.angle = -3;

	buttonHitbox = new FlxObject(board.x + board.width - 150, board.y + (board.height - 100), 100, 100);

	board.antialiasing = bubble.antialiasing = nameTxt.antialiasing = descTxt.antialiasing = text.antialiasing = spkTxt.antialiasing = true;

	ohmygodbruh = new FunkinSprite();
	ohmygodbruh.loadSprite(Paths.image('credits/controls' + (mobile ? '-mobile' : '')));
	ohmygodbruh.blend = 14;
	ohmygodbruh.color = 0x4d7f3a;
	ohmygodbruh.antialiasing = true;

	changeSelection(0);
	var data = creds[curSelected];
	if (data.color != null) {
		dump.color = FlxColor.fromString(data.color);
	}

	remove(ohmygodbruh);
	insert(members.indexOf(bubble)+1, ohmygodbruh);
	ohmygodbruh.x = bubble.x + bubble.width - ohmygodbruh.width - 50;
	ohmygodbruh.y = bubble.y + bubble.height - ohmygodbruh.height - 50;

	FlxG.mouse.visible = true;
	music.volume = 0;
	music.looped = true;
	music.play();
	music.fadeIn(0.2, 0, 0.6);
	FlxG.sound.music.fadeOut(0.2);
	music.time = FlxG.random.int(0, music.length);
}

var canDoShit = true;

function update(elapsed) {
	if (!canDoShit)
		return;

	if (controls.UP_P || controls.LEFT_P || flickingUp(elapsed)) {
		change(-1);
	}
	if (controls.DOWN_P || controls.RIGHT_P || flickingDown(elapsed)) {
		change(1);
	}
	var intendedCursor = FlxG.mouse.overlaps(buttonHitbox) ? 'button' : 'arrow';
	if (Mouse.cursor != intendedCursor)
		Mouse.cursor = intendedCursor;

	var mousePressed = FlxG.mouse.justReleased; // trolled
	if (flickingUp(elapsed) || flickingDown(elapsed)) mousePressed = false;
	if (FlxG.keys.justPressed.Z || FlxG.mouse.overlaps(buttonHitbox) && mousePressed) {
		var data = creds[curSelected];
		if (data != null) {
			if (data.url != null) {
				CoolUtil.openURL(data.url);
				mousePressed = false;
			}
		}
	}
	FlxG.camera.bgColor = (dump.color & 0xffffff) + 0xff000000;
	if (controls.ACCEPT || mousePressed) {
		advance();
	}
	if (image.animation.name == 'open' && image.animation.finished) {
		image.animation.play('idle', true);
	}
	if (controls.BACK) {
		Mouse.cursor = 'arrow';
		persistentUpdate = true;
		canDoShit = false;
		FlxTween.tween(music, {pitch: 0}, 0.1, {
			onComplete: (_) -> {
				FlxG.switchState(new MainMenuState());
			}
		});
	}

	/*if (controls.LEFT)
			scrollTxt.angle -= elapsed * 36;
		if (controls.RIGHT)
			scrollTxt.angle += elapsed * 36;
		nameTxt.text = 'angle: ' + scrollTxt.angle; */
}
var mouseThreshold = 5000;
function flickingDown(elapsed) {
	return !FlxG.mouse.justPressed && FlxG.mouse.pressed && FlxG.mouse.deltaY < -mouseThreshold * elapsed;
}
function flickingUp(elapsed) {
	return !FlxG.mouse.justPressed && FlxG.mouse.pressed && FlxG.mouse.deltaY > mouseThreshold * elapsed;
}

var closing = false;
var dump = new FunkinSprite();
function change(ch) {
	if (reading || closing)
		return;

	curSelected = FlxMath.wrap(curSelected + ch, 0, creds.length - 1);
	CoolUtil.playMenuSFX(0, 0.7);
	var data = creds[curSelected];
	if (data.color != null) {
		FlxTween.cancelTweensOf(dump);
		FlxTween.color(dump, 0.4, dump.color, FlxColor.fromString(data.color));
	}

	if (image.animation.exists('close') && image.animation.name != 'close') {
		image.animation.play('close', true);
		closing = true;
		var cha = ch;
		image.animation.finishCallback = () -> {
			changeSelection(cha);
			image.animation.finishCallback = null;
		}
	} else {
		changeSelection(ch);
	}
}

function changeSelection(change) {
	closing = false;

	var padding = 30;
	var data = creds[curSelected];
	var speaker = (data.speaker ?? 'betty');
	var mid = board.getMidpoint();
	image.loadSprite(Paths.image('credits/speakers/' + speaker));
	for (i in data.anims) {
		image.animation.addByIndices(i.name, speaker, i.frames, '', 12, i.loop);
	}
	image.updateHitbox();
	image.setPosition(mid.x - (image.width / 2) - 60, 100 + (mid.y - image.height));
	image.x += data.x;
	image.y += data.y;
	image.antialiasing = true;
	nameTxt.fieldWidth = -1;
	descTxt.fieldWidth = -1;

	nameTxt.text = data.name ?? 'unknown';
	descTxt.text = data.desc ?? 'no description provided';
	var max = 350;
	if (nameTxt.width > max)
		nameTxt.fieldWidth = max;
	if (descTxt.width > max)
		descTxt.fieldWidth = max;
	nameTxt.updateHitbox();
	descTxt.updateHitbox();

	spkTxt.text = data.speakerName;

	curLines = data.lines.copy();
	firstLine = true;
	reading = false;
	advance();

	descTxt.y = nameTxt.y + nameTxt.height - 15;

	image.animation.play('open', true);
}

function destroy() {
	FlxG.camera.bgColor = 0;
}

var reading = false;
var firstLine = true;

function advance() {
	if (reading || closing) {
		reading = false;
		text.skip();
		return;
	}
	if (!firstLine)
		FlxG.sound.play(Paths.sound('dialogue/next'));
	firstLine = false;
	var line = curLines.shift();
	if (line == null) {
		if (bubble.visible) {
			image.animation.play('close', true);
		}
		bubble.visible = text.visible = spkTxt.visible = false;
		reading = false;
		return;
	}
	bubble.visible = text.visible = spkTxt.visible = true;
	text.resetText(line.text);
	text.start();
	reading = true;

	if (!firstLine) {
		image.animation.play(line.anim);
	}

	remove(ohmygodbruh);
	insert(members.indexOf(bubble), ohmygodbruh);
	ohmygodbruh.screenCenter();
	ohmygodbruh.x += FlxG.width * 0.2;
}
