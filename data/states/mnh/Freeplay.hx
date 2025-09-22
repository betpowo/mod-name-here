import haxe.ds.StringMap;
import flixel.util.FlxSpriteUtil;
import openfl.utils.Assets;
import flixel.FlxObject;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import openfl.ui.Mouse;
import funkin.backend.chart.Chart;
import funkin.savedata.FunkinSave;
import funkin.savedata.HighscoreChange;
import Xml;
import Reflect;
import openfl.display.BlendMode;

var songs = [];
var extrasDown = false;
var songGroup = new FlxSpriteGroup();
var miscGroup = new FlxSpriteGroup();

var songMetadata = {
	size: 240,
	separator: 20,
	maxPerRow: 4
}

var cameraTracker:FlxObject = new FlxObject(0, 0, 0, 0);
var lastPlayed = -1;
var hoveringSong = -1;
var camOverlay:FlxCamera = new FlxCamera();

var rankStuff = {
	stars: new FlxSpriteGroup(),
	score: new FunkinText(),
	rating: new FunkinText(),
	rank: new FlxSprite(),
	mode: new FlxSprite()
};

var xtraIndex = -1;
var varList = ['normal', 'pico'];
var curVariation = 0;
var variation = 'normal';
var metas = ['normal' => new StringMap()];
var help = new FunkinSprite();

