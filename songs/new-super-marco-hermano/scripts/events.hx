var shit = new FunkinSprite();
var fire = new FunkinSprite();
var bfgfFly = new FunkinSprite();
var marco; // for cacheing the correct one
var bf_fnf;

function postCreate() {
	shit.makeGraphic(1, 1, 0xffffffff, 'ughhhhhhmarcothing');
	shit.blend = 14;
	shit.alpha = 0.9;

	insert(members.indexOf(gf) + 1, shit);

	shit.scale.set(camGame.width * 3, camGame.width * 3);
	shit.updateHitbox();
	shit.setPosition(224, 700);
	shit.x -= shit.width * 0.5;
	shit.y -= shit.height * 0.5;
	shit.shader = new FunkinShader('
    #pragma header
    uniform float radius = -1.0;
    void main() {
        vec2 uv = openfl_TextureCoordv;
        vec2 p = vec2(630.0);
        if (distance(floor(uv * p) / p, vec2(0.5)) < radius) {
            gl_FragColor = vec4(0.0);
            return;
        }
        gl_FragColor = textureCam(bitmap, getCamPos(uv));
    }
    ');
	shit.shader.radius = 0.0;

	insert(members.indexOf(stage.stageSprites.get('castle')) + 1, fire);
	fire.loadGraphic(Paths.image('stages/marco2/Animated fire by nevit'), true, 239, 179);
	fire.animation.add('idle', [for (i in 0...12) i], 24, true);
	fire.animation.play('idle', true);

	fire.setGraphicSize(camGame.width);
	fire.updateHitbox();
	fire.screenCenter();
	fire.zoomFactor = 0;
	fire.scrollFactor.set(0.0, 0.1);
	fire.y = -300;

	fire.alpha = 0;

	marco = dad;
	bf_fnf = boyfriend;

	insert(members.indexOf(bf_fnf) + 1, bfgfFly);
	bfgfFly.loadSprite(Paths.image('stages/marco2/fack you'));
	bfgfFly.addAnim('idle', 'anim', 0, false);
	bfgfFly.playAnim('idle', true);
	bfgfFly.scale.set(6, 6);
	bfgfFly.updateHitbox();

	bfgfFly.setPosition(bf_fnf.x + bf_fnf.globalOffset.x - 600, bf_fnf.y + bf_fnf.globalOffset.y - 500);
	bfgfFly.visible = false;

	marco.alpha = 0;
}

var shitTweens = [];

function setShit(r, a) {
	for (i in shitTweens) {
		i.cancel();
		shitTweens.remove(i, true);
	}
	shitTweens.push(FlxTween.tween(shit.shader, {radius: Std.parseFloat(r)}, 2, {ease: FlxEase.elasticOut}));
	shitTweens.push(FlxTween.tween(shit, {alpha: Std.parseFloat(a)}, 0.4, {ease: FlxEase.sineOut}));
}

var calls = 0;

function resetHealth() {
	var c = calls++;

	if (c < 2)
		FlxTween.tween(this, {health: 1}, 1, {ease: FlxEase.circOut});

	switch (c) {
		case 0:
			scripts.call('onChangeCharacter', [
				{
					event: {params: [0, 'luis', 0, true]},
					character: luis,
					strumIndex: 0,
					memberIndex: 0
				}
			]);
			iconP2.setIcon(dad.getIcon());
			FlxTween.tween(iconP3, {alpha: 1}, 0.3, {ease: FlxEase.circOut});
		case 1:
			scripts.call('onChangeCharacter', [
				{
					event: {params: [0, 'bodrio', 0, true]},
					character: bodrio,
					strumIndex: 0,
					memberIndex: 0
				}
			]);
			scripts.call('onChangeCharacter', [
				{
					event: {params: [1, 'luis', 0, true]},
					character: luis,
					strumIndex: 1,
					memberIndex: 0
				}
			]);
			iconP1.setIcon(boyfriend.getIcon());
			iconP3.isPlayer = iconP3.flipX = true;
		case 2:
			scripts.call('onChangeCharacter', [
				{
					event: {params: [0, 'luis', 0, true]},
					character: luis,
					strumIndex: 0,
					memberIndex: 0
				}
			]);
			iconP2.setIcon(marco.getIcon());
			scripts.call('onChangeCharacter', [
				{
					event: {params: [1, 'bf-pixel', 0, true]},
					character: bf_fnf,
					strumIndex: 1,
					memberIndex: 0
				}
			]);
			iconP3.isPlayer = iconP3.flipX = false;
	}
}

function changeStrumCharacters() {
	strumLines.members[1].characters = [marco];
	strumLines.members[0].characters = [bodrio];
	strumLines.members[2].characters = [luis];
}

function showBodrio() {
	FlxTween.tween(bodrio, {alpha: 1}, 2, {ease: FlxEase.bounceOut});
}

function capture() {
	boyfriend.alpha = gf.alpha = 0;
	boyfriend.visible = gf.visible = false; // pauses auto cam follow
	bfgfFly.visible = true;
	bfgfFly.playAnim('idle', true);

	for (i in shitTweens) {
		i.cancel();
		shitTweens.remove(i, true);
	}

	shit.blend = 0; // 14
	shit.alpha = 1;
	shit.shader.radius = 0;
	new FlxTimer().start(1 / 24, (_) -> {
		shit.blend = 14;
		new FlxTimer().start(1 / 24, (_) -> {
			shit.alpha = 0;
			shit.shader.radius = 1;
			boyfriend.visible = gf.visible = true; // resumes auto cam follow

			bfgfFly.moves = true;
			bfgfFly.velocity.set(-260, -600);
			bfgfFly.acceleration.y = 1000;

			bfgfFly.animation.curAnim.curFrame = 1;

			FlxTween.tween(bfgfFly.scale, {x: 1, y: 1}, 2, {ease: FlxEase.circOut});
			FlxTween.tween(bfgfFly.scrollFactor, {x: 0.1, y: 0.1}, 2, {ease: FlxEase.circOut});
			new FlxTimer().start(0.7, (_) -> {
				remove(bfgfFly, true);
				insert(members.indexOf(stage.stageSprites.get('hills')), bfgfFly);
			});
		});
	});

	var frameTime = 0;
	var defFrameT = 0.04;
	var oddFrame = true;

	FlxTween.num(100, 0, 2.6, {
		ease: FlxEase.expoOut,
		onComplete: (_) -> {
			camGame.targetOffset.y = 0;
		}
	}, (num) -> {
		if ((frameTime -= FlxG.elapsed) < 0) {
			frameTime = defFrameT;
			oddFrame = !oddFrame;

			var val = num * (oddFrame ? -1 : 1);
			camGame.targetOffset.y = val;
			camGame.scroll.y = (camFollow.y - (camGame.height * 0.5)) + val;
		}
	});
}

function evil() {
	fire.alpha = 1;
	for (i in ['sky', 'castle', 'hills', 'ground']) {
		if (stage.stageSprites.exists(i)) {
			stage.stageSprites.get(i).color = 0xff3366;
		}
	}
	luis.x += 950;
	luis.isPlayer = !luis.isPlayer;
	luis.fixChar(luis.isPlayer);
	luis.playAnim('luis', true, 'NONE'); // should show him at correct pos

	marco.x += 200;
}

function moveThatGuy(y) {
	if (y == 'true') {
		marco.x += 400;
	} else {
		marco.x -= 400;
		shit.screenCenter();
	}
}

function spawnMarco() {
	marco.alpha = 1;
	var m = marco.script.get('playerSpr');

	m.playAnim('jump', true, 'LOCK');
	marco.script.get('states').jump = true;

	var initialPos = {x: m.x, y: m.y};

	m.skipNegativeBeats = true; // disable physics

	m.x -= 400;
	m.y = FlxG.height * 1.1;

	var dur = 0.95;

	FlxTween.tween(m, {x: initialPos.x}, dur * 1.4, {
		ease: FlxEase.circOut
	});
	FlxTween.tween(m, {y: (initialPos.y - 160)}, (dur * 0.6), {
		ease: FlxEase.sineOut,
		onComplete: (_) -> {
			m.skipNegativeBeats = false;
			m.velocity.y = 0;
		}
	});
}

function spawnLuis() {
	luis.playAnim('jump', true, 'LOCK');
	luis.alpha = 1;

	var initialPos = {x: luis.x, y: luis.y};

	luis.x -= 400;
	luis.y = FlxG.height * 1.1;

	var dur = 0.95;

	FlxTween.tween(luis, {x: initialPos.x}, dur * 1.4, {ease: FlxEase.circOut});
	FlxTween.tween(luis, {y: (initialPos.y - 160)}, (dur * 0.6), {
		ease: FlxEase.sineOut,
		onComplete: (_) -> {
			FlxTween.tween(luis, {y: initialPos.y}, (dur * 0.4), {
				ease: FlxEase.sineIn,
				onComplete: (_) -> {
					luis.playAnim('luis', true, 'LOCK');
				}
			});
		}
	});
}

var appliedHide = false;

function update() {
	if (appliedHide != (appliedHide = true)) {
		bodrio.alpha = luis.alpha = iconP3.alpha = 0;
	}

	if (star) {
		for (i in [marco, luis]) {
			i.colorTransform.color = FlxColor.fromHSB(Conductor.curBeatFloat * 360, 0.3, 0.6);
			i.colorTransform.redMultiplier = i.colorTransform.greenMultiplier = i.colorTransform.blueMultiplier = 1;
		}
	}
}

function marcoPlayAnim(anim) {
	marco.script.get('playerSpr').playAnim(anim, true);
}

var star = false;

function enableStar() {
	star = true;
}

function KILLHIMYEAHHHHH() {
	bodrio.script.set('warpSpeed', 8);
	FlxTween.color(bodrio, 5, (bodrio.color & 0xffffff) + 0xff000000, 0xFF770000, {
		onComplete: (_) -> {
			FlxTween.num(6, 4, 5, {
				ease: FlxEase.circIn,
				onUpdate: (t) -> {
					bodrio.alpha = 1 - t.percent;
				}
			}, (num) -> {
				bodrio.script.set('defaultScale', num);
			});
		}
	});
}

var starNoteRGBShader = new CustomShader('rgbPalette');

starNoteRGBShader.r = [for (i in 0...3) 0.50];
starNoteRGBShader.g = [for (i in 0...3) 1.00];
starNoteRGBShader.b = [for (i in 0...3) 0.05];
function onPostNoteHit(e) {
	if (!star || e.note.isSustainNote)
		return;
	var note = new Note(e.note.strumLine, {
		time: -1000,
		id: e.note.strumID
	});
	note.scrollFactor.set(1, 1);

	final spr = (e.character == marco) ? marco.script.get('playerSpr') : e.character;
	final isChar = (spr == e.character);

	note.x = spr.getMidpoint().x + (isChar ? spr.globalOffset.x * (spr.isPlayer ? -1 : 1) : 0);
	note.y = spr.getMidpoint().y + (isChar ? spr.globalOffset.y : 0);

	note.x -= note.width * 0.5;
	note.y -= note.width * 0.5;

	note.shader = starNoteRGBShader;

	note.moves = true;
	note.velocity.y = -1000;
	note.blend = 0;

	insert(members.indexOf(e.character), note);
}
