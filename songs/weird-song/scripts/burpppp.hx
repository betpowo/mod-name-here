playCutscenes = true;
var ogMeta = Reflect.copy(PlayState.SONG.meta);

PlayState.SONG.meta.displayName = '...';
PlayState.SONG.meta.color = 0xff000000;
function onSongStart() {
	PlayState.SONG.meta = ogMeta;
}

// so reflect.copy works even after censor
function destroy() {
	onSongStart();
}

var floorLevel = 888;

// cannot use screenCenter, as resolution is bigger than 1280x720
var fuckAssCutscene = new FunkinSprite((FlxG.width - 1280) / 2, (FlxG.height - 720) / 2, Paths.image('stages/inside/weirdCutscene'));
var fuckAssCam = new FlxCamera();

function postCreate() {
	forceComboXmlPos = true;
	add(fuckAssCutscene);
	fuckAssCutscene.zoomFactor = 0;
	fuckAssCutscene.scrollFactor.set();
	fuckAssCutscene.antialiasing = true;

	FlxG.cameras.add(fuckAssCam, false);
	fuckAssCutscene.cameras = [fuckAssCam];
	fuckAssCam.bgColor = 0xff000000;

	fuckAssCutscene.visible = false;
}

function startTheThingy() {
	fuckAssCutscene.visible = true;
	fuckAssCutscene.playAnim('');
}

function endTheThingy() {
	FlxG.cameras.remove(fuckAssCam, true);
	fuckAssCutscene.destroy();
}

function onPostNoteCreation(e) {
	if (e.note.noteType == 'Note Type 1') {
		if (e.note.strumTime >= 36000) {
			e.note.avoid = true;
		}
	} else if (e.note.noteType == 'Note Type 2') {
		e.note.visible = false;
		e.note.latePressWindow = e.note.earlyPressWindow = -2;
		e.note.avoid = e.note.isSustainNote;
	}
}

function onNoteHit(e) {
	if (e.note.noteType == 'Note Type 1') {
		e.preventAnim();

		if (!FlxG.save.data.holdCovers)
			return;

		if (!e.note.isSustainNote)
			e.note.strumLine.members[e.note.strumID].extra.get('cover').health = Conductor.stepCrochet * 0.008;

		if (!e.strumGlowCancelled) {
			e.strumGlowCancelled = true;
			e.note.__strum.press(e.note.strumTime);
		}
	} else if (e.note.noteType == 'Note Type 2') {
		e.preventAnim();

		if (!e.note.isSustainNote) {
			e.note.strumLine.members[e.note.strumID].playAnim('pressed', true);
		}

		var length = FlxG.random.float(0.15, 0.25);
		if (e.note.isSustainNote || (e?.note?.nextNote?.isSustainNote ?? false)) {
			var par = findParentNote(e.note);
			var tail = findTailNote(e.note);
			var strumTime = par.strumTime;
			length = (tail.strumTime - strumTime) * 0.001;
		}

		e.note.strumLine.members[e.note.strumID].extra.set('pressTimer', length);

		e.cancelStrumGlow();
		if (FlxG.save.data.holdCovers) {
			e.note.strumLine.members[e.note.strumID].extra.get('cover').health = 0;
			e.note.strumLine.members[e.note.strumID].extra.get('cover').visible = false;
		}
	}
}

function onPlayerMiss(e) {
	if (e.noteType == 'Note Type 2') {
		e.cancelMissSound();
		e.cancelResetCombo();
		e.cancelStunned();
		e.cancelAnim();
		e.cancelVocalsMute();
		e.healthGain = 0;
		e.gfSad = false;
		e.accuracy = null;
		e.score = 0;
		e.misses = 0;
		e.cancel();
		e.deleteNote = true;
	}
}

var AAAGHHHHH = [];

function postUpdate(elapsed) {
	if (curBeat >= 314) {
		comboGroup.forEach((s) -> {
			FlxTween.globalManager.forEachTweensOf(s, ['alpha'], (t) -> {
				if (AAAGHHHHH.indexOf(t) == -1) {
					t.startDelay += Conductor.crochet * 0.0015;
					AAAGHHHHH.push(t);
				}
			});
			if ((s.y + s.height) > floorLevel) {
				s.y = floorLevel - s.height;
				s.y -= 2;
				s.velocity.y *= -0.4;
				s.angularVelocity *= -1;
			}
		});
	}

	for (i in strumLines.members) {
		for (s in i.members) {
			if (s.extra.get('pressTimer') > 0) {
				s.extra.set('pressTimer', s.extra.get('pressTimer') - elapsed);
			} else if (s.extra.get('pressTimer') != -1) {
				s.playAnim('static', true);
				s.extra.set('pressTimer', -1);
			}
		}
	}
}

function onPostStrumCreation(e) {
	e.strum.extra.set('pressTimer', -1);
}

// DIE DIE DIE FUCK YOU FUCK YOU FUJKJ
function onPostInputUpdate() {
	for (i in strumLines.members) {
		for (c in i.characters) {
			if (c != null && c.lastAnimContext == null)
				c.__lockAnimThisFrame = false;
		}
	}
}

function onCountdown(e) {
	e.soundPath = e.spritePath = null;
}
