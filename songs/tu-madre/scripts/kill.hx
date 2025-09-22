import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import openfl.display.BlendMode;

var outline = null;
var fucksEnabled = false;
var fucks = 0;
var shakeVal = 0;
var crap = new FlxSpriteGroup();

function postCreate() {
	if (Options.gameplayShaders) {
		outline = new CustomShader('outline');
	}
	abg = new FlxBackdrop();
	abg.loadGraphic(Paths.image('editors/bgs/charter'));
	abg.antialiasing = true;
	abg.velocity.set(255, 255);
	abg.blend = BlendMode.ADD;
	abg.alpha = 1;
	abg.scrollFactor.set(0, 0);

	shit = new FlxBackdrop(FlxGridOverlay.createGrid(1, 1, 2, 2, true, 0xddffffff, 0xffffffff));
	shit.scale.set(60, 60);
	shit.updateHitbox();
	shit.screenCenter();
	shit.scrollFactor.set(0.4, 0.4);
	shit.velocity.y = 69;
	shit.blend = BlendMode.MULTIPLY;
	insert(members.indexOf(gf), shit);
	insert(members.indexOf(shit) + 1, abg);
	shit.visible = abg.visible = false;

	shit.color = 0xff0000;

	outline.borderSize = 0;
	outline.borderColor = [1, 1, 1];
	if (outline != null)
		camHUD.addShader(outline);

	insert(members.indexOf(dad), crap);

	grad = new FunkinSprite().loadGraphic(Paths.image('cheap_gradient'));
	grad.antialiasing = true;
	grad.setGraphicSize(camGame.width * 1.1, camGame.height * 1.1);
	grad.updateHitbox();
	grad.screenCenter(0x01);
	grad.scrollFactor.set();
	grad.zoomFactor = 0;
	grad.forceIsOnScreen = true;
	grad.blend = BlendMode.SUBTRACT;
	grad.color = 0x717171;
	grad.visible = false;
	grad.onDraw = (s) -> {
		s.flipY = camHUD.downscroll;
		s.draw();
	}
	insert(members.indexOf(dad), grad);

	dump = new FlxSprite(-200, 200); // flash will copy the blend mode of the object in fornt for some reason
	dump.scrollFactor.set(0, 0);
	dump.screenCenter();
	dump.alpha = 0.001;
	add(dump);

	// playCutscenes = true;

	if (playCutscenes)
		dad.scripts.call('initLaser');
}

var dump = 0xff9999;

function postUpdate(elapsed) {
	dump = FlxColor.fromHSB((Math.max(0, curBeatFloat)) * 90, 0.12, 1);

	if (outline != null) {
		outline.borderColor[0] = ((dump >> 16) & 0xff) / 255;
		outline.borderColor[1] = ((dump >> 8) & 0xff) / 255;
		outline.borderColor[2] = ((dump >> 0) & 0xff) / 255;
	}

	shit.health = lerp(shit.health, 0.3, elapsed * 5);
	shit.color = FlxColor.fromHSB(fucks == 1 ? (curBeat * 6) : (Math.max(0, curBeatFloat)) * 90, 0.9, shit.health);

	if (fucksEnabled) {
		shakeVal = lerp(shakeVal, 0, elapsed * 4);
		camGame.x = FlxG.random.float(-1, 1) * shakeVal;
		camGame.y = FlxG.random.float(-1, 1) * shakeVal;

		camGame.angle = Math.cos(curBeatFloat * Math.PI) * 0.5;
	} else {
		camGame.setPosition(0, 0);
		camGame.angle = 0;
	}

	var r = getRotate(600, (curBeatFloat * 18) % 360);
	abg.velocity.set(r.x, r.y);
}

function toggleCam() {
	camGame.visible = !camGame.visible;
}

function beatHit(b) {
	shit.health = 1;
	if (fucksEnabled) {
		shakeVal += 2 * fucks;
	}
}

function fuck() {
	fucksEnabled = !fucksEnabled;
	if (fucksEnabled) {
		fucks += 1;
	}

	shit.visible = abg.visible = fucksEnabled;
	if (fucks < 2)
		abg.visible = false;
	grad.visible = abg.visible;
	if (outline != null) {
		FlxTween.num(outline.borderSize, fucksEnabled ? 5 : 0, Conductor.crochet / 1000, {ease: FlxEase.sineOut}, (num) -> {
			outline.borderSize = num;
		});
	}

	for (i in strumLines.members) {
		for (c in i.characters) {
			if (fucksEnabled) {
				c.colorTransform.color = c.iconColor ?? 0x717171;
				c.colorTransform.redMultiplier = c.colorTransform.greenMultiplier = c.colorTransform.blueMultiplier = 0.8;
			} else {
				c.setColorTransform();
			}
		}
	}
}

function getRotate(len:Float, deg:Float) {
	var rad:Float = deg * (Math.PI / 180);
	var __x:Float = len * FlxMath.fastCos(rad);
	var __y:Float = len * FlxMath.fastSin(rad);
	return FlxPoint.get(__x, __y);
}

function onNoteHit(e) {
	if (fucks >= 2) {
		for (i in e.characters) {
			if (!fucksEnabled) {
				i.setColorTransform();
				continue;
			}

			var res = (e.note.shader.r[2] * 255) + ((e.note.shader.r[1] * 255) << 8) + ((e.note.shader.r[0] * 255) << 16);
			i.colorTransform.color = res;
			i.colorTransform.redMultiplier = i.colorTransform.greenMultiplier = i.colorTransform.blueMultiplier = 0.7;
		}
		shakeVal += 0.3;
		if (!e.note.isSustainNote) {
			var no = crap.recycle() ?? new FlxSprite();
			no.frames = Paths.getFrames('game/notes/minimal');
			no.animation.addByPrefix('idle', 'green0', 24, true);
			no.animation.play('idle', true);
			no.scale.x = no.scale.y = FlxG.random.float(0.4, 0.7);
			no.updateHitbox();
			no.angle = FlxG.random.float(-1, 1) * 360;
			var res = (e.note.shader.r[2] * 255) + ((e.note.shader.r[1] * 255) << 8) + ((e.note.shader.r[0] * 255) << 16);
			no.colorTransform.color = res;
			no.antialiasing = true;

			var r = getRotate(FlxG.random.float(400, 1200), FlxG.random.float(0, 360));
			no.velocity.set(r.x * -0.8, r.y * -0.8);
			no.acceleration.set(r.x * 2, r.y * 2);
			no.angularVelocity = FlxG.random.float(-1, 1) * 180;
			crap.add(no);

			var char = e.characters[0];
			var mid = char.getGraphicMidpoint();
			no.setPosition(mid.x + char.globalOffset.x, mid.y + char.globalOffset.y);
		}
	}
}
