import funkin.backend.scripting.events.CancellableEvent;
import funkin.backend.scripting.EventManager;

var noteColors = [
	[0xC24B99, -1, 0x3C1F56],
	[0x00FFFF, -1, 0x1542B7],
	[0x12FA05, -1, 0x0A4447],
	[0xF9393F, -1, 0x651038]
];

var shaderMap:Map<Int, CustomShader> = [];

function new() {
	FlxG.camera.bgColor = 0;
}

function postCreate() {
	minDigitDisplay = 0;
	if (noteAngleFix) {
		strumLines.forEach((s) -> {
			s.onNoteUpdate.add(onNoteUpdate);
		});
	}

	if (!mobile && FlxG.save.data.middleScroll) {
		var angles = [90, 0, 180, -90];
		strumLines.forEach((s) -> {
			var gw = getGroupWidth(s);
			var gh = getGroupHeight(s);

			s.forEach((n) -> {
				n.setPosition(Note.swagWidth * n.ID * s.strumScale, 0);
				n.x -= gw * 0.5;
				n.y -= gh * 0.5;
				n.x += camHUD.width * 0.5;
				n.y += camHUD.height * 0.44;
				n.alpha *= s.cpu ? 0.3 : 1;
				n.noteAngle = angles[n.ID % angles.length];

				for (o in s.notes.members) {
					o.alpha = n.alpha;
				}
			});
		});
	}
}

function onNoteCreation(e) {
	// it fucikng sucks but i gotta
	e.note.shader = strumLines.members[e.strumLineID].members[e.strumID].extra.get('shader');
}

function onPostNoteCreation(e) {
	e.note.alpha = 1;
	if (noteAngleFix) {
		e.note.forceIsOnScreen = true;
		e.note.strumRelativePos = false;
	}
	e.note.useAntialiasingFix = true;
}

function onStrumCreation(e) {
	var stru = e.strum;
	var bleh = shade(getColors(e.strumID), e.strumID % noteColors.length);
	stru.extra.set('shader', bleh);
	stru.animation.callback = function(a, b, c) {
		if (a != 'confirm') {
			stru.shader = (a == 'static') ? null : stru.extra.get('shader');
		}
	}
	if (e.__doAnimation) {
		e.__doAnimation = false;
		stru.colorTransform.alphaOffset = -255;
		final diff = (4 / (strumLines.members[e.player].data?.keyCount ?? 4));
		FlxTween.tween(stru.colorTransform, {alphaOffset: 0}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * e.strumID * diff)});
	}
}

function onPostStrumCreation(e) {
	if (!FlxG.save.data.holdCovers)
		return;

	var lane = strumLines.members[e.player];
	if (lane.extra.get('holdCovers') == null) {
		lane.extra.set('holdCovers', []);
	}

	var stru = e.strum;
	var bleh = stru.extra.get('shader');

	stru.extra.set('cover', new FunkinSprite());
	var cover = stru.extra.get('cover');
	cover.shader = bleh;
	var holdEvent = new CancellableEvent();
	holdEvent.data = {
		cover: cover,
		sprite: 'game/holds/default',
		strumID: e.strumID, // ??? do i need this
		strumLine: lane,
		x: -12,
		y: 50,
		scale: 1
	}
	scripts.event('onHoldCoverCreation', holdEvent);
	if (!holdEvent.cancelled) {
		cover.antialiasing = true;

		var offX = holdEvent.data.x * -1;
		var offY = holdEvent.data.y * -1;

		cover.loadSprite(Paths.image(holdEvent.data.sprite));
		cover.addAnim('idle', 'start', 24, false, null, null, offX, offY);
		cover.addAnim('idle-loop', 'cover', 24, true, null, null, offX, offY);
		cover.addAnim('end', 'end', 24, false, null, null, offX, offY);
	}
	var sca = lane.strumScale * holdEvent.data.scale;
	cover.scale.set(sca, sca);
	cover.updateHitbox();
	// do the thingy that makes it not lag
	cover.drawComplex(stru.camera);
	cover.health = 0;
	scripts.event('onPostHoldCoverCreation', holdEvent);

	// using this as the "playing end anim" variable
	cover.skipNegativeBeats = false;
	cover.playAnim('idle');
	cover.health = -100;
	cover.extra.set('strum', stru);
	cover.visible = false;

	cover.onDraw = (c) -> {
		/*var oldDefaultCameras = FlxCamera._defaultCameras;
			if (stru.lastDrawCameras != null)
				FlxCamera._defaultCameras = stru.lastDrawCameras.copy(); */
		cover.cameras = stru.lastDrawCameras; // stru.cameras;
		if (!(stru.visible && (c.health > 0 || (!stru.cpu && c.skipNegativeBeats && !c.isAnimAtEnd()))))
			return;
		c.draw();
		// FlxCamera._defaultCameras = oldDefaultCameras;
	}

	lane.extra.get('holdCovers').push(cover);
	cover.ID = e.strum.strumLine.ID;
	insert(members.indexOf(strumLines) + 1, cover);

	// stru.extraCopyFields.push('alpha');
}

