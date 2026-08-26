import funkin.backend.utils.IniUtil;

final game = PlayState.instance;
var speakerText = new FunkinText();

// var skipText = new FunkinText();
var lastLetterTyped = '';
var lastChar = -1;
var curChar = 0;
var isFirstLine = true;
var cutscene = game.subState;

// trace(SOUND_SHIT['Global']);

function postResetText() {
	setupBubble(curChar);
	text._defaultFormat.leading = -13;
	text.angle = speakerText.angle = -3 * (flipX ? -1 : 1);
	text.setPosition(x + 32, y + 32);
	speakerText.setPosition(x + 7 + (flipX ? 30 : 0), y - 25);
	speakerText.alignment = flipX ? 'right' : 'left';
}

function changeChar() {
	if (cutscene.curLine == null)
		return;
	curChar = Std.int(cutscene.curLine.char);
	if (curChar >= 0)
		flipX = !game.strumLines.members[curChar].opponentSide;
	moveCam(curChar);

	if (isFirstLine) {
		isFirstLine = false;
		if (PlayState.smoothTransitionData == null)
			game.camGame.snapToTarget();
	}

	if (cutscene.curLine.changeDefAnim != null) {
		forEachChar(curChar, (c) -> {
			c.playAnim(cutscene.curLine.changeDefAnim, true, 'LOCK');
		});
	}

	/*if (lastChar != curChar && isLA) {
		FlxTween.cancelTweensOf(game.camGame.scroll);
		FlxTween.tween(game.camGame.scroll, {
			x: game.camFollow.x - (game.camGame.width / 2),
			y: game.camFollow.y - (game.camGame.height / 2)
		}, 2, {ease: FlxEase.expoOut});
	}*/
}

function popupChar(e) {
	e.cancel();
}

function forEachChar(s, f) {
	if (game.strumLines.members[s] == null)
		return;
	for (i in game.strumLines.members[s].characters) {
		if (i != null)
			f(i);
	}
}

var gm = new CustomShader('gradientMap');

function create() {
	while (cutscene.subState != null) {
		cutscene = cutscene.subState;
	}
}

function postCreate() {
	speakerText.font = Paths.font('sillyfont.ttf');
	speakerText.size = 40;
	speakerText.fieldWidth = 300;
	speakerText.borderSize = 4;
	speakerText.text = 'balls!';

	// theres skipping in pause menu
	/*skipText.font = Paths.font('sillyfont.ttf');
		skipText.size = 20;
		skipText.fieldWidth = 600;
		skipText.borderSize = 4;
		skipText.text = 'press [BACK] to skip...';
		skipText.setPosition(20, FlxG.height - skipText.height - 20);
		skipText.offset.y = -skipText.height * 2; */

	text.antialiasing = speakerText.antialiasing = /*skipText.antialiasing =*/ true;
	camera = text.camera = speakerText.camera = game.camGame;

	gm.black = [0, 0, 0, 1];
	gm.white = [1, 1, 1, 1];
	gm.mult = 1;
	shader = gm;

	game.camGame.paused = false;
	game.persistentUpdate = true;
	/*skipText.camera = FlxG.cameras.list[FlxG.cameras.list.length - 1];*/

	text.completeCallback = () -> {
		//blips.pause();
	}
}

function structureLoaded(e) {
	defPath = '';
}

var added:Bool = false;
var __cachedText = '';
//var blips = FlxG.sound.load(Paths.sound('dialogue/_'));

function update(elapsed) {
	if (!added) {
		cutscene.add(speakerText);
		// cutscene.add(skipText);

		/*FlxTween.tween(skipText, {"offset.y": 0}, 2, {
				ease: FlxEase.expoOut
			});
			FlxTween.tween(skipText, {alpha: 0}, 1, {
				ease: FlxEase.expoIn,
				startDelay: 5
		});*/

		added = true;
	}
	/*var scrX = lerp()
		game.camera.scroll.setPosition(scrX, scrY); */
	game.camGame.updateScroll();
	//text.sounds = null;

	if (__cachedText != text.text) {
		__cachedText = text.text;
		lastLetterTyped = text.text.charAt(text.text.length - 1);
		// var index = getSoundIndexOf(lastLetterTyped);

		/*if (index >= 0 && 'aehilmpstv'.split('').indexOf(lastLetterTyped.toLowerCase()) != -1) {
			blips.loadEmbedded(Paths.sound('dialogue/test/' + lastLetterTyped.toLowerCase(), null, 'wav'));
			blips.play(true);
			blips.pitch = 1 + FlxG.random.float(-0.1, 0.3);
			// blips.play(true);
			trace('DUDE', blips.time);
		}*/
	}
	// trace(blips.time);
}

