import haxe.io.Path;
import haxe.ds.ArraySort;
import flixel.text.FlxBitmapText;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import funkin.backend.system.FunkinSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxObject;
import hxvlc.flixel.FlxVideoSprite;
import flxanimate.data.Loop;
import funkin.backend.MusicBeatTransition;
import flixel.tweens.FlxTweenManager;
import flixel.tweens.misc.VarTween;

var camFront = new FlxCamera();
var scoreGroup = new FlxSpriteGroup();
var rank = 'shit';
var targetNum = 0;
var camFollow = new FlxObject(0, 0, 1, 1);

function getRankTrueName() {
	if (rank == 'shit')
		return 'LOSS';
	if (rank == 'perfect' && targetNum == 99)
		return 'PERFECT?';
	return rank.toUpperCase();
}

// fnf dev ass function
function getRankDataName() {
	if (targetNum == 100)
		return 'PERFECT_GOLD';
	if (rank == 'shit')
		return 'LOSS';
	return rank.toUpperCase();
}

function getFromNum(real) {
	var rankID = 'shit'; // loss
	if (real >= 69)
		rankID = 'good'; // good
	if (real >= 80)
		rankID = 'great'; // great
	if (real >= 90)
		rankID = 'excellent'; // excellent
	if (real >= 99)
		rankID = 'perfect'; // perfect
	return rankID;
}

function create() {
	if (data == null) {
		data = [
			'total' => 1,
			'max' => 0,
			'sick' => 0,
			'good' => 0,
			'bad' => 0,
			'shit' => 1,
			'miss' => 69420,
			'score' => 4,
			'accuracy' => 0.08 // 8%
		];
	}
	rank = getFromNum(targetNum = Std.int(Math.max(0, data['accuracy']) * 100));

	/*var resultStr = '';
		for (idx => i in __script__.parser.input.split('\r')) {
			resultStr += '\n' + (idx + 1) + ' : ' + StringTools.replace(i, '\n', '');
		}
		trace(resultStr); */
}

function getRankMiscData() {
	var struc = {
		delay: 95 / 24,
		musicDelay: 4 / 24
	};

	switch (rank) {
		case 'excellent':
			struc.delay = 97 / 24;
			struc.musicDelay = 0.01;

		case 'perfect':
			struc.musicDelay = 95 / 24;
	}

	// for comedic effect
	if (forceLossSprites) {
		struc.delay = 111 / 24;
		struc.musicDelay = 111 / 24;
	}

	return struc;
}

function shouldForceLoss() {
	var sog = PlayState.SONG.meta.name;
	if ((['weird-song'].indexOf(sog) != -1) || ((sog == 'tu-madre' && PlayState.isStoryMode))) {
		return true;
	}
	return false;
}

// BECAUSE ITS FUNNY Okay.
var forceLossSprites = shouldForceLoss();

function getBGColors() {
	var r = {
		bg: 0xffFECC5C,
		text: 0xfeda6c
	};

	if (PlayState.coopMode) {
		r.bg = 0xffffbbb6;
		r.text = 0xffcccc;
	}

	if (PlayState.opponentMode) {
		r.bg = 0xFF99ddcc;
		r.text = 0xaaeedd;
	}

	// switched co-op mode which doesnt work for some reason
	if (PlayState.opponentMode && PlayState.coopMode) {
		r.bg = 0xffeeffb8;
		r.text = 0xd8ff99;
	}

	return r;
}

var percentTween;