function create() {
	CoolUtil.playMenuSong();
	FlxG.mouse.visible = true;
	FlxG.cameras.add(camOverlay, false);
	camOverlay.bgColor = 0x00000000;

	cameraTracker.x = FlxG.width * 0.5;
	cameraTracker.y = FlxG.height * 0.5;

	help.loadGraphic(Paths.image('freeplay/help' + (mobile ? '-mobile' : '')));
	help.setGraphicSize(FlxG.width, FlxG.height);
	help.updateHitbox();
	help.screenCenter();
	help.scrollFactor.set();
	help.alpha = 0;
	help.active = false;

	songs = loadThemSongs();
	// unlock skibidi sigma pomni if all song have been 100%
	// this ones for you jaye
	if (perfectAll()) {
		songs.push({
			name: 'skibidi-sigma-pomni',
			chars: ['face', 'bf'],
			locked: false
		});
	}

	FlxG.camera.bgColor = 0xff777777;

	var shit = new FlxBackdrop(FlxGridOverlay.createGrid(1, 1, 2, 2, true, 0x00ffffff, 0x0dffffff));
	shit.scale.set(60, 60);
	shit.updateHitbox();
	shit.screenCenter();
	shit.blend = 0;
	shit.scrollFactor.set(0.4, 0.4);
	shit.velocity.y = 16;
	add(shit);

	var dumpTxt = new FunkinText();
	dumpTxt.font = Paths.font('sillyfont.ttf');
	dumpTxt.borderSize = 3;
	dumpTxt.borderColor = 0xffcccccc;
	dumpTxt.color = 0xff333333;
	dumpTxt.size = 72;
	dumpTxt.text = ' freeplay ';

	// thank you rozebud
	dumpTxt.drawFrame(true);
	var scrollTxt = new FlxBackdrop(dumpTxt.pixels);
	scrollTxt.antialiasing = true;
	scrollTxt.velocity.set(-150, 0);
	scrollTxt.repeatAxes = 0x01;
	scrollTxt.updateHitbox();
	scrollTxt.blend = BlendMode.ADD;
	scrollTxt.y = 50;
	scrollTxt.spacing.x = -15;
	add(scrollTxt);

	var dumpTxt = new FunkinText();
	dumpTxt.font = Paths.font('sillyfont.ttf');
	dumpTxt.borderSize = 3;
	dumpTxt.borderColor = 0xff333333;
	dumpTxt.color = 0xff999999;
	dumpTxt.size = 32;
	dumpTxt.text = (mobile ? 'tap this text' : 'press [F1]') + ' for navigation help - ';

	// thank you rozebud
	dumpTxt.drawFrame(true);
	var scrollTxt = new FlxBackdrop(dumpTxt.pixels);
	scrollTxt.antialiasing = true;
	scrollTxt.velocity.set(150, 0);
	scrollTxt.repeatAxes = 0x01;
	scrollTxt.updateHitbox();
	scrollTxt.blend = BlendMode.ADD;
	scrollTxt.y = 150;
	add(scrollTxt);

	songBG = new FlxSprite().makeGraphic(1, 1, -1);
	songBG.color = 0x0;
	add(songBG);

	resizeSongBG(xtraIndex == 0 ? songs.length : xtraIndex + 1);
	songBG.updateHitbox();

	add(songGroup);

	add(miscGroup);
	miscGroup.cameras = [camOverlay];

	var fuckingbg = new FlxSprite();
	fuckingbg.frames = Paths.getFrames('freeplay/misc');
	fuckingbg.animation.addByPrefix('idle', 'board', 0, false);
	fuckingbg.animation.play('idle', true);
	fuckingbg.updateHitbox();
	miscGroup.add(fuckingbg);

	for (i in 0...10) {
		var star = new FlxSprite(34 * i, 0);
		star.frames = Paths.getFrames('freeplay/misc');
		star.animation.addByPrefix('idle', 'star0', 12, true);
		star.animation.addByPrefix('idle-ex', 'star extreme', 12, true);
		star.animation.play('idle', true);
		star.updateHitbox();
		rankStuff.stars.add(star);

		star.ID = i + 1;
	}

	rankStuff.stars.setPosition(20, 20);

	rankStuff.score.font = rankStuff.rating.font = Paths.font('sillyfont.ttf');

	rankStuff.score.size = 50;
	rankStuff.score.borderColor = 0xFFffffff;
	rankStuff.score.borderSize = 3;
	rankStuff.score.borderQuality = 8;
	rankStuff.score.antialiasing = true;
	rankStuff.score.text = '1234567890';
	rankStuff.score.setPosition(20, 36);
	rankStuff.score.color = 0;
	rankStuff.score.fieldWidth = 400;

	rankStuff.rating.size = 20;
	rankStuff.rating.color = 0xbbbbbb;
	rankStuff.rating.antialiasing = true;
	rankStuff.rating.text = '(12.34%)';
	rankStuff.rating.fieldWidth = 200;
	rankStuff.rating.setPosition(fuckingbg.width - 180, 74);
	rankStuff.rating.alignment = 'center';
	rankStuff.rating.borderColor = 0xFF333333;
	rankStuff.rating.borderSize = 3;
	rankStuff.rating.borderQuality = 8;

	rankStuff.rank.frames = Paths.getFrames('freeplay/misc');
	rankStuff.rank.animation.addByPrefix('ranks', 'ranks', 0, false);
	rankStuff.rank.animation.play('ranks', true);
	rankStuff.rank.updateHitbox();
	rankStuff.rank.setPosition(fuckingbg.width - rankStuff.rank.width - 30, -10);

	rankStuff.mode.frames = Paths.getSparrowAtlas('freeplay/charsel/_playerlabels');
	rankStuff.mode.animation.addByPrefix('idle', '_mode-labels', 0, true);
	rankStuff.mode.animation.play('idle', true);
	rankStuff.mode.x = 15;
	rankStuff.mode.y = -50;
	rankStuff.mode.scale.set(0.7, 0.7);
	rankStuff.mode.updateHitbox();
	rankStuff.mode.antialiasing = true;

	miscGroup.add(rankStuff.stars);
	miscGroup.add(rankStuff.score);
	miscGroup.add(rankStuff.rank);
	miscGroup.add(rankStuff.rating);
	miscGroup.add(rankStuff.mode);

	miscGroup.alpha = 0.001;
	miscGroup.y = FlxG.height - miscGroup.height + 64;

	miscGroup.forEach((_) -> {
		var a = _;
		if (a.flixelType == 4) {
			a.forEach((b) -> {
				b.antialiasing = true;
			});
		}
		else a.antialiasing = true;
	});

	/*var modeLabelSpr = new FlxSprite();
		modeLabelSpr.frames = Paths.getSparrowAtlas('freeplay/charsel/_playerlabels');
		modeLabelSpr.animation.addByPrefix('idle', '_tab', 12, true);
		modeLabelSpr.animation.play('idle', true);
		modeLabelSpr.updateHitbox();
		modeLabelSpr.x = FlxG.width - modeLabelSpr.width - 40;
		modeLabelSpr.y = 30;
		modeLabelSpr.scrollFactor.set(0, 0);
		add(modeLabelSpr); */

	var songIndex = 0;
	for (bleh in songs) {
		try {
			var def = Chart.loadChartMeta(bleh.name, null, 'normal', true, false);

			for (i in def.difficulties) {
				// trace('===== before: ' + metas.get(i));
				if (metas.get(i) == null) {
					metas.set(i, new StringMap());
					// trace('added new entry! ' + i);
				}
				// trace('====== after: ' + metas.get(i));
				try {
					var dat = Chart.loadChartMeta(bleh.name, null, i, true, false);
					// trace(dat);
					if (dat != null && metas.get(i) != null) {
						// trace(dat);
						metas.get(i).set(bleh.name, dat);
						if (i != 'normal') {
							def.metas.set(i, dat);
						}
					}
				} catch (e:Dynamic) {
					trace(e);
				}
			}

			var data = metas.get(variation).get(bleh.name) ?? def;
			var square = songsquare(data);
			square.locked = bleh.locked;
			songGroup.add(square);
			square.x = ((songMetadata.size + songMetadata.separator) * (songIndex % songMetadata.maxPerRow));
			square.y = ((songMetadata.size + songMetadata.separator) * Math.floor(songIndex / songMetadata.maxPerRow)) + songMetadata.separator;
			square.y -= songMetadata.separator;
			square.ID = songIndex;
			songIndex += 1;

			square.onClick = function() {
				if (help.active)
					return;
				if (square.locked) {
					square.shakeAmount += 5;
					CoolUtil.playMenuSFX(2, 0.7);
				} else {
					var mode = FlxG.save.data.coopselection;
					if (Assets.exists('songs/' + data.name + '/charts/' + variation + '.json')) {
						Mouse.cursor = 'arrow';
						PlayState.loadSong(data.name, variation, null /* for now we dont have variations */, (mode == 0) || (mode == 2), mode > 1);
						PlayState.SONG.meta = metas.get(variation).get(data.name); // Bruhhh
						forceTween().tween(FlxG.sound.music, {pitch: 0}, 0.2);
						var hah = new FunkinSprite();
						hah.makeSolid(FlxG.width, FlxG.height, 0xffffffff);
						hah.blend = BlendMode.SUBTRACT;
						hah.screenCenter();
						hah.cameras = [camOverlay];
						add(hah);
						hah.alpha = 0;
						// trace(PlayState.SONG.meta);
						forceTween().tween(hah, {alpha: 1}, 0.3, {
							onComplete: (_) -> {
								FlxG.switchState(new PlayState());
							}
						});
					}
				}
			};
			square.onOverlap = function() {
				hoveringSong = -1;
				if (help.active)
					return;
				if (bleh.name != '--extras') {
					hoveringSong = square.ID;
					var mode = FlxG.save.data.coopselection;
					var changes = [];
					if ((mode == 0) || (mode == 2))
						changes.push(HighscoreChange.COpponentMode);
					if (mode > 1)
						changes.push(HighscoreChange.CCoopMode);
					var saveData = FunkinSave.getSongHighscore(bleh.name, variation, null, changes);
					rankStuff.score.text = saveData.score;
					rankStuff.rating.text = '(' + CoolUtil.quantize(saveData.accuracy * 100, 100) + '%)';
					rankStuff.mode.animation.curAnim.curFrame = mode;
					miscGroup.alpha = 1;

					var data = metas.get(variation)?.get(bleh.name) ?? def;
					// trace(metas.get(variation));

					updateStars(data.customValues == null ? 0 : (Std.parseInt(data.customValues.stars ?? 0)));
					updateRank(saveData.accuracy);
				} else {
					hoveringSong = -2;
				}
				square.shakeAmount += 1.3;
				CoolUtil.playMenuSFX(0, square.locked ? 0.1 : 0.7);
			};
			square.onExit = function() {
				hoveringSong = -1;
			};

			if (xtraIndex != 0) {
				square.visible = square.ID <= xtraIndex;
			}
		} catch (e:Dynamic) {
			// trace(e);
		}
		updateExtrasColor(xtraIndex);
	}
	// trace(metas);

	songGroup.screenCenter();
	songGroup.y = (FlxG.height - songMetadata.size) / 2;
	songBG.setPosition(songGroup.x - songMetadata.separator, songGroup.y - songMetadata.separator);

	var square = songGroup.members[xtraIndex];
	if (mobile) {
		backSquare = songsquare({
			name: '--back',
			color: 0xff0033
		});
		insert(members.indexOf(songGroup) + 1, backSquare);

		backSquare.onClick = function() {
			FlxG.switchState(new MainMenuState());
			persistentUpdate = false;
			Mouse.cursor = 'arrow';
		};
		backSquare.onOverlap = function() {
			backSquare.shakeAmount += 1.3;
			CoolUtil.playMenuSFX(0, 0.7);
		};
		backSquare.playSprite.flipX = true;
	}

	// square.setColor(0x2eaeac);
	if (square != null) {
		square.playSprite.angle = 90;
		// square.playSprite.offset.y = -20;

		square.onClick = function() {
			extrasDown = !extrasDown;

			square.playSprite.flipX = extrasDown;

			songGroup.forEach(function(square) {
				if (square.ID > xtraIndex) {
					square.visible = extrasDown;
				}
				square.shakeAmount = 5;
				if (mobile)
					backSquare.shakeAmount = 5;
			});

			resizeSongBG(xtraIndex + 1 + (mobile ? 1 : 0));

			if (extrasDown) {
				cameraTracker.y += 100;
				resizeSongBG(songGroup.length + (mobile ? 1 : 0));
			}

			FlxG.sound.play(Paths.sound('pixel/clickText'), 0.7);
		};
	}

	FlxG.camera.follow(cameraTracker, null, 0.07);
	help.camera = camOverlay;
	add(help);
	FlxG.save.data.coopselection = 1; // 0: opp, 1: solo, 2: co-op, 3: co-op (switch)
}

