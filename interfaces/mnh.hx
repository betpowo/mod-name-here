import flixel.math.FlxMath;
import PsychBar;
import funkin.backend.FunkinText;
import funkin.backend.system.framerate.Framerate;
import flixel.util.FlxColor;

public var testBar = new PsychBar(150, 150, 0, 0, 'game/healthBar', function() {
	return health / maxHealth;
}, 0, 1);

public var scoreTxt, missesTxt, accuracyTxt, rankTxt:FunkinText;
var accBar = new PsychBar(0, FlxG.height * 0.8 + 50, 0, 0, 'game/healthBar', null, 0, 1);
var accBG = new FunkinSprite();
public var comboGroup:FlxSpriteGroup = new FlxSpriteGroup();
public var forceComboXmlPos:Bool = false;
var game = PlayState.instance;
var scoreBG = new FunkinSprite();
var lerpHP:Float = 0.5;

function create() {
	for (content in Paths.getFolderContent('images/game/score/mnh', true, true))
		graphicCache.cache(Paths.getPath(content));

	PauseSubState.script = 'data/states/pause/mnh';

	currentUI = 'mnh';
}

function postCreate() {
	healthBar.visible = healthBarBG.visible = false;

	for (i in [game.scoreTxt, game.missesTxt, game.accuracyTxt]) {
		i.visible = i.exists = i.alive = i.active = false;
	}

	lerpHP = health / maxHealth;

	// kill
	scoreTxt = new FunkinText(healthBarBG.x + 50, healthBarBG.y, -1, "0", 16);
	missesTxt = new FunkinText(healthBarBG.x + 50, healthBarBG.y, -1, "0", 16);
	accuracyTxt = new FunkinText(healthBarBG.x + 50, healthBarBG.y, -1, "?", 16);
	rankTxt = new FunkinText(healthBarBG.x + 50, healthBarBG.y, -1, "---", 16);

	for (i in [scoreTxt, missesTxt, accuracyTxt, rankTxt]) {
		insert(1, i);
		i.camera = camHUD;

		i.font = Paths.font('sillyfont.ttf');
		i.size = 28;
		i.antialiasing = true;
		i.borderSize = 2.5;
		i.borderColor = 0xff3f0048;
		i.color = 0xeef7f1;
		i.alignment = 'center';
		i.fieldWidth = 475;
		i.screenCenter(0x01);
		i.offset.y = 6;
		i.height = 28;
	}
	scoreTxt.alignment = 'right';
	missesTxt.alignment = 'left';

	var offs = -10;

	scoreTxt.x -= offs;
	missesTxt.x += offs;
	accuracyTxt.x -= 36;
	rankTxt.x += 77;

	var uiImage = Paths.getSparrowAtlas('ui/mnh/ui');

	insert(0, testBar);
	testBar.camera = camHUD;
	testBar.addFuckers(PlayState.instance, members.indexOf(testBar));
	testBar.set_leftToRight(false);

	testBar.setColors(0xb20069, 0x33ff66);
	if (Options.colorHealthBar)
		testBar.setColors(dad?.iconColor, boyfriend?.iconColor);

	testBar.bg.frames = uiImage;
	testBar.bg.animation.addByIndices('idle', 'healthbar', [0, 1], '', 12, true);
	testBar.bg.animation.play('idle');
	testBar.bg.updateHitbox();
	testBar.width = testBar.bg.width = testBar.bg.frameWidth;
	testBar.set_barHeight(testBar.bg.frameHeight);
	testBar.screenCenter(0x01);
	testBar.barOffset.set(6, 3);
	for (bar in [testBar.leftBar, testBar.rightBar]) {
		bar.frames = uiImage;
		bar.animation.addByIndices('idle', 'healthbar', [2], '', 12, true);
		bar.animation.play('idle');
		bar.updateHitbox();
	}
	testBar.regenerateClips();
	testBar.set_barWidth(testBar.bg.frameWidth);
	testBar.y = FlxG.height * 0.8;
	setupFancyBarShaders();

	insert(members.indexOf(testBar.bg), accBG);
	accBG.camera = camHUD;
	accBG.makeGraphic(1, 1, -1);
	accBG.setGraphicSize(70, 70);
	accBG.updateHitbox();

	accBar.camera = camHUD;
	accBar.addFuckers(PlayState.instance, members.indexOf(testBar.bg));
	accBar.setColors(0xffcc66, 0xb20069);

	accBar.bg.frames = uiImage;
	accBar.bg.animation.addByPrefix('idle', 'accurext', 12, true);
	accBar.bg.animation.play('idle');
	accBar.bg.scale.set(0.8, 0.8);
	accBar.bg.updateHitbox();
	accBar.bg.screenCenter(0x01);
	accBar.barOffset.set(185, 1);
	accBar.regenerateClips();
	accBar.set_barWidth(150);
	accBar.set_barHeight(17);
	accBar.y = FlxG.height * 0.8 + 50;
	accBar.updateBar();

	accBG.x = accBar.bg.x + accBar.barOffset.x + 154;
	accBG.y = accBar.y + 3;

	for (i in iconArray) {
		i.y = 15 + testBar.y - i.height * 0.5;
	}

	reloadIcons([getIcon(dad), getIcon(boyfriend)]);

	accBar.bg.y = FlxG.height * 0.865;

	/*
		// rest in piece
		comboRatings[0].color = 0xb20069; // f
		comboRatings[1].color = 0xff3366; // e
		comboRatings[2].color = 0xff6633; // d
		comboRatings[3].color = 0xffcc66; // c
		comboRatings[4].color = 0x7be341; // b
		comboRatings[5].color = 0x00cc7b; // a
		comboRatings[6].color = 0x2eaeac; // s
		comboRatings[7].color = 0x99ffff; // s++
	 */

	// comboGroup.camera = camHUD;
	// comboGroup.setPosition(gf.x + (gf.width * 0.5) + 30, gf.y + 460);
	insert(members.indexOf(game.comboGroup) + 1, comboGroup);
	//comboGroup.add(new FlxSprite(-99999, 0));
	if (gf != null)
		comboGroup.scrollFactor.set(gf.scrollFactor.x, gf.scrollFactor.y);

	var shads = scripts.getByName('NoteHandler.hx').get('shaderMap');
	for (i => j in [
		[0xAB52FF, 0x150060],
		[0x47EAD9, 0x1A5598],
		[0xE5FF3E, 0x006B61],
		[0xFF439E, 0x710465]
	]) {
		shads.get(i).r = getFUCKINGcolor(j[0]);
		shads.get(i).b = getFUCKINGcolor(j[1]);
	}

	if (FlxG.save.data.compact) {
		for (i in [missesTxt, accuracyTxt, rankTxt, accBG]) {
			i.visible = i.active = i.alive = i.exists = false;
		}
		scoreTxt.x = FlxG.width * 0.5;
		scoreTxt.x += 350;
		scoreTxt.y -= 35;
		scoreTxt.alignment = 'right';
		scoreTxt.fieldWidth = 150;

		accBar.bg.x = -9999;
		iconP1.y += 20;
		iconP2.y += 20;

		testBar.x -= 180;
		testBar.y += 20;

		scoreBG.camera = camHUD;
		scoreBG.antialiasing = true;
		scoreBG.frames = uiImage;
		scoreBG.animation.addByPrefix('idle', 'score', 12, true);
		scoreBG.animation.play('idle');
		scoreBG.updateHitbox();
		insert(members.indexOf(scoreTxt), scoreBG);

		scoreBG.setPosition(scoreTxt.x - 80, scoreTxt.y - 22);
	}

	for (i in [scoreTxt, missesTxt, accuracyTxt, rankTxt]) {
		i.setPosition(Std.int(i.x), Std.int(i.y));
	}

	for (i in iconArray) {
		if (i.isPlayer)
			i.extraOffsets.x *= -1;
		i.updateHitbox();
		i.origin.x += i.extraOffsets.x;
		i.origin.y += i.extraOffsets.y;

		i.bump = () -> {
			var iconScale = 1.1;
			i.scale.set(i.defaultScale * iconScale, i.defaultScale * iconScale);
		}

		i.updateBump = () -> {
			var iconLerp = 0.17;
			i.scale.set(lerp(i.scale.x, i.defaultScale, iconLerp), lerp(i.scale.y, i.defaultScale, iconLerp));
		}
		if (i.isPlayer)
			i.extraOffsets.x *= -1;

		remove(i);
		insert(members.indexOf(testBar) + 1, i);
	}

	updateIconPositions = () -> {
		var iconOffset = 420;
		iconP1.screenCenter(0x01);
		iconP2.screenCenter(0x01);
		iconP1.x += iconOffset;
		iconP2.x -= iconOffset;

		if (FlxG.save.data.compact) {
			iconP2.x -= 60;
			iconP1.x -= 300;
		}

		// this part is inside the update pos function for some reason .
		// keep it to make sure nothing gameplay-related breaks
		var healthBarPercent = healthBar.percent;
		health = FlxMath.bound(health, 0, maxHealth);

		iconP1.health = healthBarPercent / 100;
		iconP2.health = 1 - (healthBarPercent / 100);
	}
	updateIconPositions();
}