function postCreate() {
	FlxG.camera.bgColor = getBGColors().bg;
	FlxG.camera.width *= 1.5;
	FlxG.camera.height *= 1.5;
	FlxG.camera.setPosition((FlxG.width - FlxG.camera.width) * 0.5, (FlxG.height - FlxG.camera.height) * 0.5);
	FlxG.camera.scroll.x = FlxG.camera.x;

	// backdrops and bitmap texts will not rotate with camera angle
	// for some reason so we have to go back to the caveman era
	FlxG.camera.rotateSprite = true;

	FlxG.camera.angle = -3.8;
	FlxG.cameras.add(camFront, false);

	camFollow.screenCenter();
	for (bleh in [FlxG.camera, camFront]) {
		bleh.follow(camFollow, 0, 0.04);
	}
	FlxG.camera.snapToTarget();
	camFront.bgColor = 0x00000000;
	FlxG.sound.music?.stop();

	scrollers = [];

	var dumpTxt = new FunkinText();
	dumpTxt.font = Paths.font('5by7_bold.ttf');
	dumpTxt.borderSize = dumpTxt.borderColor = 0;
	dumpTxt.color = getBGColors().text;
	dumpTxt.size = 64;
	dumpTxt.text = getRankTrueName();
	// dumpTxt.text = 'FUCKING KILL YOURSELF';
	dumpTxt.drawFrame(true);

	for (idx => i in [-1, 1]) {
		var img = dumpTxt.pixels;
		var shit = new FlxBackdrop(img);
		var pad = shit.height * 1.75;
		if (i == 1)
			shit.y = FlxMath.lerp(shit.height, pad, 0.5);
		shit.velocity.x = 7 * i;
		shit.spacing.y = pad;
		shit.spacing.x = 18;
		shit.visible = false;
		shit.antialiasing = true;
		shit.scrollFactor.set(0.3, 0.3);
		add(shit);
		scrollers[idx] = shit;
	}

	var fontLetters:String = "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz:1234567890!?,.()-Ññ&\"'+[]/#_|;{}><❤";
	songName = new FlxBitmapText(567, -100, 'bleh',
		FlxBitmapFont.fromMonospace(Paths.image('results/base/tardlingSpritesheet'), fontLetters, FlxPoint.get(49, 62)));
	songName.text = 'coño e su madre';
	songName.letterSpacing = -15;
	songName.antialiasing = true;
	songName.scrollFactor.set(1, 1);
	add(songName);
	FlxTween.tween(songName, {y: 125}, 0.5, {ease: FlxEase.quartOut, startDelay: 0.9});

	songName.text = 'Skibidi Sigma Pomni Digital Fortnite Chamba Free Gigachad Rizz OMG Flow xxxTentacion Hotmail Lionel Ronaldo Jr. Mewing III Chiki Ibai Xocas Ete Sech Golden Toy Puppet Ohio Ruben-tuesta YouTube Pro Insano Globo de Texto 51 Decadencia 777';

	if (PlayState.SONG != null) {
		songName.text = (PlayState.SONG.meta.displayName ?? 'Unknown') + ' by ' + (PlayState.SONG.meta.customValues?.composer ?? 'Unknown');
		if (PlayState.isStoryMode && PlayState.storyWeek != null) {
			songName.text = PlayState.storyWeek.name;
		}
	}

	clearBig = new ClearPercentCounter(800, 300);
	Reflect.setProperty(clearBig, 'cameras', [camFront]);
	add(clearBig);
	clearBig.number = 0;
	clearBig.alpha = 0.001;
	clearBig.scrollFactor.set(0.5, 0.5);

	var fuckkk = FlxG.sound.load(Paths.sound('menu/scroll'));
	fuckkk.pitch = 0.9;
	var twn = null;
	FlxTween.tween(clearBig, {alpha: 1}, 0.4, {
		startDelay: 0.5,
		onComplete: (_) -> {
			percentTween = FlxTween.num(0, targetNum - 0.5, 3, {
				ease: FlxEase.quartOut,
				onComplete: (_) -> {
					clearBig.number = Math.max(0, targetNum - 1);
				}
			}, function(num) {
				if (clearBig.number != (clearBig.number = Std.int(Math.max(0, num)))) {
					fuckkk.play(true, 38);
					fuckkk.pitch += 0.004;

					if (twn != null)
						twn.start();
					else {
						twn = FlxTween.num(3, 0, 0.8, {
							ease: FlxEase.expoOut
						}, function(num) {
							clearBig.frameOffset.x = FlxG.random.float(1, -1) * num;
							clearBig.frameOffset.y = FlxG.random.float(1, -1) * num;
						});
					}
				}
			});
		}
	});

	clearSmall = new ClearPercentCounter(567, 125);
	clearSmall.big = false;
	add(clearSmall);
	clearSmall.number = Std.int(targetNum);
	clearSmall.alpha = 0.001;

	var chosen = Json.parse(Assets.getText(Paths.json('states/_results-chars/bf')));
	for (i in Paths.getFolderContent('data/states/_results-chars')) {
		var path = Paths.json('states/_results-chars/' + Path.withoutExtension(i));
		var choice = Json.parse(Assets.getText(path));
		if (PlayState.SONG != null && choice?.ownedChars.contains(PlayState.SONG.strumLines[1].characters[0]) ?? false) {
			chosen = choice;
		}
	}

	makefuckingidiot(chosen.results);

	var blehh = new FunkinSprite(-50).makeSolid(FlxG.width * 2, 400);
	blehh.color = 0;
	blehh.y = -490;
	blehh.angle = FlxG.camera.angle;
	blehh.antialiasing = true;
	blehh.cameras = [camFront];
	FlxTween.tween(blehh, {y: -333}, 7 / 24, {ease: FlxEase.quartOut, startDelay: 3 / 24});

	resultsAnim = new FlxSprite(-200, -10);
	resultsAnim.frames = Paths.getFrames('results/base/results');
	resultsAnim.animation.addByPrefix("result", "results instance 1", 24, false);
	resultsAnim.visible = false;
	new FlxTimer().start(6 / 24, _ -> {
		resultsAnim.visible = true;
		resultsAnim.animation.play("result");
	});
	resultsAnim.antialiasing = true;
	resultsAnim.cameras = [camFront];

	soundSystem = new FlxSprite(-15, -180);
	soundSystem.frames = Paths.getFrames('results/base/soundSystem');
	soundSystem.animation.addByPrefix("idle", "sound system", 24, false);
	soundSystem.visible = false;
	new FlxTimer().start(8 / 24, _ -> {
		soundSystem.animation.play("idle");
		soundSystem.visible = true;
	});
	add(soundSystem);
	soundSystem.antialiasing = true;
	soundSystem.cameras = [camFront];

	ratingsPopin = new FlxSprite(-135, 135);
	ratingsPopin.frames = Paths.getFrames('results/base/ratingsPopin');
	ratingsPopin.animation.addByPrefix("idle", "Categories", 24, false);
	ratingsPopin.visible = false;
	new FlxTimer().start(21 / 24, _ -> {
		ratingsPopin.animation.play("idle");
		ratingsPopin.visible = true;
	});
	add(ratingsPopin);
	ratingsPopin.antialiasing = true;
	ratingsPopin.cameras = [camFront];

	scorePopin = new FlxSprite(-180, 515);
	scorePopin.frames = Paths.getFrames('results/base/scorePopin');
	scorePopin.animation.addByPrefix("idle", "tally score", 24, false);
	scorePopin.visible = false;
	new FlxTimer().start(31 / 24, _ -> {
		scorePopin.animation.play("idle");
		scorePopin.visible = true;
	});
	add(scorePopin);
	scorePopin.antialiasing = true;
	scorePopin.cameras = [camFront];

	add(scoreGroup);
	scoreGroup.cameras = [camFront];

	for (i in 0...10) {
		var bleh = new ScoreGuy(i * 61, 0);
		bleh.ID = i;
		bleh.setNumber(-1);
		scoreGroup.add(bleh);
	}

	scoreGroup.setPosition(69, 605);

	for (index => i in [
		[375, 150, -1],
		[375, 200, -1],
		[230, 277, 0x89e59E],
		[210, 331, 0x89c9e5],
		[190, 385, 0xe6cf8a],
		[220, 439, 0xe68c8a],
		[260, 493, 0xc68ae6],
	]) {
		var intendedNums = [
			data['total'],
			data['max'],

			data['sick'],
			data['good'],
			data['bad'],
			data['shit'],
			data['miss']
		];

		var tal = new TallyCounter(i[0], i[1]);
		Reflect.setProperty(tal, 'cameras', [camFront]);
		add(tal);
		tal.number = 0;
		tal.color = i[2];
		tal.visible = false;

		new FlxTimer().start((0.3 * index) + 1.20, _ -> {
			tal.visible = true;
			FlxTween.num(0, intendedNums[index], 0.5, {ease: FlxEase.quartOut}, function(num) {
				tal.number = Std.int(num);
			});
		});
	}

	scoreGroup.visible = false;

	new FlxTimer().start(37 / 24, _ -> {
		scoreGroup.visible = true;

		var score = Math.abs(data['score']);
		var splitScore = Std.string(score).split('');
		var hsv = new CustomShader('adjustColor');
		hsv.hue = 140;
		hsv.saturation = -50;
		hsv.brightness = 100;
		hsv.contrast = 1000;

		for (i in 0...splitScore.length) {
			var index = i + (10 - splitScore.length);
			new FlxTimer().start(i / 24, () -> {
				scoreGroup.members[index].shuffle(Std.parseInt(splitScore[i]), () -> {
					if (data['score'] < 0) {
						scoreGroup.members[index].color = 0x369fff;
						scoreGroup.members[index].shader = hsv;
					}
				});
			});
		}
	});

	dumpTxt.text = getRankTrueName();
	dumpTxt.size = 78;
	dumpTxt.fieldWidth = Std.int(dumpTxt.size * 0.75);
	dumpTxt._defaultFormat.leading = 20;
	dumpTxt.updateDefaultFormat();
	dumpTxt.borderSize = 4.5;
	dumpTxt.borderColor = dumpTxt.color = 0xffffffff;
	dumpTxt.drawFrame(true);

	grahh = new FlxBackdrop(dumpTxt.pixels, 0x10, 0, 30);
	add(grahh);
	grahh.antialiasing = true;
	Reflect.setProperty(grahh, 'cameras', [camFront]);
	grahh.x = FlxG.width - grahh.width - 5;
	grahh.scrollFactor.set(0, 0);
	grahh.visible = false;

	add(blehh);
	add(resultsAnim);

	var grah = forceLossSprites ? 'resultsSHIT' : Reflect.field(chosen.results.music, getRankDataName());
	playMusicWithIntro('results/' + grah, getRankMiscData().musicDelay);
}

