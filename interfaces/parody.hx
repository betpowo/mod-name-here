var scoreTxt, missesTxt, accuracyTxt, rankTxt:FunkinText;
var oldStageQuality = FlxG.game.stage.quality;
var daPixelZoom = 4;

function create() {
	PauseSubState.script = 'data/states/pause/parody';
	for (i => j in [
		[0xff00ff, 0xff7fff],
		[0x0000ff, 0x7f7fff],
		[0xffff00, 0xffff7f],
		[0xff0000, 0xff7f7f]
	]) {
		noteColors[i][0] = j[0];
		noteColors[i][2] = j[1];
	}
	currentUI = 'parody';
}

function onNoteCreation(e) {
	e.cancel();

	var note = e.note;
	var lane = e.note.strumLine;
	var off = e.strumID * 7;
	note.loadGraphic(Paths.image('ui/parody/arrowSheet'), true, 40, 40);

	if (!note.isSustainNote) {
		note.animation.add('scroll', [off + 1], 10, true);
	} else {
		note.animation.add('hold', [28]);
		note.animation.add('holdend', [29]);
	}
	note.scale.set(daPixelZoom * lane.strumScale, daPixelZoom * lane.strumScale);
	note.updateHitbox();
}

function onStrumCreation(e) {
	e.cancel();

	var note = e.strum;
	var lane = strumLines.members[e.player];
	var off = e.strumID * 7;

	note.loadGraphic(Paths.image('ui/parody/arrowSheet'), true, 40, 40);
	note.animation.add('static', [off + 0], 10, true);
	note.animation.add('pressed', [off + 4, off + 5, off + 6], 10, true);
	note.animation.add('confirm', [off + 2, off + 3], 10, false);

	note.scale.set(daPixelZoom * lane.strumScale, daPixelZoom * lane.strumScale);
	note.updateHitbox();

	if (!mobile) {
		note.x += (Note.swagWidth - (note.frameWidth * note.scale.x)) / 2;
		note.y -= 4 * daPixelZoom * lane.strumScale;
	}

	/*note.x += FlxMath.fastCos(e.strumID * 180) * 10;
		note.y += FlxMath.fastSin(e.strumID * 70) * 10; */
}

var prevSprite:FlxSprite = null;

function onCountdown(e) {
	e.antialiasing = false;
	if (e.soundPath != null)
		e.soundPath = 'parody/' + e.soundPath;

	if (e.spritePath != null) {
		e.spritePath = StringTools.replace(e.spritePath, 'game', 'ui/parody');
	}

	if (prevSprite != null && e.swagCounter < introLength - 1) {
		prevSprite.kill();
	}
}

function onPostCountdown(e) {
	if (e.spriteTween != null)
		e.spriteTween.cancel();

	if (e.sprite != null) {
		prevSprite = e.sprite;
		prevSprite.zoomFactor = 0;
		prevSprite.scale.set(FlxG.random.float(7, 14), FlxG.random.float(7, 14));
	}
	if (e.swagCounter == introLength - 1) {
		FlxTween.tween(prevSprite.scale, {x: 0, y: 0}, 2, {
			onComplete: (_) -> {
				remove(prevSprite);
				prevSprite.destroy();
			}
		});
	}
}

function beatHit(b) {
	camZoomingStrength = 0;
	for (i in iconArray) {
		i.angle = FlxG.random.float(-1, 1) * 4;
	}
}

function postUpdate(elapsed) {
	var xx = FlxG.width - 700;
	var yy = FlxG.height - 95;
	iconP2.setPosition(xx, yy - iconP2.height * 0.5);
	iconP1.setPosition(xx + 500, yy - iconP1.height * 0.5);

	var shak = 3;
	for (i in iconArray) {
		if (i.curAnimState == 1 || i.curAnimState == 'losing') {
			i.x += FlxG.random.float(-1, 1) * shak;
			i.y += FlxG.random.float(-1, 1) * shak;
			var sin = Math.sin(curBeatFloat * Math.PI);
			i.angle = (sin * sin) * FlxMath.signOf(sin) * 7;
			i.y += Math.abs(sin) * -14;
			i.x -= Math.cos(curBeatFloat * Math.PI) * 7;
		}
	}

	meter.setPosition(meterBG.getMidpoint().x - (meter.width * 0.5), FlxG.height - meter.height * 0.5);
	meter.angle = FlxMath.remapToRange(healthBar.percent, 0, 100, 75, -75);
	if (downscroll) {
		meter.angle *= -1;
	}
}

function destroy() {
	// resets the stage quality
	FlxG.game.stage.quality = oldStageQuality;
	FlxG.enableAntialiasing = true;
}