function destroy() {
	Mouse.cursor = 'arrow';
}

function resizeSongBG(num) {
	songBG.scale.set(Math.min(num, songMetadata.maxPerRow) * (songMetadata.size + songMetadata.separator) + songMetadata.separator,
		((songMetadata.size + songMetadata.separator) * (num == 0 ? 1 : Math.ceil(num / songMetadata.maxPerRow))) + songMetadata.separator);
	songBG.updateHitbox();
}

function updateExtrasColor(dix) {
	var color = '#2eaeac';
	switch (variation) {
		case 'pico':
			color = '#cefa71';
	}
	if (songGroup.members[dix] != null)
		songGroup.members[dix].setColor(CoolUtil.getColorFromDynamic(color));
}

function shouldDo(node, act) {
	var idk = node.get(act);

	if (idk == 'true')
		return true; // whats the point

	if (StringTools.startsWith(idk, 'score.')) {
		var saveData = FunkinSave.getSongHighscore(idk.split('score.')[1], variation, null, []);
		if (saveData.score == 0)
			return true;
	}

	return false;
}

function loadThemSongs() {
	var sogs = [
		{
			name: 'question-mark',
			chars: ['betpo', 'bf'],
			locked: false
		}
	];
	try {
		var bleh = CoolUtil.coolTextFile(Paths.txt('weeks/weeks'));
		bleh.push('extras');
			
		sogs.shift();

		for (i in bleh) {
			if (i == 'extras') {
				sogs.push({
					name: '--extras',
					chars: ['face', 'bf'],
					locked: false
				});
				xtraIndex = sogs.length - 1;
			}

			var path = Paths.xml('weeks/weeks/' + i);
			if (Assets.exists(path)) {
				var xml = Xml.parse(Assets.getText(path)).firstElement();

				for (node in xml.elements()) {
					if (!shouldDo(node, 'hide')) {
						sogs.push({
							name: StringTools.trim(node.firstChild().nodeValue),
							locked: shouldDo(node, 'locked'),
							chars: node.get('chars')?.split(',') ?? ['face', 'bf']
						});
					}
				}
			}
		}
	} catch (e:Dynamic) {
		trace(e);
	}

	return sogs;
}