function playMusicWithIntro(_path, delay) {
	var path = Paths.music(_path);
	var introPath = StringTools.replace(path, '.ogg', '-intro.ogg');
	var doIntro = Assets.exists(introPath);
	var offPitch = 0.965;
	if (forceLossSprites)
		offPitch = 1;

	FlxG.sound.load(path);

	if (doIntro)
		FlxG.sound.load(introPath);

	new FlxTimer().start(delay, (_) -> {
		FlxG.sound.playMusic(doIntro ? introPath : path, 1, !doIntro);
		if (doIntro) {
			FlxG.sound.music.onComplete = () -> {
				FlxG.sound.playMusic(path);
				FlxG.sound.music.onComplete = null;
				if (targetNum == 99)
					FlxG.sound.music.pitch = offPitch;
			};
		}
		if (targetNum == 99)
			FlxG.sound.music.pitch = offPitch;
	});
}

var cache = [];

function makefuckingidiot(_params) {
	if (!StringTools.endsWith(_params.folder, '/'))
		_params.folder += '/';
	var defaultParams = [
		{
			renderType: "animateatlas",
			assetPath: "resultsSHIT",
			offsets: [0, 20],
			loopFrame: 149
		}
	];

	var params = Reflect.field(_params, forceLossSprites ? 'loss' : getRankDataName().toLowerCase());
	if (params == null) {
		_params.folder = 'results/base/results-bf/';
		params = defaultParams;
	}

	for (i in params) {
		i.zIndex ??= 500;
	}
	params.sort((a, b) -> {
		return a.zIndex - b.zIndex;
	});
	var sprites = params;

	for (i in sprites) {
		if (!Reflect.hasField(i, 'loopFrame'))
			Reflect.setField(i, 'loopFrame', 0);

		var bf = new FunkinSprite(i.offsets[0], i.offsets[1]);
		bf.cameras = [camFront];
		bf.antialiasing = true;
		bf.loadSprite(Paths.image(_params.folder + i.assetPath));
		if (i.renderType == 'sparrow') {
			bf.animation.addByPrefix('idle', '', 24, false);
			bf.animation.play('idle', true);
			bf.updateHitbox();
			bf.animation.finishCallback = (_name:String) -> {
				bf.animation.play('idle', true);
				bf.animation.curAnim.curFrame = i.loopFrame;
			};
		} else if (i.renderType == 'animateatlas') {
			var an = bf.animateAtlas.anim;
			an.play();
			an.curInstance.symbol.loop = Loop.PlayOnce;
		}
		// trace(i);
		bf.visible = bf.active = false;
		bf.scrollFactor.set(0.94, 0.94);
		if (i.scale != null) {
			bf.scale.set(i.scale, i.scale);
		}
		if (i.scroll != null) {
			bf.scrollFactor.x *= i.scroll;
			bf.scrollFactor.y *= i.scroll;
		}
		cache.push({sprite: bf, data: i});
		add(bf);
	}

	new FlxTimer().start(getRankMiscData().delay, (fuck) -> {
		for (i in cache) {
			var lol = () -> {
				i.sprite.active = i.sprite.visible = true;
			}
			if (i.data.delay > 0) {
				new FlxTimer().start(i.data.delay, (_) -> {
					lol();
				});
			} else {
				lol();
			}
		}

		FlxG.camera.flash(0xffffffff, 0.1, null, true);
		for (shit in scrollers) {
			shit.visible = true;
		}
		CoolUtil.playMenuSFX(1);
		// flicker
		new FlxTimer().start(3 / 24, (_) -> {
			if (_.loopsLeft == 0) {
				grahh.velocity.y = -80;
			} else {
				grahh.visible = !grahh.visible;
				var fu = _.loopsLeft % 2 == 0 ? 255 : 0;
				clearSmall.setColorTransform(1, 1, 1, 1, fu, fu, fu);
				clearBig.setColorTransform(1, 1, 1, 1, fu, fu, fu);
			}
		}, 10);

		if (percentTween != null)
			percentTween.finish();

		FlxTween.tween(songName.offset, {x: (clearSmall.graphWidth * -1) - 40}, 2, {ease: FlxEase.expoOut});
		clearSmall.alpha = 1;
		clearBig.number = clearSmall.number;

		FlxTween.tween(clearBig, {alpha: 0}, 0.4, {startDelay: 1.7});
	});
}

