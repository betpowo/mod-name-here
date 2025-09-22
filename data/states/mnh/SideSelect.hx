import Xml;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import funkin.savedata.HighscoreChange;

var pauseCam = new FlxCamera();
var conchetumadre = [];
var selected = 0; // 0: solo, 1: opp
var inCoop = false;
var modeSpr = new FlxSprite();
var bgs = [new FlxSprite(), new FlxSprite()];
var players = [new FlxSprite(), new FlxSprite()];
var flxwidth = FlxG.width;
var bar = new FunkinSprite();

function has(change) {
	return data.changes.indexOf(change) != -1;
}

function create() {
	// whats the point
	if (data.changes.length < 1) {
		CoolUtil.playMenuSFX(2);
		close();
		return;
	}

	FlxG.cameras.add(pauseCam, false);
	cameras = [pauseCam];

	for (i in bgs) {
		i.makeGraphic(1, 1, -1);
		i.scale.set(FlxG.width * 0.5, FlxG.height);
		i.updateHitbox();
		i.color = 0x3f0048;
		add(i);
	}
	bgs[1].x += FlxG.width * 0.5;

	if (!Options.lowMemoryMode) {
		var shit = new FlxBackdrop(FlxGridOverlay.createGrid(1, 1, 2, 2, true, 0x00ffffff, 0x11ffffff));
		shit.scale.set(60, 60);
		shit.updateHitbox();
		shit.screenCenter();
		shit.blend = 0;
		shit.scrollFactor.set(0.4, 0.4);
		shit.velocity.y = 46;
		add(shit);
	}

	bar.makeGraphic(1, 1, -1);
	bar.scale.set(FlxG.width, 148);
	bar.updateHitbox();
	bar.screenCenter(0x01);
	bar.color = 0x3f0048;

	pauseCam.bgColor = 0x33000000;

	var slice = flxwidth * 0.25;

	conchetumadre = [fuckingIdiot(data?.chars[0] ?? 'face'), fuckingIdiot(data?.chars[1] ?? 'bf')];

	conchetumadre[0].x = slice - (conchetumadre[0].width * 0.5);
	conchetumadre[1].x = (slice * 3) - (conchetumadre[1].width * 0.5);

	add(conchetumadre[0]);
	add(conchetumadre[1]);

	add(bar);

	var fighter = new FunkinSprite().loadGraphic(Paths.image('freeplay/charsel/_label'));
	add(fighter);
	fighter.screenCenter(0x01);
	fighter.y = 6;

	tabSpr = new FlxSprite();
	tabSpr.frames = Paths.getSparrowAtlas('freeplay/charsel/_playerlabels');
	tabSpr.animation.addByPrefix('idle', '_tab', 12, true);
	tabSpr.animation.play('idle', true);
	tabSpr.x = 40;
	tabSpr.y = 30;
	add(tabSpr);

	var modeLabelSpr = new FlxSprite();
	modeLabelSpr.frames = Paths.getSparrowAtlas('freeplay/charsel/_playerlabels');
	modeLabelSpr.animation.addByPrefix('idle', '_mode', 0, true);
	modeLabelSpr.animation.play('idle', true);
	modeLabelSpr.screenCenter(0x01);
	modeLabelSpr.x += 340;
	modeLabelSpr.y = 16;

	modeSpr.frames = Paths.getSparrowAtlas('freeplay/charsel/_playerlabels');
	modeSpr.animation.addByPrefix('idle', '_mode-labels', 0, true);
	modeSpr.animation.play('idle', true);
	modeSpr.screenCenter(0x01);
	modeSpr.x += 360;
	modeSpr.y = 26;

	var index = 1;
	for (i in players) {
		i.frames = Paths.getSparrowAtlas('freeplay/charsel/_playerlabels');
		i.animation.addByPrefix('p1', '_p1', 12, true);
		i.animation.addByPrefix('p2', '_p2', 12, true);
		i.animation.play('p' + index, true);
		i.ID = index;
		i.antialiasing = true;
		i.updateHitbox();
		add(i);
		index += 1;
	}

	test();
	pauseCam.flash(-1, 0.3, null);
	pauseCam.shake(0.01, 0.25, null);

	add(modeLabelSpr);
	add(modeSpr);

	if (mobile) {
		bar.y = FlxG.height - bar.height;
		for (o in conchetumadre) {
			o.y -= bar.height;
		}
		for (i in [tabSpr, modeLabelSpr, modeSpr, fighter]) {
			i.y += bar.y;
		}
	}

	updateSelected(FlxG.save.data.coopselection);

	FlxG.sound.music.volume = 0.5;
}

