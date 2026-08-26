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
 
import funkin.backend.utils.AudioAnalyzer;
import funkin.backend.assets.ModsFolder;

var analyzer:AudioAnalyzer;
var analyzerLevelsCache:Array<Float>;
var analyzerTimeCache:Float;
var songs = [];
var extrasDown = false;
var songGroup = new FlxSpriteGroup();
var miscGroup = new FlxSpriteGroup();

var songMetadata = {
	size: 240,
	separator: 20,
	maxPerRow: 3
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
var whiteSquare = new FunkinSprite();
var accepted = false;
var vizbars:FlxSpriteGroup = new FlxSpriteGroup();

function col2rgba(col) {
	return [
		((col >> 16) & 0xff) / 255,
		((col >> 8) & 0xff) / 255,
		((col >> 0) & 0xff) / 255,
		1
	];
}

var bars = {
	amount: 24,
	padding: 14,
	height: 250
};

function create() {
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
	shit.blend = BlendMode.ADD;
	shit.scrollFactor.set(0.4, 0.4);
	shit.velocity.y = 16;
	add(shit);

	add(vizbars);
	for (i in 0...bars.amount) {
		var bar = new FunkinSprite().makeSolid(((((songMetadata.size + songMetadata.separator) * songMetadata.maxPerRow)) / (bars.amount - 1)) - bars.padding, 1, -1);
		vizbars.add(bar);

		bar.origin.y = 1;
		bar.x = i * (bar.width + bars.padding);
	}
	vizbars.screenCenter(0x01);
	fuck = new Alphabet(50, 50, translate('mnh.fp.title'), 'silly');
	add(fuck);

	import funkin.menus.ui.effects.WaveEffect;

	var effect = new WaveEffect(0, 4, 7);
	effect.speed = 4;
	fuck.effects.push(effect);

	var effect = new WaveEffect(10, 2, 1.01);
	effect.speed = 0.3;
	fuck.effects.push(effect);

	fuck2 = new Alphabet(FlxG.width - 50, 50, translate('mnh.fp.help' + (mobile ? '-mobile' : ''), ['F1']), 'silly');
	fuck2.alignment = 2;
	fuck2.scale.set(0.5, 0.5);
	fuck2.updateHitbox();
	fuck2.x -= fuck2.width;
	add(fuck2);

	for (i in [fuck, fuck2]) {
		var gm = new CustomShader('gradientMap');
		gm.black = [0, 0, 0, 1];
		gm.white = [1, 1, 1, 1];
		gm.mult = 1;
		i.shader = gm;
	}

	songOBG = new FlxSprite().makeGraphic(1, 1, -1);
	songOBG.color = 0xffffff;
	add(songOBG);

	songBG = new FlxSprite().makeGraphic(1, 1, -1);
	songBG.color = 0x0;
	add(songBG);

	resizeSongBG(xtraIndex == 0 ? songs.length : xtraIndex + 1);
	songBG.updateHitbox();
	songOBG.updateHitbox();

	whiteSquare.makeSolid(songMetadata.size + (songMetadata.separator * 0.5), songMetadata.size + (songMetadata.separator * 0.5), -1);
	whiteSquare.alpha = 0;
	add(whiteSquare);

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
		} else
			a.antialiasing = true;
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
					if (data.difficulties.indexOf(variation) != -1 && !accepted) {
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
						accepted = true;
					}
				}
			};
			square.onOverlap = function() {
				hoveringSong = -1;
				if (help.active)
					return;
				if (bleh.name != '--extras') {
					hoveringSong = square.ID;
					if (whiteSquare.alpha <= 0) {
						whiteSquare.setPosition(square.x - 5, square.y - 5);
					}
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
				Mouse.cursor = 'button';
				square.shakeAmount += 1.3;
				CoolUtil.playMenuSFX(0, square.locked ? 0.1 : 0.7).pitch = FlxG.random.float(0.95, 1.05);
			};
			square.onExit = function() {
				hoveringSong = -1;
				Mouse.cursor = 'arrow';
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
	songOBG.setPosition(songBG.x - 7, songBG.y - 7);

	var square = songGroup.members[xtraIndex];

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

	CoolUtil.playMenuSong();
	FlxG.sound.music.pitch = 1; // ???

	analyzer = new AudioAnalyzer(FlxG.sound.music, 1024);
}

function destroy() {
	Mouse.cursor = 'arrow';
}

function resizeSongBG(num) {
	songBG.scale.set(Math.min(num, songMetadata.maxPerRow) * (songMetadata.size + songMetadata.separator) + songMetadata.separator,
		((songMetadata.size + songMetadata.separator) * (num == 0 ? 1 : Math.ceil(num / songMetadata.maxPerRow))) + songMetadata.separator);
	songBG.updateHitbox();

	songOBG.scale.set(songBG.scale.x + 14, songBG.scale.y + 14);
	songOBG.updateHitbox();
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

				var contents = getAddonFileContents(Paths.xml('weeks/weeks/extras'));
				for (i in contents) {
					var xml = Xml.parse(i).firstElement();

					for (node in xml.elementsNamed('song')) {
						if (!shouldDo(node, 'hide')) {
							sogs.push({
								name: StringTools.trim(node.firstChild().nodeValue),
								locked: shouldDo(node, 'locked'),
								chars: node.get('chars')?.split(',') ?? ['face', 'bf']
							});
						}
					}
				}
				continue;
			}

			var path = Paths.xml('weeks/weeks/' + i + '/LIB_' + ModsFolder.currentModFolder);
			if (Assets.exists(path)) {
				var xml = Xml.parse(Assets.getText(path)).firstElement();

				for (node in xml.elementsNamed('song')) {
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
		if (blacklisted.indexOf(i.name) != -1)
			continue;
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
var prevY = null;
var diff = 0;
var offsetY = null;
var overlappingSquare = false;
var trackedHelpActive = false;
var oob = false;

function getChangesAvailable(s) {
	var song = metas.get(variation).get(songs[s].name);
	var res = [];
	if (song.opponentModeAllowed)
		res.push(HighscoreChange.COpponentMode);
	if (song.coopAllowed)
		res.push(HighscoreChange.CCoopMode);
	return res;
}

// hi jaye
function doSwipeBullshit(touch) {
	if (!(touch.pressed || touch.justReleased))
		return;
	var pos = touchPos(touch);
	if (touch.justPressed) {
		prevY = pos.y;
		if (offsetY != null)
			offsetY = camera.scroll.y + (camera.height * 0.5) - cameraTracker.y;
	}
	var _diff = prevY - pos.y;
	if (Math.abs(_diff) >= 1)
		diff = _diff;

	if (trackedHelpActive == help.active) {
		if (!overlappingSquare) {
			cameraTracker.y += (_diff) * (oob ? 0.4 : 1.0);
			if (touch.pressed) {
				camera.followEnabled = false;
				camera.scroll.y = (cameraTracker.y - (camera.height * 0.5));
				if (offsetY != null)
					camera.scroll.y += offsetY;
			}
		} else {
			prevY = offsetY = null;
		}
		if (touch.justReleased) {
			if (!overlappingSquare && (diff == _diff))
				cameraTracker.y += diff / camera.followLerp;
			offsetY = 0;
			overlappingSquare = false;
			camera.followEnabled = true;
		}
	}

	prevY = pos.y;
}

var disableBounding = false;

function checkOverlapSquare(touch) {
	if (!(touch.pressed || touch.justReleased))
		return;
	if (touch.pressed) {
		disableBounding = true;
		if (hoveringSong != -1 && !overlappingSquare) {
			overlappingSquare = true;
		}
	} else {
		overlappingSquare = false;
	}
}

function update(elapsed) {
	time += elapsed;
	FlxG.camera.bgColor = FlxColor.fromHSB(time * 50, 0.3, 0.4);
	fuck.shader.black = fuck2.shader.black = col2rgba(FlxColor.fromHSB(time * 50, 0.3, 1));
	fuck.shader.white = fuck2.shader.white = col2rgba(FlxColor.fromHSB(time * 50, 2, 0.5));
	trackedHelpActive = help.active;

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
	whiteSquare.alpha -= elapsed * 4;
	var square = songGroup.members[hoveringSong];
	if (square != null) {
		var targetX = square.x + (square.width - whiteSquare.width) * 0.5;
		var targetY = square.y + (square.height - whiteSquare.height) * 0.5;
		whiteSquare.x = lerp(whiteSquare.x, targetX, 1 / 3);
		whiteSquare.y = lerp(whiteSquare.y, targetY, 1 / 3);
		whiteSquare.scale.x = whiteSquare.width + Math.abs(whiteSquare.x - targetX);
		whiteSquare.scale.y = whiteSquare.height + Math.abs(whiteSquare.y - targetY);
		whiteSquare.angle = square.angle;
		whiteSquare.alpha = 1;
	}

	disableBounding = false;
	if (mobile) {
		for (touch in FlxG.touches.list) {
			checkOverlapSquare(touch);
		}
	} else {
		checkOverlapSquare(FlxG.mouse);
	}
	// trace(overlappingSquare);
	var maxH = extrasDown ? songGroup.height - (songMetadata.size * 0.5) : (songGroup.members[xtraIndex]?.y ?? 0) - (songMetadata.size * 0.5);
	if (!disableBounding) {
		cameraTracker.y = FlxMath.bound(cameraTracker.y, camera.height * 0.5, songGroup.y + maxH);
	}
	oob = (cameraTracker.y < (camera.height * 0.5)) || (cameraTracker.y > (songGroup.y + maxH));
	if (controls.UP)
		cameraTracker.y -= elapsed * scrollSpeed;
	if (controls.DOWN)
		cameraTracker.y += elapsed * scrollSpeed;

	if (FlxG.keys.justPressed.HOME) {
		cameraTracker.y = camera.height * 0.5;
	} else if (FlxG.keys.justPressed.END) {
		cameraTracker.y = songGroup.y + maxH;
	}

	cameraTracker.y += FlxG.mouse.wheel * (scrollSpeed * -0.1);

	if (mobile) {
		for (touch in FlxG.touches.list) {
			doSwipeBullshit(touch);
		}
	} else {
		camera.targetOffset.set(((FlxG.mouse.x - (camera.width * 0.5)) * 0.01), ((FlxG.mouse.y - (camera.height * 0.5)) * 0.01));
		doSwipeBullshit(FlxG.mouse); // they share almost the same properties
	}

	if (controls.getJustPressed('switchvar')) {
		variation = varList[FlxMath.wrap(++curVariation, 0, varList.length - 1)];
		CoolUtil.playMenuSFX(5, 0.6);
		updateExtrasColor(xtraIndex);
		songGroup.forEach(function(square) {
			square.shakeAmount = 5;
			if (square.ID != xtraIndex) {
				square.locked = songs[square.ID].locked;
				var targetMeta = metas.get(variation).get(songs[square.ID].name);
				if (targetMeta == null) {
					square.locked = true;
				} else {
					square.setColor(CoolUtil.getColorFromDynamic(targetMeta.color));
				}
			}
		});
		if (hoveringSong >= 0) {
			songGroup.members[hoveringSong].onOverlap();
		}
	}
	if (analyzer != null && FlxG.sound.music.playing) {
		var time = FlxG.sound.music.time;
		analyzerLevelsCache = analyzer.getLevels(time, FlxG.sound.music.calcTransformVolume(), vizbars.group.members.length, analyzerLevelsCache,
			CoolUtil.getFPSRatio(0.2), -30, 0, 100, 24000);
	} else {
		if (analyzerLevelsCache == null)
			analyzerLevelsCache = [];
		analyzerLevelsCache.resize(vizbars.group.members.length);
		// for (i in 0...analyzerLevelsCache.length) analyzerLevelsCache[i] = 0;
	}

	songOBG.color = FlxColor.fromHSB(time * 50, 0.2, 1);
	for (k => v in vizbars.group.members) {
		v.scale.y = analyzerLevelsCache[k] * bars.height;
		v.color = songOBG.color;
		v.y = songOBG.y;
	}
}

function songsquare(data) {
	var squa = new SongSquare(0, 0, null, data);
	squa.mobile = mobile;
	squa.group = songGroup;
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
	public var group:FlxSpriteGroup;
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
		overlaySprite.updateHitbox();
		overlaySprite.antialiasing = true;

		setColor(CoolUtil.getColorFromDynamic(data.color));

		initialOffsets = {x: 0, y: 0};
	}

	var __overlapped = false;

	public var __lastlock = false;

	public override function update(elapsed:Float) {
		super.update(elapsed);
		if (!visible)
			return;

		shakeAmount = FlxMath.lerp(shakeAmount, 0, elapsed * 6);

		frameOffset.set(FlxG.random.float(-shakeAmount, shakeAmount), FlxG.random.float(-shakeAmount, shakeAmount));
		frameOffset.x /= scale.x;
		frameOffset.y /= scale.y;
		angle = FlxG.random.float(-shakeAmount, shakeAmount) * 0.3;

		playSprite.x = this.x - (frameOffset.x * scale.x) + (this.width - playSprite.width) * 0.5;
		playSprite.y = this.y - (frameOffset.y * scale.y) + (this.height - playSprite.height) * 0.5;
		playSprite.visible = false;
		if (!accepted) {
			if (FlxG.mouse.overlaps(this)) {
				if (onOverlap != null && !__overlapped) {
					onOverlap();
					__overlapped = true;
				}
				if (!locked) {
					playSprite.visible = true;
				}
				if (mobile ? FlxG.mouse.justReleased : FlxG.mouse.justPressed)
					if (onClick != null)
						onClick();
			} else {
				if (__overlapped) {
					__overlapped = false;
					if (onExit != null) {
						onExit();
					}
				}
			}
		}
		overlaySprite.x = this.x - (frameOffset.x * scale.x);
		overlaySprite.y = this.y - (frameOffset.y * scale.y);
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
		var luminance = getLuminance(col);
		var brightestLuminance:Float = 0.83;

		if (useShader) {
			if (gm == null) {
				gm = new CustomShader('gradientMap');
				gm.black = [0, 0, 0, 1];
				gm.white = [1, 1, 1, 1];
				gm.mult = 1;
				this.shader = playSprite.shader = gm;
			}
			gm.black = getRGBArray((col & 0xffffff) + 0xFF000000);
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
		if (!visible || !isOnScreen(cameras[0]))
			return;
		super.draw();
		if (locked)
			overlaySprite.draw();
		else {
			if (playSprite.visible)
				playSprite.draw();
		}
	}

	public function setColorTransformOffset(sprite, color) {
		var c = getRGBArray(color & 0xffffff, false);
		sprite.setColorTransform(1, 1, 1, sprite.alpha, c[0], c[1], c[2]);
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