function perfectAll() {
	var blacklisted = ['--extras', '--back', 'skibidi-sigma-pomni'];
	for (i in songs) {
		if (blacklisted.indexOf(i.name) != -1) continue;
		if (FunkinSave.getSongHighscore(i.name, 'normal', null, []).accuracy < 1) {
			return false;
			break;
		}
	}
	return true;
}

var scrollSpeed = 600;
var charsToUse = ['face', 'bf'];
var time = 0.0;

if (mobile) {
	var prevY = null;
	var diff = 0;
	var offsetY = null;
	var overlappingSquare = false;
}

function getChangesAvailable(s) {
	var song = metas.get(variation).get(songs[s].name);
	var res = [];
	if (song.opponentModeAllowed) res.push(HighscoreChange.COpponentMode);
	if (song.coopAllowed) res.push(HighscoreChange.CCoopMode);
	return res;
}

function update(elapsed) {
	time += elapsed;
	FlxG.camera.bgColor = FlxColor.fromHSB(time * 50, 0.3, 0.4);

	var trackedHelpActive = help.active;

	if (FlxG.keys.justPressed.F1 || (mobile && FlxG.mouse.justReleased && FlxG.mouse.y <= 200)) {
		help.active = !help.active;
		// trace('burp');
	}
	help.alpha = lerp(help.alpha, help.active ? 1 : 0, 0.3);

	if (help.active)
		return;

	if (controls.BACK) {
		FlxG.switchState(new MainMenuState());
		persistentUpdate = false;
		Mouse.cursor = 'arrow';
	}
	if (controls.CHANGE_MODE && hoveringSong > -1) {

		charsToUse = getCharactersFromSong(hoveringSong);

		var ch = getChangesAvailable(hoveringSong);
		if (ch.length < 1) {
			songGroup.members[hoveringSong].shakeAmount += 3;
		} else {
			persistentUpdate = false;
			Mouse.cursor = 'arrow';
		}

		var test = new ModSubState('mnh/SideSelect', {chars: charsToUse, changes: ch});
		openSubState(test);

	}
	if (hoveringSong < 0) {
		miscGroup.alpha -= elapsed * 5;
	}
	var disableBounding = false;
	if (mobile) {
		for (touch in FlxG.touches.list) {
			if (touch.pressed) {
				disableBounding = true;
				if (hoveringSong != -1 && !overlappingSquare) {
					overlappingSquare = true;
				}
			} else {
				overlappingSquare = false;
			}
		}

		var songIndex = extrasDown ? songGroup.length : (xtraIndex + 1);
		backSquare.x = ((songMetadata.size + songMetadata.separator) * (songIndex % songMetadata.maxPerRow));
		backSquare.y = ((songMetadata.size + songMetadata.separator) * Math.floor(songIndex / songMetadata.maxPerRow)) + songMetadata.separator;
		backSquare.y -= songMetadata.separator;

		backSquare.x += songGroup.x;
		backSquare.y += songGroup.y;
	}
	var maxH = extrasDown ? songGroup.height - (songMetadata.size * 0.5) : (songGroup.members[xtraIndex]?.y ?? 0) - (songMetadata.size * 0.5);
	if (!disableBounding) {
		cameraTracker.y = FlxMath.bound(cameraTracker.y, camera.height * 0.5, songGroup.y + maxH);
	}
	var oob = (cameraTracker.y < (camera.height * 0.5)) || (cameraTracker.y > (songGroup.y + maxH));
	if (controls.UP)
		cameraTracker.y -= elapsed * scrollSpeed;
	if (controls.DOWN)
		cameraTracker.y += elapsed * scrollSpeed;
	cameraTracker.y += FlxG.mouse.wheel * (scrollSpeed * -0.1);

	if (mobile) {
		for (touch in FlxG.touches.list) {
			if (touch.justPressed) {
				prevY = touch.screenY;
				if (offsetY != null)
					offsetY = camera.scroll.y + (camera.height * 0.5) - cameraTracker.y;
			}
			var _diff = prevY - touch.screenY;
			if (Math.abs(_diff) >= 1)
				diff = _diff;

			if (trackedHelpActive == help.active) {
				if (!overlappingSquare) {
					cameraTracker.y += (_diff) * (oob ? 0.4 : 1.0);
					if (touch.pressed) {
						camera.scroll.y = (cameraTracker.y - (camera.height * 0.5));
						if (offsetY != null)
							camera.scroll.y += offsetY;
					}
				}
				if (touch.justReleased) {
					if (!overlappingSquare)
						cameraTracker.y += diff / camera.followLerp;
					offsetY = 0;
					overlappingSquare = false;
				}
			}

			prevY = touch.screenY;
		}
	} else {
		camera.targetOffset.set(((FlxG.mouse.x - (camera.width * 0.5)) * 0.01), ((FlxG.mouse.y - (camera.height * 0.5)) * 0.01));
	}

	if (controls.getJustPressed('switchvar')) {
		variation = varList[FlxMath.wrap(++curVariation, 0, varList.length - 1)];
		CoolUtil.playMenuSFX(5, 0.6);
		updateExtrasColor(xtraIndex);
		songGroup.forEach(function(square) {
			square.shakeAmount = 5;
			if (square.ID != xtraIndex) {
				square.locked = songs[square.ID].locked;
				if (!Assets.exists('songs/' + songs[square.ID].name.toLowerCase() + '/charts/' + variation + '.json')) {
					square.locked = true;
				} else {
					square.setColor(CoolUtil.getColorFromDynamic(metas.get(variation).get(songs[square.ID].name.toLowerCase()).color));
				}
			}
		});
		if (hoveringSong >= 0) {
			songGroup.members[hoveringSong].onOverlap();
		}
	}
}