var accepted = false;
var firstFrame = true;
function update(elapsed) {
	if (firstFrame != (firstFrame = false)) {
		return;
	}
	var screen = FlxG.mouse.getScreenPosition(pauseCam);
	if (!accepted) {
		if (has(HighscoreChange.COpponentMode)) {
			if (controls.LEFT_P || (mobile && screen.y < bar.y && screen.x < FlxG.width * 0.5)) {
				updateSelected(inCoop ? 2 : 0);
			}
			if (controls.RIGHT_P || (mobile && screen.y < bar.y && screen.x >= FlxG.width * 0.5)) {
				updateSelected(inCoop ? 3 : 1);
			}
		}

		if (has(HighscoreChange.CCoopMode)) {
			if (controls.CHANGE_MODE
				|| (mobile && (screen.y >= bar.y + 5 && screen.x <= tabSpr.x + tabSpr.frameWidth) && FlxG.mouse.justReleased)) {
				inCoop = !inCoop;
				CoolUtil.playMenuSFX(5, 0.6);
				updateSelected(inCoop ? selected + 2 : selected);
			}
		}
	}
	if (controls.BACK || controls.ACCEPT || mobile // todo: make this better
		&& screen.y < bar.y && FlxG.mouse.justReleased) {
		conchetumadre[selected].animation.play('win');
		conchetumadre[1 - selected].animation.play(inCoop ? 'win' : 'idle');

		bgs[1 - selected].color = FlxColor.interpolate(conchetumadre[1 - selected].extra.get('color'), inCoop ? 0xf1e7ff : 0x3f0048, inCoop ? 0.9 : 0.5);
		bgs[selected].color = FlxColor.interpolate(conchetumadre[selected].extra.get('color'), 0xf1e7ff, 0.9);

		CoolUtil.playMenuSFX(1, 0.6);

		new FlxTimer().start(1.5, function(_) {
			FlxG.sound.music.volume = 1;
			close();
			FlxG.camera.bgColor = 0xFF999999;
		});
		accepted = true;
	}

	for (i in players) {
		var id = i.ID - 1;
		players[id].x = flxwidth * (id == 0 ? 0.25 : 0.75) - players[id].frameWidth * 0.5;
		players[id].y = (conchetumadre[id].y - conchetumadre[id].offset.y) - players[id].frameHeight - 15;
		players[id].y = Math.max(players[id].y, 0);
	}
}

function destroy() {
	if (FlxG.cameras.list.indexOf(pauseCam) != -1) FlxG.cameras.remove(pauseCam);
}

function test() {
	// trace('MY ASSHOLE BURNS');
	FlxG.sound.play(Paths.sound('pixel/ANGRY_TEXT_BOX'));
}

function fuckingIdiot(char = 'face') {
	var spr = new FunkinSprite();
	spr.frames = Paths.getSparrowAtlas('freeplay/charsel/' + char ?? {
		char = 'face';
		Paths.getSparrowAtlas('freeplay/charsel/face');
	});
	if (spr.animation.exists('idle')) {
		spr.animation.remove('idle');
		spr.animation.remove('select');
		spr.animation.remove('win');
	}
	spr.animation.addByIndices('idle', char, [0, 1], '', 12, true);
	spr.animation.addByIndices('select', char, [2, 3], '', 12, true);
	spr.animation.addByIndices('win', char, [4, 5], '', 12, true);
	spr.animation.play('idle', true);
	spr.antialiasing = true;
	spr.updateHitbox();
	spr.width = spr.frameWidth;
	spr.y = FlxG.height - (spr.height * 0.83);
	var xmlPath = Paths.file('images/freeplay/charsel/' + char + '.xml');
	var xml:String = Xml.parse(Assets.getText(xmlPath)).firstElement();
	var idk:String = xml.get('color');
	spr.extra.set('color', (CoolUtil.getColorFromDynamic('#' + idk ?? 0x9999cc) & 0xffffff) + 0xff000000);
	spr.onDraw = (s) -> {
		s.offset.y = lerp(s.offset.y, (s.animation.name != 'idle') ? 30 : 0, 0.1);
		s.draw();
	}

	return spr;
}

var firstEntry = true;
var lastIndex = -1;

function updateSelected(index) {
	FlxG.save.data.coopselection = index;

	if (index == lastIndex)
		return;

	if (firstEntry) {
		firstEntry = false;
		inCoop = index > 1;
	}
	selected = index % 2;

	bgs[1 - selected].color = FlxColor.interpolate(conchetumadre[1 - selected].extra.get('color'), 0x3f0048, 0.5);
	bgs[selected].color = conchetumadre[selected].extra.get('color');

	players[1 - selected].alpha = 0.001;
	players[selected].alpha = 0.001;
	players[selected].animation.play('p1');

	if (inCoop) {
		conchetumadre[0].animation.play('select');
		conchetumadre[1].animation.play('select');

		bgs[0].color = conchetumadre[0].extra.get('color');
		bgs[1].color = conchetumadre[1].extra.get('color');

		players[selected].alpha = 1;
		players[1 - selected].alpha = 1;

		players[selected].animation.play('p1');
		players[1 - selected].animation.play('p2');
	} else {
		conchetumadre[1 - selected].animation.play('idle');
		conchetumadre[selected].animation.play('select');
	}

	modeSpr.animation.curAnim.curFrame = index;

	CoolUtil.playMenuSFX(0, 0.7);
	lastIndex = index;
}
