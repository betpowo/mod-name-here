import flixel.math.FlxMath;
import PsychBar;
import funkin.backend.FunkinText;
import funkin.backend.system.framerate.Framerate;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import flixel.text.FlxTextFormat;
import flixel.text.FlxTextFormatMarkerPair;

public var testBar = new PsychBar(150, 150, 0, 0, 'game/healthBar', function() {
	return health / maxHealth;
}, 0, 1);

public var scoreTxt, missesTxt, accuracyTxt, rankTxt:FunkinText;
var accBar = new PsychBar(0, FlxG.height * 0.8 + 50, 0, 0, 'game/healthBar', null, 0, 1);
var accBG = new FunkinSprite();
public var comboDefaultPos = FlxPoint.get();
public var forceComboXmlPos:Bool = false;
var game = PlayState.instance;
var scoreBG = new FunkinSprite();
var lerpHP:Float = 0.5;
var bruhhhFormatFR = new FlxTextFormat();
var bruhhhFormat = new FlxTextFormatMarkerPair(bruhhhFormatFR, "*");

function create() {
	for (content in Paths.getFolderContent('images/game/score/mnh', true, true))
		graphicCache.cache(Paths.getPath(content));

	PauseSubState.script = 'data/states/pause/mnh';
	for (i => j in [
		[0xAB52FF, 0x150060],
		[0x47EAD9, 0x1A5598],
		[0xE5FF3E, 0x006B61],
		[0xFF439E, 0x710465]
	]) {
		noteColors[i][0] = j[0];
		noteColors[i][2] = j[1];
	}
	gameOverBGColor = 0xFF330066;
	currentUI = 'mnh';
}

function postCreate() {
	healthBar.visible = healthBarBG.visible = false;

	for (i in [game.scoreTxt, game.missesTxt, game.accuracyTxt]) {
		i.visible = i.exists = i.alive = i.active = false;
	}

	lerpHP = health / maxHealth;
	// kill
	var startY = FlxG.height - 90;
	scoreTxt = new FunkinText(healthBarBG.x + 50, startY - 3, -1, "0", 16);
	missesTxt = new FunkinText(healthBarBG.x + 50, startY - 3, -1, "0", 16);
	accuracyTxt = new FunkinText(healthBarBG.x + 50, startY, -1, "?", 16);
	rankTxt = new FunkinText(healthBarBG.x + 50, startY, -1, "---", 16);

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
		i.height = i.size;
	}
	bruhhhFormatFR.format.size = 20;
	bruhhhFormatFR.format.bold = true;
	bruhhhFormatFR.borderColor = 0xff3f0048;

	scoreTxt.alignment = 'right';
	missesTxt.alignment = 'left';

	scoreTxt.origin.x = scoreTxt.fieldWidth;
	scoreTxt.scale.set(0.8, 0.8);
	missesTxt.origin.x = 0;
	missesTxt.scale.set(0.8, 0.8);

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
	testBar.y = startY - 50;
	setupFancyBarShaders();

	accBar.camera = camHUD;
	accBar.addFuckers(PlayState.instance, members.indexOf(testBar.leftBar));
	accBar.setColors(0xffcc66, 0xb20069);
	insert(members.indexOf(accBar.bg), accBG);
	accBG.camera = camHUD;
	accBG.makeGraphic(1, 1, -1);
	accBG.setGraphicSize(70, 70);
	accBG.updateHitbox();

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
	accBar.updateBar();
	accBar.bg.y = startY - 35;

	accBG.x = accBar.bg.x + accBar.barOffset.x + 154;
	accBG.y = accBar.bg.y + 3;

	for (i in iconArray) {
		i.y = 15 + testBar.y - i.height * 0.5;
	}

	reloadIcons([getIcon(dad), getIcon(boyfriend)]);

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
	comboDefaultPos.set(comboGroup.x, comboGroup.y);
	// comboGroup.add(new FlxSprite(-99999, 0));
	if (gf != null)
		comboGroup.scrollFactor.set(gf.scrollFactor.x, gf.scrollFactor.y);

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

	// optimizing 100
	if (gf != null) {
		gf.extra['combox'] ??= 0; gf.extra['comboy'] ??= 0;
		if (gf.extra['combox'] is String)
			gf.extra['combox'] = Std.parseFloat(gf.extra['combox']);

		if (gf.extra['comboy'] is String)
			gf.extra['comboy'] = Std.parseFloat(gf.extra['comboy']);
	}
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
	var acc = accuracy; // because its a getter with divisions and shi
	accBar.percent = Math.max(acc * 100, 0);
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

	scoreTxt.text = FlxStringUtil.formatMoney(songScore, false);
	missesTxt.text = FlxStringUtil.formatMoney(misses, false);
	if (acc < 0)
		accuracyTxt.text = '?';
	else {
		var result = '' + Math.floor(acc * 100);
		if (acc < 1)
			result += '.*' + (Math.floor(acc * 1000) % 10) + '' + (Math.floor(acc * 10000) % 10) + '*';
		result += '%';
		accuracyTxt.applyMarkup(result, [bruhhhFormat]);
	}

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
			if (dad.iconColor != null)
				testBar.leftBar.color = dad.iconColor;
			if (boyfriend.iconColor != null)
				testBar.rightBar.color = boyfriend.iconColor;
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
	aberration.r = getRGBArray(r);
	aberration.g = getRGBArray(g);
	aberration.b = getRGBArray(b);
	return aberration;
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
	if (e.note.isSustainNote || !(e.showRating || (e.showRating == null && e.player)))
		return;
	comboGroup.forEachAlive((a) -> {
		a.kill();
	});
}