function postUpdate(elapsed) {
	text.updateHitbox();
	text.origin.set(0, 0);
}

function playBubbleAnim(e) {
	changeChar();

	if (e.suffix != '-close') {
		e.suffix = '';
		e.setTextAfter = false;

		if (lastChar != curChar) {
			lastChar = curChar;
			e.suffix = ((curChar == -1) ? '-close' : '-open');
			e.setTextAfter = (curChar != -1);
		}
	}
}

var isLastLine = false;

function postPlayBubbleAnim(e) {
	if (isLastLine) {
		cutscene.remove(speakerText);
		if (cutscene.curMusic != null) {
			FlxTween.tween(cutscene.curMusic, {pitch: 0}, 0.25);
		}
		for (i in 0...game.strumLines.members.length) {
			forEachChar(i, (c) -> {
				c.lastAnimContext = null;
			});
		}
	}
	isLastLine = cutscene.dialogueLines.length == 0;
}

function moveCam(a) {
	if (game.strumLines.members[a] == null)
		return;
	var pos = FlxPoint.get();
	var r = 0;
	var w = 0;
	var o = [0, 0];
	var p = [0, 0];
	for (c in game.strumLines.members[a].characters) {
		if (c == null || !c.visible)
			continue;
		var cpos = c.getCameraPosition();
		pos.x += cpos.x;
		pos.y += cpos.y;

		o[0] += Std.parseFloat(c.xml.get('dialx') ?? '0');
		o[1] += Std.parseFloat(c.xml.get('dialy') ?? '0');

		p[0] += Std.parseFloat(c.xml.get('dialcamx') ?? '0');
		p[1] += Std.parseFloat(c.xml.get('dialcamy') ?? '0');

		r++;
		w += c.animateAtlas != null ? c.animateAtlas.width : c.width;
		// cpos.put();
	}
	if (r > 0) {
		pos.x /= r;
		pos.y /= r;
		o[0] /= r;
		o[1] /= r;
		p[0] /= r;
		p[1] /= r;
		w /= r;
	}
	game.camFollow.setPosition(pos.x + p[0], pos.y + p[1]);

	setPosition(pos.x, pos.y);
	y -= height * 0.8;
	if (flipX)
		x -= width - 60;
	else
		x += -60;

	// trace(o);

	x += o[0];
	y += o[1];

	pos.put();
}

function setupBubble(c) {
	var isNull = game.strumLines.members[c] == null;
	var char = isNull ? null : game.strumLines.members[c].characters[0];

	if (!isNull) {
		var col = char.iconColor ?? 0x717171;
		var white = FlxColor.interpolate(col, FlxColor.WHITE, 0.9);
		var w_ = getColorRGB(white);
		for (i in 0...w_.length) {
			w_[i] = Math.min(w_[i] * 2, 255);
		}
		white = FlxColor.fromRGB(w_[0] / 255, w_[1] / 255, w_[2] / 255);

		var black = col;
		var b_ = getColorRGB(black);
		for (i in 0...b_.length) {
			b_[i] = Math.max(b_[i] - 128, 0) / 255;
			gm.black[i] = b_[i];
			gm.white[i] = w_[i] / 255;
		}
		black = FlxColor.fromRGB(b_[0] * 255, b_[1] * 255, b_[2] * 255);

		speakerText.color = (col & 0xffffff) + 0xff000000;
		text.color = speakerText.borderColor = (black & 0xffffff) + 0xff000000;

		speakerText.text = ' ' + char.curCharacter + ' ';
	} else {
		speakerText.text = ' ';
	}
}

function getColorRGB(col) {
	col = col & 0xffffff;
	return [(col >> 16) & 0xff, (col >> 8) & 0xff, col & 0xff];
}