function songsquare(data) {
	var squa = new SongSquare(0, 0, null, data);
	squa.mobile = mobile;
	return squa;
}

function updateStars(count) {
	var stars = rankStuff.stars;
	for (star in stars.members) {
		if (count > 10) {
			star.animation.play('idle');
			star.offset.set(0, 0);
			star.color = 0xffcc66;
			if (star.ID <= (count - 10)) {
				star.color = -1;
				star.animation.play('idle-ex');
				star.offset.set(3, 14);
			}
		} else {
			star.animation.play('idle');
			star.offset.set(0, 0);
			star.color = 0x003366;
			if (star.ID <= count)
				star.color = 0xffcc66;
		}
	}
}

function updateRank(acc) {
	var real = acc * 100;
	var rank = rankStuff.rank.animation.curAnim;
	rank.curFrame = 0;
	if (real > 0) {
		rank.curFrame = 1; // loss
		if (real >= 69)
			rank.curFrame = 2; // good
		if (real >= 80)
			rank.curFrame = 3; // great
		if (real >= 90)
			rank.curFrame = 4; // excellent
		if (real >= 99)
			rank.curFrame = 5; // perfect
		if (real >= 100)
			rank.curFrame = 6; // perfect+
	}
}

function destroy() {
	FlxG.camera.bgColor = 0;
	FlxG.save.data.coopselection = null;
}