function postCreate() {
	FlxG.game.stage.quality = 2;
	FlxG.enableAntialiasing = false;

	var game = PlayState.instance;

	for (i in [game.scoreTxt, game.missesTxt, game.accuracyTxt]) {
		i.visible = i.exists = i.alive = i.active = false;
	}

	// kill
	var xx = -10;
	var yy = FlxG.height - 260;
	var hh = 55;

	scoreTxt = new FunkinText(xx, yy, -1, "---", 16);
	missesTxt = new FunkinText(xx, yy + hh, -1, "---", 16);
	accuracyTxt = new FunkinText(xx, yy + (hh * 2), -1, "---", 16);
	rankTxt = new FunkinText(xx, yy + (hh * 3), -1, "---", 16);
	rankTxt.addFormat(accFormat);

	for (i in [scoreTxt, missesTxt, accuracyTxt, rankTxt]) {
		insert(members.indexOf(game.accuracyTxt), i);
		i.camera = camHUD;

		i.font = Paths.font('comic.ttf');
		i.size = 40;
		i.borderSize = 0.5;
		i.fieldWidth = FlxG.width;
	}

	healthBarBG.visible = healthBar.visible = false;

	meter = new FunkinSprite().loadGraphic(Paths.image('ui/parody/meter'));
	insert(0, meter);
	meter.scale.set(2, 2);
	meter.updateHitbox();

	meterBG = new FunkinSprite().loadGraphic(Paths.image('ui/parody/meterBG'));
	insert(0, meterBG);
	meterBG.scale.set(2, 2);
	meterBG.updateHitbox();
	meterBG.setPosition(FlxG.width - 525, FlxG.height - meterBG.height);
	meterBG.camera = meter.camera = camHUD;

	if (FlxG.save.data.compact) {
		for (i in [missesTxt, accuracyTxt, rankTxt]) {
			i.visible = i.exists = i.alive = i.active = false;
		}
		scoreTxt.y += hh * 3;
	}

	doIconBop = false;

	TEXT_GAME_SCORE = TranslationUtil.getRaw("mnh.ui.parody.score");
	TEXT_GAME_MISSES = TranslationUtil.getRaw("mnh.ui.parody.misses");
	TEXT_GAME_COMBOBREAKS = TranslationUtil.getRaw("mnh.ui.parody.comboBreaks");
	TEXT_GAME_ACCURACY = TranslationUtil.getRaw("mnh.ui.parody.accuracy");
	TEXT_GAME_RANK = TranslationUtil.getRaw("mnh.ui.parody.rank");

	updateRatingStuff = function() {
		scoreTxt.text = TEXT_GAME_SCORE.format([songScore]);
		missesTxt.text = (comboBreaks ? TEXT_GAME_COMBOBREAKS : TEXT_GAME_MISSES).format([misses]);
		accuracyTxt.text = TEXT_GAME_ACCURACY.format([(accuracy < 0 ? '???' : CoolUtil.quantize(accuracy * 100, 100))]);
		rankTxt.text = 'i am here to fix the bug where '; // going from perfect (gold) to perfect (pink) wouldnt change the color because the text data was the same
		rankTxt.text = TEXT_GAME_RANK.format([curRating.rating]);
		for (i => frmtRange in rankTxt._formatRanges)
			if (frmtRange.format == accFormat) {
				rankTxt._formatRanges[i].range.start = rankTxt.text.length - curRating.rating.length;
				rankTxt._formatRanges[i].range.end = rankTxt.text.length;
				break;
			}
		accFormat.format.color = curRating.color;
	}
}

function draw(e) {
	meterBG.flipY = downscroll;
}

function onChangeCharacter(e) {
	if (!e.event.params[3])
		return;

	if (e.memberIndex == 0) {
		if (e.strumIndex >= 2)
			return;
		final opp = (e.strumIndex == 0);
		final opp = (e.strumIndex == 0);
		var icon = opp ? iconP2 : iconP1;
		icon.setIcon(e?.character?.getIcon() ?? 'face');

		// since health bar is invisible we dont need to do the things with it
		// :3
	}
}

function onLyricSetup(e) {
	e.text.font = Paths.font('comic.ttf');
	e.text.updateHitbox();
	e.text.screenCenter();
	e.text.y = FlxG.height - 150 - e.text.height;
}

function onNoteHit(e) {
	if (e.note.isSustainNote || !(e.showRating || (e.showRating == null && e.player)))
		return;
	comboGroup.forEachAlive((a) -> {
		a.kill();
	});
}

final sharedJPEGShader = new CustomShader('jpeg');

function onRatingsShown(e) {
	e.acceleration = 0;
	e.velocity.set(0, 160);
	e.playTween = false;
}

function onPostRatingsShown(e) {
	final sprite = e.ratingSprite ?? e.numberSprite ?? e.comboSprite;
	sprite.shader = sharedJPEGShader;
}
