final _type = 'Fart Note';

// backend helpers for rgb

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

function convert(col) {
	return [redf(col), greenf(col), bluef(col)];
}

// general graphics

var follower = new FunkinSprite().loadGraphic(Paths.image('game/notes/overlays/fartOverlay'));
var rgbShader:CustomShader;
var sound:FlxSound;

function create() {
	follower.scale.set(0.7, 0.7);
	follower.updateHitbox();
	follower.camera = camHUD;

	rgbShader = new CustomShader('rgbPalette');
	rgbShader.mult = 1;
	rgbShader.r = convert(0xbbaa66);
	rgbShader.g = convert(-1);
	rgbShader.b = convert(0x445555);

	sound = FlxG.sound.load(Paths.sound('fart'));
}

function onPostNoteCreation(e) {
	if (e.noteType == _type) {
		e.note.shader = null;
		e.note.shader = rgbShader;
		e.note.avoid = true;
		e.note.latePressWindow = e.note.earlyPressWindow = 0.3;
	}
}

function postCreate() {
	strumLines.forEach((s) -> {
		s.onNoteUpdate.add(onNoteUpdate);
	});
	insert(members.indexOf(strumLines) + 1, follower);
	follower.onDraw = (f) -> {
		for (j in strumLines.members) {
			j.notes.forEach(function(note) {
				if (note.noteType == _type && !note.isSustainNote) {
					doFollow(note, follower);
					follower.draw();
				}
			});
		}
	}
}

// label for note

var angles = [270, 180, 0, 90];

function doFollow(note, sprite) {
	sprite.setPosition(note.x, note.y);
	if (note.strumRelativePos && note.__strum != null) {
		sprite.x += note.__strum.x;
		sprite.y += note.__strum.y;
	}
	sprite.angle = note.angle + (angles[note.noteData] ?? 0);
	sprite.scale.set(note.strumLine.strumScale * 0.7, note.strumLine.strumScale * 0.7);
}

// general events

function onPlayerHit(e) {
	if (e.noteType == _type) {
		e.cancelAnim();
		e.healthGain = -0.03;
		e.score = -15;
		e.accuracy = 0.8;
		e.rating = 'dookie';
		e.countAsCombo = false;

		sound.play(true);
		sound.volume = 0.7;

		// zoomOffsets[0] += 0.04;
		// zoomOffsets[1] += 0.02;

		e.showSplash = false;

		fart(e);
	}
}

function onPlayerMiss(e) {
	if (e.noteType == _type) {
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
	}
}

function onNoteUpdate(e) {
	if (e.note.noteType != _type)
		return;
	var strumTime = e.note.strumTime;
	if (e.note.isSustainNote) {
		var n = e.note;
		while (n.isSustainNote) {
			n = n.prevNote;
		}
		strumTime = n.strumTime;
	}
	if (e.__reposNote) {
		e.cancelPositionUpdate();
		e.strum.updateNotePosition(e.note);
	}
	e.note.x += FlxMath.fastCos((Conductor.songPosition - strumTime) * 0.01) * 5;
	e.note.y += FlxMath.fastSin((Conductor.songPosition - strumTime) * 0.01) * 5 * e.strum.getScrollSpeed(e.note);
}

final rad:Float = 0.017453292519943295; // Math.PI / 180;
var fartClouds = [];

function fart(e) {
	if (e.note.__strum == null)
		return;

	var fartFrames = Paths.getFrames('game/notes/misc/fartEffect');

	var explosion = new FunkinSprite();
	explosion.frames = fartFrames;
	explosion.antialiasing = true;
	explosion.addAnim('boom', 'explosion', 24, false, true, null, -80, -50);
	explosion.playAnim('boom', true);
	explosion.updateHitbox();
	explosion.origin.x += 80;
	explosion.origin.y += 50;
	explosion.angle = FlxG.random.float(-180, 180);
	explosion.setPosition(explosion.width * -0.5, explosion.height * -0.5);

	explosion.x += e.note.__strum.x;
	explosion.y += e.note.__strum.y;
	explosion.cameras = e.note.__strum.lastDrawCameras;

	var lilFarts = [];
	final amount = 5;
	for (i in 0...amount) {
		var fart = new FunkinSprite();
		fart.frames = fartFrames;
		fart.antialiasing = true;
		fart.addAnim('idle', 'cloud', 24, true);
		fart.playAnim('idle', true);
		fart.updateHitbox();
		fart.cameras = explosion.cameras;
		fart.animation.update(FlxG.random.float(0, 1));

		var angle = 180 + ((i / amount) * 360) + explosion.angle;
		var distance = 250;
		var angleX = FlxMath.fastCos(angle * rad);
		var angleY = FlxMath.fastSin(angle * rad);

		fart.setPosition(e.note.__strum.x + (e.note.__strum.width * 0.5), e.note.__strum.y + e.note.__strum.height * 0.5);
		fart.x += angleX * distance;
		fart.y += angleY * distance;

		fart.x -= 170;
		fart.y -= 141;

		var randomV = FlxG.random.float(60, 200);
		fart.moves = true;
		fart.velocity.set(angleX * randomV, angleY * randomV);
		fart.acceleration.set(angleX * randomV * -1.25, angleY * randomV * -1.25);

		lilFarts.push(fart);
	}

	explosion.animation.finishCallback = (a) -> {
		explosion.kill();
		remove(explosion, true);

		for (j in lilFarts) {
			insert(members.indexOf(follower), j);
			fartClouds.push(j);

			new FlxTimer().start(7 + FlxG.random.float(-0.5, 0.5), (_) -> {
				FlxTween.tween(j, {alpha: 0}, FlxG.random.float(0.4, 0.8), {
					ease: FlxEase.circOut,
					onComplete: (__) -> {
						fartClouds.remove(j, true);
						j.kill();
						remove(j, true);
						j.destroy();
						explosion.destroy();
					}
				});
			});
		}
	};

	insert(members.indexOf(follower), explosion);
}

function postUpdate(e) {
	var d = 100 * e;
	for (f in fartClouds) {
		f.velocity.degrees += d;
		// f.acceleration.degrees -= d * 0.2;
	}
}
