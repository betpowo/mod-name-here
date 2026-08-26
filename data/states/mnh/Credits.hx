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

// the same thing but without lines
var guests = [
	{
		name: 'fallback credit',
		desc: 'what have you done bruh',
		icon: '_default',
		color: '#ffffcc',
		url: 'https://betpowo.github.io/'
	}
];

var curSelected = 0;
var curSelectedGuest = 0;
var curLines = [];

function parseGuests(node) {
	guests.shift(); // remove fallback
	for (l in node.elementsNamed('credit')) {
		guests.push({
			name: l.get('name') ?? '???',
			desc: StringTools.replace(l.get('desc') ?? 'nothing?', '\\n', '\n'),
			icon: l.get('icon') ?? '_default',
			color: l.get('color') ?? '#717171',
			url: l.get('url') ?? 'https://betpowo.github.io/'
		});
	}
}

var guestGroup = new FlxSpriteGroup();

function create() {
	FlxG.camera.bgColor = 0;
	shit = new FlxBackdrop(FlxGridOverlay.createGrid(1, 1, 2, 2, true, 0, 0xFF030600));
	shit.scale.set(60, 60);
	shit.updateHitbox();
	shit.screenCenter();
	shit.scrollFactor.set(0.4, 0.4);
	shit.velocity.y = 16;
	shit.blend = BlendMode.SUBTRACT;
	add(shit);

	var xmlPath = Paths.xml('config/credits');
	var xml = null;

	try {
		xml = Xml.parse(Assets.getText(xmlPath)).firstElement();

		for (node in xml.elements()) {
			if (node.nodeName == 'menu') {
				parseGuests(node);
				continue;
			}
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
	creds.push(guests);

	nameTxt = new FunkinText(0, 0, FlxG.width, 'a', 48);
	nameTxt.font = Paths.font('sillyfont.ttf');
	nameTxt.borderSize = 0;
	nameTxt.color = 0x660033;
	nameTxt.borderColor = 0x00010057;
	add(nameTxt);

	descTxt = new FunkinText(0, 0, 350, 'a', 24);
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
	var leg = creds.length;
	brah.onDraw = (b) -> {
		brah.x -= (brah.width + 10) * leg;
		for (i in 0...leg) {
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
	ohmygodbruh.blend = BlendMode.SUBTRACT;
	ohmygodbruh.color = 0x4d7f3a;
	ohmygodbruh.antialiasing = true;

	guestTitle = new Alphabet(FlxG.width * 0.5 - 100, 75, translate('mnh.misc.guestTitle'), 'silly');
	guestTitle.scale.set(0.8, 0.8);
	guestTitle.updateHitbox();
	add(guestTitle);
	guestTitle.visible = false;

	import funkin.menus.ui.effects.WaveEffect;
	var effect = new WaveEffect(0, 4, 7);
	effect.speed = 4;
	guestTitle.effects.push(effect);

	import funkin.menus.ui.effects.ColorWaveEffect;

	var effect = new ColorWaveEffect(0xcccccc, 0xffffff, 3);
	effect.speed = 4;
	guestTitle.effects.push(effect);
	var gm = new CustomShader('gradientMap');
	gm.black = [0, 0, 0, 1];
	gm.white = [1, 1, 1, 1];
	gm.mult = 1;
	guestTitle.shader = gm;

	add(guestGroup);

	for (x => i in guests) {
		var nameContainer = new FlxSpriteGroup();
		guestGroup.add(nameContainer);

		var name = new Alphabet(0, 0, i.name, 'silly');
		name.scale.set(0.7, 0.7);
		name.updateHitbox();
		nameContainer.add(name);

		var size = 90;
		var icon = new FunkinSprite();
		icon.loadSprite(Paths.image('credits/' + i.icon));
		icon.antialiasing = true;
		CoolUtil.setUnstretchedGraphicSize(icon, size, size);
		icon.x = (icon.width * -1) - 12;
		icon.y = ((name.textHeight * name.scale.y) - icon.height) * 0.5;
		nameContainer.add(icon);

		nameContainer.x = FlxG.width * 0.5;
		nameContainer.y = 160 + x * 70;
		nameContainer.ID = x;
	}

	changeSelection(0);
	var data = creds[curSelected];
	if (data.color != null) {
		dump.color = FlxColor.fromString(data.color);
	}

	remove(ohmygodbruh);
	insert(members.indexOf(bubble) + 1, ohmygodbruh);
	ohmygodbruh.x = bubble.x + bubble.width - ohmygodbruh.width - 50;
	ohmygodbruh.y = bubble.y + bubble.height - ohmygodbruh.height - 50;

	CoolUtil.playMusic(Paths.music('misc/wacky'));
	FlxG.sound.music.volume = 0;
	FlxG.sound.music.fadeIn(0.2, 0, 0.6);
	FlxG.sound.music.pitch = 1; // ???
}

var canDoShit = true;
var deltaX:Float = 0;
var deltaY:Float = 0;

function update(elapsed) {
	if (!canDoShit)
		return;

	deltaX = FlxG.mouse.deltaX;
	deltaY = FlxG.mouse.deltaY;

	// trace(deltaX);
	// trace(deltaY);

	if ((controls.UP_P && !inGuests) || controls.LEFT_P || flickingLeft(elapsed)) {
		change(-1);
	}
	if ((controls.DOWN_P && !inGuests) || controls.RIGHT_P || flickingRight(elapsed)) {
		change(1);
	}
	if (inGuests) {
		changeSelectionGuest(controls.DOWN_P ? 1 : (controls.UP_P ? -1 : 0));
		var col = dump.color;
		guestTitle.shader.black = [
			((col >> 16 & 0xff) / 2) / 255,
			((col >> 8 & 0xff) / 3) / 255,
			((col >> 0 & 0xff) / 2) / 255,
			1
		];
		if (guestGroup.exists) {
			for (k => v in guestGroup.members) {
				var neg = Conductor.curBeat % 2 == 0 ? -1 : 1;
				v.members[1].angle = lerp(v.members[1].angle,
					k == curSelectedGuest ? FlxMath.lerp(-neg, neg, FlxEase.elasticOut(Conductor.curBeatFloat - Conductor.curBeat)) * 5 : 0, 0.3);
			}
		}
	}
	var intendedCursor = FlxG.mouse.overlaps(buttonHitbox) ? 'button' : 'arrow';
	if (Mouse.cursor != intendedCursor)
		Mouse.cursor = intendedCursor;

	var mousePressed = FlxG.mouse.justReleased; // trolled
	if (flickingLeft(elapsed) || flickingDown(elapsed) || flickingUp(elapsed) || flickingRight(elapsed))
		mousePressed = false;
	if (FlxG.keys.justPressed.Z || FlxG.mouse.overlaps(buttonHitbox) && mousePressed) {
		var data = creds[curSelected];
		if (inGuests)
			data = data[curSelectedGuest];
		if (data != null) {
			if (data.url != null) {
				CoolUtil.openURL(data.url);
				mousePressed = false;
			}
		}
	}
	FlxG.camera.bgColor = (dump.color & 0xffffff) + 0xff000000;
	if ((controls.ACCEPT || mousePressed) && !inGuests) {
		advance();
	}
	if (image.animation.name == 'open' && image.animation.finished) {
		image.animation.play('idle', true);
	}
	if (controls.BACK) {
		Mouse.cursor = 'arrow';
		persistentUpdate = true;
		canDoShit = false;
		CoolUtil.playMenuSFX(2).persist = true;
		FlxG.sound.music.stop();
		FlxG.switchState(new MainMenuState());
	}
	/*if (controls.LEFT)
			scrollTxt.angle -= elapsed * 36;
		if (controls.RIGHT)
			scrollTxt.angle += elapsed * 36;
		nameTxt.text = 'angle: ' + scrollTxt.angle; */
}

// yanderedev moment
var mouseThreshold = 5000;

function flickingLeft(elapsed) {
	return !FlxG.mouse.justPressed && FlxG.mouse.pressed && deltaX > mouseThreshold * elapsed;
}

function flickingDown(elapsed) {
	return !FlxG.mouse.justPressed && FlxG.mouse.pressed && deltaY < -mouseThreshold * elapsed;
}

function flickingUp(elapsed) {
	return !FlxG.mouse.justPressed && FlxG.mouse.pressed && deltaY > mouseThreshold * elapsed;
}

function flickingRight(elapsed) {
	return !FlxG.mouse.justPressed && FlxG.mouse.pressed && deltaX < -mouseThreshold * elapsed;
}

var closing = false;
var dump = new FunkinSprite();

function change(ch, ?guestMode) {
	guestMode ??= false;
	if (reading || closing)
		return;

	var lastSel = curSelected;
	var lastGuests = inGuests;
	curSelected = FlxMath.wrap(curSelected + ch, 0, creds.length - 1);
	inGuests = curSelected == creds.length - 1;

	if (inGuests && (lastSel == curSelected))
		changeSelectionGuest(0, true);
	CoolUtil.playMenuSFX(0, 0.7);
	var data = inGuests ? creds[curSelected][curSelectedGuest] : creds[curSelected];
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

var inGuests = false;

function changeSelectionGuest(ch, ?force) {
	force ??= false;
	if (!guestGroup.exists || (ch == 0 && !force))
		return;
	curSelectedGuest = FlxMath.wrap(curSelectedGuest + ch, 0, creds[creds.length - 1].length - 1);
	var data = creds[curSelected][curSelectedGuest];
	CoolUtil.playMenuSFX(0, 0.7);
	if (data.color != null) {
		FlxTween.cancelTweensOf(dump);
		FlxTween.color(dump, 0.4, dump.color, FlxColor.fromString(data.color));
	}
	guestGroup.forEach((g) -> {
		g.alpha = curSelectedGuest == g.ID ? 1 : 0.6;
	});
	nameTxt.text = data.name;
	descTxt.text = data.desc;
	var textWidth = nameTxt.textField.textWidth;

	var factor = Math.min(1, 325 / textWidth);
	nameTxt.scale.set(factor, factor);
	nameTxt.updateHitbox();

	descTxt.y = Std.int(nameTxt.y + nameTxt.height - 15);
}

function changeSelection(cha) {
	closing = false;
	guestGroup.exists = guestTitle.visible = inGuests;

	if (inGuests) {
		curSelectedGuest = -1;
		changeSelectionGuest(1);
		image.visible = bubble.visible = ohmygodbruh.visible = text.visible = spkTxt.visible = false;
		nameTxt.text = creds[curSelected][curSelectedGuest].name;
		descTxt.text = creds[curSelected][curSelectedGuest].desc;
		return;
	} else {
		image.visible = bubble.visible = ohmygodbruh.visible = text.visible = spkTxt.visible = true;
		curSelectedGuest = 0;
	}
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

	nameTxt.text = data.name ?? 'unknown';
	descTxt.text = data.desc ?? 'no description provided';
	spkTxt.text = data.speakerName;
	var textWidth = nameTxt.textField.textWidth;
	
	var factor = Math.min(1, 325 / textWidth);
	nameTxt.scale.set(factor, factor);
	nameTxt.updateHitbox();
	
	curLines = data.lines.copy();
	firstLine = true;
	reading = false;
	advance();

	descTxt.y = Std.int(nameTxt.y + nameTxt.height - 15);

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