function getCharactersFromSong(index) {
	return songs[index].chars ?? ['face', 'bf'];
}

class SongSquare extends flixel.FlxSprite {
	public var playSprite:FlxSprite;
	public var overlaySprite:FlxSprite;
	public var locked:Bool = false;

	public var onClick:Void->Void;
	public var onOverlap:Void->Void;
	public var onExit:Void->Void;

	public var playingSong:Bool = false;
	public var initialColor = 0x666666;

	public var shakeAmount = 0;
	public var initialOffsets = {x: 0, y: 0};

	public var gm:CustomShader;

	// bandaid fix
	public var mobile = false;

	public function new(blehx, blehy, blehgraph, data) {
		super();

		var image = Paths.image('freeplay/defaultImage'); // Paths.image('freeplay/songs/' + song.toLowerCase());
		if (Assets.exists('images/freeplay/songs/' + data.name.toLowerCase() + '.png')) {
			// trace('ayo i found ' + song);
			image = Paths.image('freeplay/songs/' + data.name.toLowerCase());
		}
		loadGraphic(image);
		setGraphicSize(songMetadata.size);
		antialiasing = true;

		updateHitbox();

		playSprite = doPlayThing();

		overlaySprite = new FlxSprite().loadGraphic(Paths.image('freeplay/lock'));
		overlaySprite.setGraphicSize(songMetadata.size);
		overlaySprite.antialiasing = true;

		setColor(CoolUtil.getColorFromDynamic(data.color));

		initialOffsets = {x: offset.x, y: offset.y};
	}

	var __overlapped = false;

	public var __lastlock = false;

	public override function update(elapsed:Float) {
		super.update(elapsed);
		if (!visible)
			return;

		shakeAmount = FlxMath.lerp(shakeAmount, 0, elapsed * 6);

		offset.set(initialOffsets.x + FlxG.random.float(-shakeAmount, shakeAmount), initialOffsets.y + FlxG.random.float(-shakeAmount, shakeAmount));
		angle = FlxG.random.float(-shakeAmount, shakeAmount) * 0.3;

		playSprite.x = getGraphicMidpoint().x - (playSprite.width * 0.5) - offset.x;
		playSprite.y = getGraphicMidpoint().y - (playSprite.height * 0.5) - offset.y;
		playSprite.visible = false;
		if (FlxG.mouse.overlaps(this)) {
			if (onOverlap != null && !__overlapped) {
				onOverlap();
				Mouse.cursor = 'button';
				__overlapped = true;
			}
			if (!locked)
				playSprite.visible = true;
			if (mobile ? FlxG.mouse.justReleased : FlxG.mouse.justPressed)
				if (onClick != null)
					onClick();
		} else {
			if (__overlapped) {
				Mouse.cursor = 'arrow';
				__overlapped = false;
				if (onExit != null) {
					onExit();
				}
			}
		}
		overlaySprite.x = getGraphicMidpoint().x - (overlaySprite.width * 0.5) - offset.x;
		overlaySprite.y = getGraphicMidpoint().y - (overlaySprite.height * 0.5) - offset.y;
		overlaySprite.angle = angle;

		if (__lastlock != locked) {
			__lastlock = locked;
			// trace('blah! ' + locked);
			setColor(initialColor);
		}
	}