var _timeUntilScroll = 5;
var _timeUntilNextScroll = 5;
var canPress = true;

function postUpdate(elapsed) {
	if (_timeUntilScroll < 0) {
		_timeUntilScroll = 0;
	} else if (_timeUntilScroll == 0) {
		var max = 125;
		songName.velocity.x = FlxMath.bound(songName.velocity.x + (elapsed * max * -1), max * -1, 0);
		clearSmall.x = songName.x;

		if (songName.x - songName.offset.x + songName.width <= 500) {
			if (_timeUntilNextScroll < 0) {
				_timeUntilNextScroll -= elapsed;
			} else {
				_timeUntilScroll = 5;
				_timeUntilNextScroll = 5;
				songName.setPosition(567, -100);
				clearSmall.setPosition(songName.x, -100);
				songName.velocity.x = 0;
				FlxTween.tween(clearSmall, {y: 125}, 0.5, {ease: FlxEase.quartOut, startDelay: 0.75});
				FlxTween.tween(songName, {y: 125}, 0.5, {ease: FlxEase.quartOut, startDelay: 0.9});
			}
		}
	} else {
		_timeUntilScroll -= elapsed;
	}

	/*for (i in FUCK) {
		if (i != null) i(elapsed);
	}*/

	for (i in cache) {
		if (i.data.renderType == 'animateatlas') {
			var an = i.sprite.animateAtlas.anim;
			if (an.finished) {
				an.curFrame = i.data.loopFrame;
				an.isPlaying = true;
			}
		}
	}

	camFollow.x = FlxMath.bound(camFollow.x, FlxG.width * 0.5, FlxG.width * 1.5);
	var vel = 700;
	if (controls.LEFT)
		camFollow.x -= elapsed * vel;
	if (controls.RIGHT)
		camFollow.x += elapsed * vel;

	FlxG.camera.targetOffset.y = ((FlxG.width * 0.5) - camFollow.x) * Math.sin(FlxG.camera.angle * (Math.PI / 180));

	// trace(FlxG.plugins.list);

	var pressedEnter:Bool = controls.ACCEPT || controls.BACK;

	if (mobile) {
		for (touch in FlxG.touches.list) {
			if (touch.justPressed) {
				pressedEnter = true;
			}
		}
	}

	if (pressedEnter && canPress) {
		canPress = false;
		if (FlxG.sound.music != null) {
			forceTween().tween(FlxG.sound.music, {volume: 0}, 0.8, {
				onComplete: (_) -> {
					FlxG.sound.music.stop();
				}
			});
			forceTween().tween(FlxG.sound.music, {pitch: 3}, 0.1, {
				onComplete: (_) -> {
					FlxTween.tween(FlxG.sound.music, {pitch: 0.5}, 0.4);
				}
			});
		}
		MusicBeatTransition.script = 'data/states/StickerTransition';
		FlxG.switchState(PlayState.isStoryMode ? new StoryMenuState() : new FreeplayState());
	}
}