// fix the stupid noteAngle bug
var noteAngleFix = true;

function onNoteUpdate(e) {
	if (e.__reposNote) {
		if (!e.note.exists)
			return;

		e.strum.updateNotePosition(e.note);
		updateNotePos(e.note, e.strum);
	}
	e.cancelPositionUpdate();
}

final PIX180:Float = 565.4866776461628; // 180 * Math.PI
final N_WIDTHDIV2:Float = Note.swagWidth / 2;
final _noteOffset = FlxPoint.get(0, 0);
final TO_RAD:Float = 0.017453292519943295; // Math.PI / 180;
final helperOffset = 90;

function updateNotePos(daNote, strum) {
	var shouldX = strum.updateNotesPosX && daNote.updateNotesPosX;
	var shouldY = strum.updateNotesPosY && daNote.updateNotesPosY;

	if (shouldX || shouldY) {
		final distance = (Conductor.songPosition - daNote.strumTime) * (-0.45 * strum.getScrollSpeed(daNote));
		final angleX = Math.cos((daNote.__noteAngle + helperOffset) * TO_RAD);
		final angleY = Math.sin((daNote.__noteAngle + helperOffset) * TO_RAD);
		_noteOffset.set(angleX * distance, angleY * distance);
		_noteOffset.x += -daNote.origin.x + daNote.offset.x;
		_noteOffset.y += -daNote.origin.y + daNote.offset.y;
		if (daNote.isSustainNote) {
			final m = (daNote.height * 0.5);
			_noteOffset.x += angleX * m;
			_noteOffset.y += angleY * m;
		}
		_noteOffset.x += strum.x + (strum.width * 0.5);
		_noteOffset.y += strum.y + (strum.height * 0.5);
		if (shouldX)
			daNote.x = _noteOffset.x;
		if (shouldY)
			daNote.y = _noteOffset.y;
	}
}

function update(elapsed) {
	// player.members[3].angle += elapsed * 180;
	// THIS IS A NIGHTMARE

	/*if (FlxG.keys.pressed.Z)
			scrollSpeed -= elapsed * 2;
		if (FlxG.keys.pressed.X)
			scrollSpeed += elapsed * 2; */

	for (lane in strumLines.members) {
		/*for (i in lane.members) {
			i.angle += elapsed * 60;
		}*/
		if (FlxG.save.data.holdCovers) {
			for (cover in lane.extra.get('holdCovers')) {
				cover.health -= FlxG.elapsed;
				if (cover.health <= 0 && !cover.skipNegativeBeats) {
					cover.skipNegativeBeats = true;
					cover.playAnim('end', true);
				}
				var stru = cover.extra.get('strum');
				cover.setPosition(stru.x, stru.y);
				cover.x = stru.x + (stru.width - cover.width) * 0.5;
				cover.y = stru.y + (stru.height - cover.height) * 0.5;

				if (stru.extra.get('curNote') != null) {
					cover.angle = (stru.getNotesAngle(stru.extra.get('curNote'))) * (downscroll ? -1 : 1);
					if (cover.getAnimName() == 'end')
						cover.angle = 0;
				}
			}
		}
	}
}