	public var useShader:Bool = !mobile;

	public function setColor(col) {
		initialColor = col;
		var luminance = (0.2126 * (red(col) / 255) + 0.7152 * (green(col) / 255) + 0.0722 * (blue(col) / 255));
		var brightestLuminance:Float = 0.83;

		if (useShader) {
			if (gm == null) {
				gm = new CustomShader('gradientMap');
				gm.black = [0, 0, 0, 1];
				gm.white = [1, 1, 1, 1];
				gm.mult = 1;
				this.shader = playSprite.shader = gm;
			}
			gm.black[0] = red(col) / 255;
			gm.black[1] = green(col) / 255;
			gm.black[2] = blue(col) / 255;
			for (i in 0...3) {
				gm.white[i] = (luminance >= brightestLuminance) ? 0 : 1;
			}
			if (locked) {
				gm.white = gm.black;
				gm.black = [0, 0, 0, 1];
			}
			return;
		}
		if (!locked) {
			setColorTransformOffset(this, col);
			if (luminance >= brightestLuminance) {
				this.colorTransform.redMultiplier = this.colorTransform.greenMultiplier = this.colorTransform.blueMultiplier = -1;
			}
		} else {
			this.colorTransform.color = 0x000000;
			this.color = col;
		}
	}

	public override function draw() {
		super.draw();
		if (locked)
			overlaySprite.draw();
		else {
			if (playSprite.visible)
				playSprite.draw();
		}
	}

	// color
	public function red(col) {
		return (col >> 16) & 0xff;
	}

	public function green(col) {
		return (col >> 8) & 0xff;
	}

	public function blue(col) {
		return (col & 0xff);
	}

	public function setColorTransformOffset(sprite, color) {
		sprite.setColorTransform(1, 1, 1, sprite.alpha, red(color), green(color), blue(color));
	}

	public function doPlayThing() {
		var radius = 50;
		var canvasSize = (radius * 2) + 50;
		var circle = new FlxSprite().makeGraphic(canvasSize * 2, canvasSize, 0x0);
		FlxSpriteUtil.drawCircle(circle, circle.width / 4, circle.height / 2, radius, 0xFFffffff, {thickness: 5, color: 0xFF000000});
		FlxSpriteUtil.drawCircle(circle, (circle.width / 4) + (circle.width / 2), circle.height / 2, radius, 0xFF000000);
		var wa1 = circle.width / 8;
		var wa2 = circle.height / 4;
		var ofsets = {x: wa1, y: wa2};
		ofsets.x += 23;
		ofsets.y += 12;
		var triang = {w: 40, h: 50};

		FlxSpriteUtil.drawPolygon(circle, [
			FlxPoint.get(ofsets.x, ofsets.y),
			FlxPoint.get(ofsets.x + triang.w, ofsets.y + (triang.h * 0.5)),
			FlxPoint.get(ofsets.x, ofsets.y + triang.h),
			FlxPoint.get(ofsets.x, ofsets.y)
		], 0xFF000000);
		for (i in 0...2) {
			FlxSpriteUtil.drawRect(circle, (circle.width / 4) + (circle.width / 2) - 7 - ((i - 0.5) * 27), (circle.height / 2) - (radius * 0.5), 14, radius,
				-1);
		}

		circle.loadGraphic(circle.graphic, true, canvasSize, canvasSize);
		circle.animation.add('idle', [0, 1], 0, true);
		circle.animation.play('idle', true);
		circle.alpha = 0.001;
		circle.updateHitbox();
		circle.screenCenter();
		circle.antialiasing = true;
		circle.colorTransform = this.colorTransform;
		return circle;
	}
}