function destroy() {
	FlxG.camera.bgColor = 0;
}

class TallyCounter extends flixel.FlxSprite {
	public var number:Int = 0;

	public function new(x, y, ?sg) {
		super();
		setPosition(x, y);
		frames = Paths.getFrames('results/base/tallieNumber');
		for (bleh in 0...10) {
			var str = Std.string(bleh);
			animation.addByPrefix(str, str + ' small', 0, true);
		}
		animation.play('0', true);
		antialiasing = true;
	}

	public override function draw() {
		var ogx = x;
		var width = 40;
		var splitStr = Std.string(number).split('');
		splitStr.remove('-'); // ???
		var index = 0;
		for (i in splitStr) {
			x = ogx + (width * index);
			animation.play(i, true);
			super.draw();
			index += 1;
		}
		x = ogx;
	}
}

class ScoreGuy extends flixel.FlxSprite {
	// -1: disabled, -2: gone
	public var number:Int = -1;

	public function new(x, y, ?sg) {
		super();
		setPosition(x, y);
		frames = Paths.getFrames('results/base/score-digital-numbers');
		for (idx => bleh in ['ZERO', 'ONE', 'TWO', 'THREE', 'FOUR', 'FIVE', 'SIX', 'SEVEN', 'EIGHT', 'NINE']) {
			var str = Std.string(bleh);
			animation.addByPrefix(Std.string(idx), str + ' DIGITAL', 24, false);
		}
		animation.addByPrefix('disabled', 'DISABLED', 24, false);
		animation.addByPrefix('gone', 'GONE', 24, false);

		animation.play('gone', true);

		antialiasing = true;
	}