function getIcon(char)
	return char != null ? ((char.icon != null) ? char.icon : char.curCharacter) : 'face';

var iconBop:Bool = true;
function beatHit(b) {}

function setupFancyBarShaders() {
	testBar.leftBar.shader = new FunkinShader('
	#pragma header
	uniform vec3 outlineColor;
	uniform float outlineSize;
	uniform float stupidFix;
	uniform float outlineOffset;
	float _max(float a, float b) {
		if (b > a) return b;
		return a;
	}
	void main() {
		vec2 uv = getCamPos(openfl_TextureCoordv);
		vec4 col = textureCam(bitmap, uv);
		if ((uv.x * _camSize.z) >= (_camSize.z - ((outlineSize * stupidFix) + _max(outlineOffset, 0.0)))) {
			gl_FragColor = vec4(outlineColor.rgb, 1.0) * col.a;
			return;
		}
		gl_FragColor = col;
	}
	');

	testBar.rightBar.shader = new FunkinShader('
	#pragma header
	uniform vec3 outlineColor;
	uniform float outlineSize;
	uniform float stupidFix;
	uniform float outlineOffset;
	float _max(float a, float b) {
		if (b > a) return b;
		return a;
	}
	void main() {
		vec2 uv = getCamPos(openfl_TextureCoordv);
		vec4 col = textureCam(bitmap, uv);
		if ((uv.x * _camSize.z) <= ((outlineSize * stupidFix) + _max(outlineOffset, 0.0))) {
			gl_FragColor = vec4(outlineColor.rgb, 1.0) * col.a;
			return;
		}
		gl_FragColor = col;
	}
	');

	testBar.leftBar.shader.outlineColor = [63.0 / 255.0, 0.0, 72.0 / 255.0];
	testBar.rightBar.shader.outlineColor = [241.0 / 255.0, 247.0 / 255.0, 1];

	for (i in [testBar.leftBar.shader, testBar.rightBar.shader]) {
		i.outlineSize = 5.0;
		i.stupidFix = 1.0;
		i.outlineOffset = 0.0;
	}
}

function postUpdate(elapsed) {
	// testBar.updateBar();
	accBar.percent = Math.max(accuracy * 100, 0);
	accBar.updateBar();

	var hp = Math.min(health, maxHealth);
	lerpHP = lerp(lerpHP, hp / maxHealth, 0.1);

	var val = (hp / maxHealth) - lerpHP;
	testBar.leftBar.shader.outlineOffset = val * -1 * testBar.leftBar.width;
	testBar.rightBar.shader.outlineOffset = val * testBar.rightBar.width;

	testBar.leftBar.shader.stupidFix = hp <= 0 ? 0 : 1;
	testBar.rightBar.shader.stupidFix = hp >= maxHealth ? 0 : 1;

	if (curRating.rating == '[N/A]') {
		curRating.rating = '---';
		curRating.color = 0xFFcc99cc;
	}

	scoreTxt.text = songScore;
	missesTxt.text = misses;
	accuracyTxt.text = CoolUtil.quantize(accuracy * 100, 100) + '%';
	if (accuracy < 0)
		accuracyTxt.text = '?';
	rankTxt.text = curRating.rating;
	accBG.color = curRating.color;
}

function reloadIcons(chars) {
	if (iconP1.curCharacter != chars[1]) {
		iconP1.extraOffsets.set(0, 0);
		iconP1.setIcon(chars[1]);
	}
	if (iconP2.curCharacter != chars[0]) {
		iconP2.extraOffsets.set(0, 0);
		iconP2.setIcon(chars[0]);
	}
}

function onChangeCharacter(e) {
	if (!e.event.params[3])
		return;

	if (e.memberIndex == 0) {
		if (e.strumIndex >= 2)
			return;
		var opp = (e.strumIndex == 0);
		var r = 0xb20069;
		var g = 0x33ff66;
		testBar.setColors(PlayState.opponentMode ? g : r, PlayState.opponentMode ? r : g);
		if (Options.colorHealthBar) {
			if (dad.iconColor != null) testBar.leftBar.color = dad.iconColor;
			if (boyfriend.iconColor != null) testBar.rightBar.color = boyfriend.iconColor;
		}
		reloadIcons([dad?.getIcon() ?? 'face', boyfriend?.getIcon() ?? 'face']);
		for (i in iconArray) {
			var scale = i.scale.x;
			i.scale.set(i.defaultScale, i.defaultScale);
			i.updateHitbox();
			i.y = 15 + testBar.y - i.height * 0.5;
			if (i.isPlayer)
				i.extraOffsets.x *= -1;
			i.updateHitbox();
			i.origin.x += i.extraOffsets.x;
			i.origin.y += i.extraOffsets.y;
			if (i.isPlayer)
				i.extraOffsets.x *= -1;
			i.scale.set(scale, scale);
		}
	}
}

function getThing(ae) {
	return ae > 80 ? 'win' : (ae < 20 ? 'lose' : 'idle');
}

function newRGBShader(?r:FlxColor = 0xff0000, ?g:FlxColor = 0x00ff00, ?b:FlxColor = 0x0000ff) {
	var aberration:CustomShader = new CustomShader('rgbPalette');
	aberration.mult = 1;
	aberration.r = [redf(r), greenf(r), bluef(r)];
	aberration.g = [redf(g), greenf(g), bluef(g)];
	aberration.b = [redf(b), greenf(b), bluef(b)];
	return aberration;
}

function red(col) {
	return (col >> 16) & 0xff;
}

function green(col) {
	return (col >> 8) & 0xff;
}

function blue(col) {
	return col & 0xff;
}

function redf(col) {
	return red(col) / 255;
}

function greenf(col) {
	return green(col) / 255;
}

function bluef(col) {
	return blue(col) / 255;
}

function getFUCKINGcolor(col) {
	return [redf(col), greenf(col), bluef(col)];
}

function onNoteCreation(e) {
	e.noteSprite = 'game/notes/minimal';
	e.note.splash = 'minimal';
}

function onStrumCreation(e) {
	e.sprite = 'game/notes/minimal';
}

function onHoldCoverCreation(e) {
	e.data.sprite = 'game/holds/minimal';
	e.data.x = 3;
	e.data.y = 10;
	e.data.scale = 0.7;
}

function onNoteHit(e) {
	e.ratingPrefix = 'game/score/mnh/';

	// combo = FlxG.random.int(0, 10000);
	if (e.showRating ?? (!e.note.isSustainNote && e.player)) {
		popUpScore(e);
	}

	e.ratingPrefix = 'game/score/';
	e.showRating = false;

	if (!forceComboXmlPos && gf != null)
		comboGroup.setPosition((gf.x + (gf.width - comboGroup.width) * 0.5) + 5, gf.y + 444);
	else
		comboGroup.setPosition(game.comboGroup.x - (comboGroup.width * 0.5), game.comboGroup.y - 30);
}

var thefuckingtimer = null;
var frame_length:Float = 2 / 24;

function popUpScore(e) {
	try {
		/*if (comboGroup.members.length > 0) {
			comboGroup.forEachAlive(function(spr) {
				spr.kill();
				comboGroup.remove(spr, true);
				spr.destroy();
			});
		}*/
		if (thefuckingtimer != null) {
			thefuckingtimer.cancel();
		}

		var numOffset = 0;

		// rating

		var rating:FlxSprite = comboGroup.members[0] ?? new FlxSprite();
		rating.frames = Paths.getFrames(e.ratingPrefix + 'ratings' + e.ratingSuffix);
		rating.animation.addByPrefix('idle', e.rating, 0, true);
		rating.animation.play('idle', true);
		rating.acceleration.y = 200;
		rating.velocity.set(0, 0);
		rating.angle = 0;
		rating.velocity.y -= FlxG.random.int(20, 60);
		rating.velocity.x = FlxG.random.int(-3, 3);
		rating.angularVelocity = FlxG.random.int(-5, 5);
		rating.scale.set(e.ratingScale, e.ratingScale);
		rating.antialiasing = e.ratingAntialiasing ?? true;
		rating.updateHitbox();
		rating.setPosition(0, rating.height * -0.5);
		numOffset = rating.width + 30;
		comboGroup.add(rating);
		rating.alpha = 1;
		FlxTween.cancelTweensOf(rating, ['alpha']);
		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		rating.scale.set(e.ratingScale * 1.1, e.ratingScale * 1.1);

		// numbers

		if (e.countAsCombo)
			combo += 1; // lazy

		var nums = [];

		if (combo >= minDigitDisplay) {
			var separatedScore = Std.string(combo).split('');
			if (combo < 10) {
				separatedScore = ['0', Std.string(combo)];
			}

			for (i in 0...separatedScore.length) {
				var bleh = separatedScore[i];
				var num:FlxSprite = comboGroup.members[i + 1] ?? new FlxSprite();
				num.frames = Paths.getFrames(e.ratingPrefix + 'ratings' + e.ratingSuffix);
				num.animation.addByPrefix('idle', 'num' + bleh, 0, true);
				num.animation.play('idle', true);
				num.acceleration.y = 200;
				num.velocity.set(0, 0);
				num.angle = 0;
				num.velocity.y -= FlxG.random.int(20, 60);
				num.velocity.x = FlxG.random.int(-5, 5) + 3;
				num.angularVelocity = FlxG.random.int(-5, 5);
				num.scale.set(e.numScale, e.numScale);
				num.antialiasing = e.numAntialiasing ?? true;
				num.updateHitbox();
				num.setPosition(numOffset + (num.width * i), num.height * -0.5);
				comboGroup.add(num);
				num.alpha = 1;
				FlxTween.cancelTweensOf(num, ['alpha']);
				FlxTween.tween(num, {alpha: 0}, 0.2, {
					startDelay: (Conductor.crochet * 0.002) + FlxG.random.float(-0.4, 0.1)
				});
				nums.push(num);
				num.scale.set(e.numScale * 1.1, e.numScale * 1.1);
			}
			if (comboGroup.members.length > separatedScore.length + 1) {
				for (idx => i in comboGroup.members) {
					if (idx > separatedScore.length) {
						comboGroup.remove(i, true);
						i.kill();
						i.destroy();
					}
				}
			}
		}
		if (e.countAsCombo)
			combo -= 1; // lazy

		// idk
		thefuckingtimer = new FlxTimer().start(frame_length, (_) -> {
			rating.scale.set(e.ratingScale, e.ratingScale);
			for (i in nums)
				i.scale.set(e.numScale, e.numScale);
		});
	} catch (e:Dynamic) {
		trace(e);
	}
}

var prevSprite:FlxSprite = null;

function onCountdown(e) {
	e.volume = 0.6;
	if (e.spritePath != null) {
		e.spritePath = StringTools.replace(e.spritePath, 'game', 'game/score/mnh');
		e.scale = 1.05;
	}
	if (prevSprite != null && e.swagCounter < introLength - 1) {
		prevSprite.kill();
	}
}

function onPostCountdown(e) {
	if (e.spriteTween != null)
		e.spriteTween.cancel();
	if (e.sound != null)
		e.sound.pitch = FlxG.random.float(0.7, 1.6);
	prevSprite = e.sprite;
	var sounds = [null, 'menu/cancel', 'pixel/clickText', 'pixel/ANGRY_TEXT_BOX'];
	if (sounds[e.swagCounter] != null && e.soundPath != null)
		FlxG.sound.play(Paths.sound(sounds[e.swagCounter]), 0.5).pitch = 1.3;

	if (prevSprite != null) {
		prevSprite.zoomFactor = 0;
		prevSprite.cameras = [camGame];
		new FlxTimer().start(frame_length, function(_) {
			prevSprite.scale.set(1, 1);
		});

		if (e.swagCounter == introLength - 2) {
			prevSprite.moves = true;
			prevSprite.velocity.x = FlxG.random.float(-200, 200);
			prevSprite.velocity.y -= FlxG.random.float(90, 300);
			prevSprite.acceleration.y = 700;
			prevSprite.angularVelocity = FlxG.random.float(-1, 1) * ((e.swagCounter == introLength - 2) ? 60 : 20);
		}
	}
}

function onLyricSetup(e) {
	e.background.visible = false;
	e.text.font = Paths.font('sillyfont.ttf');
	e.text.borderSize = 2.5;
	e.text.borderColor = 0xff3f0048;

	e.text.updateHitbox();
	e.text.screenCenter();
	e.text.y = FlxG.height - 150 - e.text.height;

	e.text.antialiasing = true;
}