function onPostNoteHit(e) {
	if (e.note.isSustainNote || !(e.showRating || (e.showRating == null && e.player)))
		return;
		// i dont even care anymore man
	if (!forceComboXmlPos && gf != null) {
		comboGroup.setPosition(gf.x + gf.globalOffset.x + (gf.width * 0.5) + gf.extra['combox'], gf.y + 420 + gf.extra['comboy']);
	}
	else
		comboGroup.setPosition(comboDefaultPos.x, comboDefaultPos.y);

	final bembers = [];
	comboGroup.forEachAlive((i) -> {
		bembers.push(i);
	});
	// bring rating to front since its the last one to spawn
	bembers.insert(0, bembers.pop());
	var newX = 0;
	for (x => i in bembers) {
		i.setPosition(comboGroup.x + newX, comboGroup.y - (i.height * 0.5));
		newX += i.width + 5;
		if (x == 0)
			newX += 25;
	}
	for (i in bembers) {
		i.x -= newX * 0.5;
	}
}

var stupidIndex = -1;

function onRatingsShown(e) {
	final sprite = e.ratingSprite ?? e.numberSprite ?? e.comboSprite;
	e.position.set(comboGroup.x, comboGroup.y);
	e.ratingPrefix = 'game/score/mnh/';
	e.acceleration = 200;
	e.velocity.y = FlxG.random.int(20, 60);
	sprite.angularVelocity = FlxG.random.int(-5, 5);
	sprite.angle = 0;
	if (e.ratingSprite != null) {
		e.velocity.x = FlxG.random.int(-3, 3) * -1;
		stupidIndex = -1;
	}
	if (e.numberSprite == null)
		return;
	e.velocity.x = FlxG.random.int(-3, 7) * -1;
	e.startDelay += FlxG.random.float(-0.4, 0.1);
	final log = Math.floor(Math.log(combo) / Math.log(10));
	stupidIndex += 1;
	if (combo >= Math.pow(10, 2))
		return;
	if ((2 - stupidIndex) > 1)
		e.cancel();
}

function onPostRatingsShown(e) {
	final sprite = e.ratingSprite ?? e.numberSprite ?? e.comboSprite;
	final ox = sprite.scale.x;
	final oy = sprite.scale.y;
	sprite.scale.set(ox * 1.1, oy * 1.1);
	new FlxTimer().start(frame_length, (_) -> {
		sprite.scale.set(ox, oy);
	});
}

var frame_length:Float = 2 / 24;
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
		prevSprite.cameras = [camHUD];
		new FlxTimer().start(frame_length, function(_) {
			prevSprite.scale.set(1, 1);
		});

		if (e.swagCounter == introLength - 2) {
			prevSprite.moves = true;
			prevSprite.velocity.x = FlxG.random.float(-200, 200);
			prevSprite.velocity.y = FlxG.random.float(90, 300);
			prevSprite.acceleration.y = -900;
			prevSprite.angularVelocity = FlxG.random.float(-1, 1) * ((e.swagCounter == introLength - 2) ? 60 : 20);
			var prevSprite = prevSprite; // Kill HScript
			new FlxTimer().start(3, function(_) {
				FlxTween.tween(prevSprite, {alpha: 0}, 0.3, {
					onComplete: (_) -> {
						new FlxTimer().start(1, function(_) {
							prevSprite.kill();
							remove(prevSprite, true);
							prevSprite.destroy();
						});
					}
				});
			});
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