	public function shuffle(finalNum:Int = 0, ?_onFinish) {
		var finall = finalNum;
		var finish = _onFinish;
		setNumber(-1);
		var duration:Float = 41 / 24;
		var interval:Float = 1 / 24;
		var shuffleTimer = new FlxTimer().start(interval, (_) -> {
			var tempDigit:Int = number;
			tempDigit += 1;
			tempDigit %= 10;
			setNumber(tempDigit, false);

			if (_.loops > 0 && _.loopsLeft == 0) {
				FlxTween.num(0, finall, 2 + (ID * 0.01), {
					ease: FlxEase.quartOut,
					onComplete: (_) -> {
						setNumber(finall, true);
						if (finish != null)
							finish();
					}
				}, function(num) {
					setNumber(Std.int(num), false);
				});
			}
		}, Std.int(duration / interval));
	}

	public function setNumber(num:Int = 0, ?glow:Bool = true) {
		number = num ?? 0;
		if (num >= 0)
			animation.play(Std.string(num), true, false, glow ? 0 : 4);
		else
			animation.play(num == -1 ? 'disabled' : 'gone', true);
		centerOffsets(false);
	}
}

class ClearPercentCounter extends flixel.FlxSprite {
	public var number:Int = 0;
	public var big:Bool = true;

	public function new(x, y, ?sg) {
		super();
		setPosition(x, y);
		antialiasing = true;
		frames = Paths.getFrames('results/base/clearPercentText');
		animation.addByPrefix('bg', 'clearPercentText', 0, true);
		animation.addByPrefix('big', 'numbers0', 0, true);
		animation.addByPrefix('small', 'numbers small', 0, true);
		animation.play('bg', true);

		antialiasing = true;
	}

	public var graphWidth = 0;

	public override function draw() {
		var ogpos = {x: x, y: y};
		if (big) {
			animation.play('bg', true);
			super.draw();
		}

		var _width = big ? 80 : 30;
		var splitStr = Std.string(number).split('');
		var offsex = splitStr.length * _width;
		var offsex2 = 160;
		if (!big) {
			splitStr.push('10'); // percent
			offsex = offsex2 = 0;
		} else {
			y += 69;
		}
		for (index => i in splitStr) {
			scale.set(1, 1);
			x = ogpos.x + (_width * index) - offsex + offsex2;
			animation.play(big ? 'big' : 'small', true, false, Std.parseInt(i));
			if (i == '10')
				scale.set(1.25, 1.25);
			updateHitbox();
			super.draw();
		}

		graphWidth = x - ogpos.x + frameWidth;
		setPosition(ogpos.x, ogpos.y);
	}
}