function newRGBShader(colArray) {
	var r = colArray[0];
	var g = colArray[1];
	var b = colArray[2];
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

function getColors(id) {
	if (noteColors[id % noteColors.length] != null)
		return noteColors[id % noteColors.length];
	return [0xff0000, 0x00ff00, 0x0000ff];
}

function shade(colors:Array<Int>, ?colorID:Int = -1) {
	if (!shaderMap.exists(colorID)) {
		var shad = newRGBShader(colors);
		shaderMap.set(colorID, shad);
	}
	return shaderMap.get(colorID);
}

function onPlayerHit(e) {
	if (FlxG.save.data.cbreak) {
		if (['bad', 'shit'].indexOf(e.rating) != -1) {
			combo = -1;
		}
	}

	if (FlxG.save.data.susLink) {
		if (!e.cancelled && e.note != null) {
			if (e.note.extra.get('__missedSustain') == true) {
				e.cancel();
				e.note.wasGoodHit = false;
				e.autoHitLastSustain = false;
				e.cancelVocalsUnmute();
			}
		}
	}

	if (FlxG.save.data.pbot && !e.note.avoid) {
		if (e.note.isSustainNote) {
			songScore += (e.score = Std.int(250 * (e.note.sustainLength * 0.001)));
		} else
			pbotScore(e);
	}
}

function onPlayerMiss(e) {
	if (FlxG.save.data.pbot) {
		if (e.note != null)
			e.score = -100;
	}
	if (FlxG.save.data.susLink) {
		if (!e.cancelled && e.note != null) {
			if (e.note.extra.get('__missedSustain') == true) { // == true cus its null by default
				// trace('a!');
				e.cancel();
				if (e.deleteNote && e.note != null && e.note.strumLine != null)
					e.note.strumLine.deleteNote(e.note);
				return;
			}
			// trace('KILL.');
			if (!e.note.avoid) { // avoid having effect on notes youre supposed to miss
				var not = e.note;

				// the first sustain hold is missed Before the parent note, do hacky fix
				if (e.note.isSustainNote && (!e.note.prevNote?.isSustainNote ?? false)) {
					// trace('note ' + e.note.strumTime + ' (' + e.note.strumID + ', ' + e.note.animation.name + ') has head before it..');
					// trace('yes im talking about note ' + e.note.prevNote.strumTime + ' (' + e.note.prevNote.strumID + ', ' + e.note.prevNote.animation.name + ')');
					ghostNote(e.note.prevNote);
				}

				if (!e.note.isSustainNote && (e.note.nextNote?.isSustainNote ?? false)) {
					ghostNote(e.note);
					not = e.note.nextNote;
				}
				while (not != null) {
					// trace('looping..' + not + ' (' + not.animation.name + ')');
					ghostNote(not);
					not.alpha *= 0.5;
					not = not.nextSustain;
				}
			}
		}
	}
}

function ghostNote(n) {
	n.avoid = true;
	n.earlyPressWindow = n.latePressWindow = -1000;
	n.extra.set('__missedSustain', true);
}

function onNoteHit(e) {
	e.note.__strum.shader = e.note.shader;
	if (e.showSplash) {
		e.showSplash = false;
		var grp = splashHandler.getSplashGroup(e.note.splash);
		splashHandler.showSplash(e.note.splash, e.note.__strum);
		grp.__splash.shader = grp.__splash.strum.shader;
	}
	if (!e.cancelled) {
		if (!FlxG.save.data.holdCovers)
			return;
		if (e.note.isSustainNote) {
			var par = findParentNote(e.note);
			var tail = findTailNote(e.note);

			var strumTime = par.strumTime;
			var length = tail.strumTime - strumTime + (e.player ? 0 : Conductor.stepCrochet);
			var strum = e.note.__strum;
			if (strum != null) {
				var res = (strumTime + length - Conductor.songPosition);
				if ((tail.strumTime - par.strumTime) < (((60 / Conductor.bpmChangeMap[0].bpm) * 1000 / 4)) * 0.75)
					return;
				if (strum.extra.get('cover').health <= 0) {
					strum.extra.get('cover').playAnim('idle', true);
					strum.extra.get('cover').skipNegativeBeats = false;
					strum.extra.get('cover').health = res * 0.001;
					strum.extra.get('cover').visible = true;
					strum.extra.get('cover').shader = e.note.shader;
				}
				strum.extra.set('curNote', e.note);
			}
		}
	}
}

function onInputUpdate(e) {
	if (!FlxG.save.data.holdCovers)
		return;
	if (e.justReleased.indexOf(true) == -1)
		return;
	for (i => v in e.justReleased) {
		var holdCovers = e.strumLine.extra.get('holdCovers');
		if (v && holdCovers[i].health > 0) {
			holdCovers[i].health = 0;
			holdCovers[i].visible = false;
		}
	}
}

function onPostNoteHit(e) {
	if (e.player) return;

	final resetMS = 150;
	e.data.strumGlowCancelled = e.strumGlowCancelled;
	if (!e.strumGlowCancelled) {
		if (e.note.nextNote == null ? true : !e.note.nextNote.isSustainNote || e.note.nextSustain == null) {
			e.note.__strum.lastHit = (e.note.strumTime - (Conductor.crochet / 2)) + resetMS;
		} else {
			e.note.__strum.lastHit = inst.length;
		}
	}
}

function pbotScore(e) {
	var diff = Conductor.songPosition - e.note.strumTime;
	var absTiming:Float = Math.abs(diff);

	// not gonna bother rewriting the pbot1 score system from scratch

	/**
	 * The maximum score a note can receive.
	 */
	var PBOT1_MAX_SCORE:Int = 500;

	/**
	 * The offset of the sigmoid curve for the scoring function.
	 */
	var PBOT1_SCORING_OFFSET:Float = 54.99;

	/**
	 * The slope of the sigmoid curve for the scoring function.
	 */
	var PBOT1_SCORING_SLOPE:Float = 0.080;

	/**
	 * The minimum score a note can receive while still being considered a hit.
	 */
	var PBOT1_MIN_SCORE:Float = 9.0;

	var factor:Float = 1.0 - (1.0 / (1.0 + Math.exp(-PBOT1_SCORING_SLOPE * (absTiming - PBOT1_SCORING_OFFSET))));

	var score:Int = Std.int(PBOT1_MAX_SCORE * factor + PBOT1_MIN_SCORE);
	score = Std.int(FlxMath.bound(score, 0, PBOT1_MAX_SCORE));

	return e.score = score;
}