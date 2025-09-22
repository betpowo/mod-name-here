import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;

function create() {
	FlxG.camera.bgColor = 0xFF3f0048;

	var sep = ' + ';

	scrollTxt = makeTextBackdrop(getPeople().join(sep) + sep);
	scrollTxt.antialiasing = true;
	scrollTxt.velocity.set(-150, 0);
	scrollTxt.repeatAxes = 0x01;
	scrollTxt.updateHitbox();
	scrollTxt.x = FlxG.width / 2;
	add(scrollTxt);

	logo = new FunkinSprite(0, 0, Paths.image('logo'));
	add(logo);
	logo.screenCenter();
	logo.antialiasing = true;

	scrollTxt.y = logo.y - scrollTxt.height - 10;

	logo2 = new FunkinSprite(0, 0, Paths.image('logo'));
	insert(0, logo2);
	logo2.screenCenter();
	logo2.antialiasing = true;
	logo2.onDraw = (s) -> {
		var deg = s.offset.degrees;
		var spins = 4;
		for (i in 0...spins) {
			s.offset.degrees += (i / spins) * 360;
			s.draw();
		}
		s.offset.degrees = deg;
	}
	logo2.blend = 0;
	logo2.alpha = 0.75;

	enter = new FunkinSprite(0, 0, Paths.image('ui/mnh/titleEnter' + (mobile ? 'M' : '')));
	add(enter);
	enter.addAnim('idle', 'Press Enter to Begin', 24, true, true);
	enter.addAnim('press', 'ENTER PRESSED', 24, true, true, null, 0, 0);
	enter.playAnim('idle');
	enter.screenCenter();
	enter.y = logo.y + logo.height - 50;
	enter.antialiasing = true;
	enter.colorTransform.color = 0x3f0048;
	enter.color = 0xaff7b7; // #aff7b7 + #3f0048 = #eef7ff ; color offset is additive

	shit = new FlxBackdrop(FlxGridOverlay.createGrid(1, 1, 2, 2, true, 0x33ffffff, 0xffffffff));
	shit.scale.set(60, 60);
	shit.updateHitbox();
	shit.screenCenter();
	shit.scrollFactor.set(0.4, 0.4);
	shit.velocity.y = 16;
	shit.blend = 0;
	shit.alpha = 0.1;
	insert(0, shit);

	shit2 = new FlxBackdrop();
	shit2.loadGraphic(Paths.image('carl and shaggy doing the macarena'), true, 30, 30);
	shit2.setGraphicSize(150);
	shit2.antialiasing = true;
	shit2.updateHitbox();
	shit2.screenCenter();
	shit2.scrollFactor.set(0.2, 0.2);
	shit2.velocity.y = 16;
	shit2.blend = 0;
	shit2.alpha = 0.1;
	shit2.animation.add('idle', [for (i in 0...84) i], 24, true);
	shit2.animation.play('idle', true);
	insert(0, shit2);

	var border = 20;
	ver = new FunkinText();
	ver.fieldWidth = FlxG.width - (border * 2);
	ver.alignment = 'right';
	ver.font = Paths.font('sillyfont.ttf');
	ver.borderSize = 3;
	ver.text = 'v' + version;
	ver.screenCenter();
	ver.y = FlxG.height - ver.height - border;
	add(ver);

	ver.borderColor = 0xFF3f0048;

	CoolUtil.playMenuSong();
}

var waitTime = -1;

function getRotate(len:Float, deg:Float) {
	var rad:Float = deg * (Math.PI / 180);
	var __x:Float = len * FlxMath.fastCos(rad);
	var __y:Float = len * FlxMath.fastSin(rad);
	return FlxPoint.get(__x, __y);
}

var elapsedTime = 0.0;

function makeTextBackdrop(text) {
	var dumpTxt = new FunkinText();
	dumpTxt.font = Paths.font('sillyfont.ttf');
	dumpTxt.borderSize = 3;
	dumpTxt.borderColor = 0xffffffff;
	dumpTxt.color = 0xff333333;
	dumpTxt.size = 32;
	dumpTxt.text = text;

	// thank you rozebud
	dumpTxt.drawFrame(true);
	var txt = new FlxBackdrop(dumpTxt.pixels);

	dumpTxt.destroy();
	return txt;
}

function update(elapsed) {
	var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

	if (mobile) {
		for (touch in FlxG.touches.list) {
			if (touch.justPressed) {
				pressedEnter = true;
			}
		}
	}

	if (pressedEnter) {
		if (waitTime == -1) {
			CoolUtil.playMenuSFX(1);
			enter.playAnim('press');
			waitTime = 1.5;
			shit.alpha = 0.5;
			camera.flash(0xffffffff, 0.1);
			FlxTween.tween(shit, {alpha: 0.2}, 0.3);
		} else {
			waitTime = 0;
		}
	}
	if (waitTime != -1) {
		waitTime = Math.max(waitTime - elapsed, 0);
		if (waitTime == 0) {
			FlxG.switchState(new MainMenuState());
		}
		enter.color = FlxColor.fromHSB(elapsedTime * 360, 0.2, 1);
		FlxG.camera.bgColor = FlxColor.fromHSB(elapsedTime * 360, 1, 0.3);
	}

	elapsedTime += elapsed;
	logo.offset.y = Math.abs(Math.sin(Conductor.curBeatFloat * Math.PI)) * 15;
	var r = getRotate(200, elapsedTime * 30);
	shit.velocity.set(r.x, r.y);

	var r = getRotate(900, shit2.rotation = elapsedTime * -150);
	shit2.velocity.set(r.x / 5, r.y / 5);
	shit2.rotation *= -0.06;

	var r = getRotate(FlxMath.lerp(7, 17, Math.abs(Math.sin(Conductor.curBeatFloat * Math.PI * 0.5))), elapsedTime * 50);
	logo2.offset.set(r.x, r.y);
	logo2.frameOffset.y = logo.offset.y;
	logo2.colorTransform.color = scrollTxt.color = ver.color = FlxColor.fromHSB(elapsedTime * (Options.flashingMenu ? 360 : 45), 0.3, 1);
	shit2.color = 0xffffffff;
}

function getPeople() {
	var xmlPath = Paths.xml('config/credits');
	var xml = null;

	var creds = ['you failed to parse credits.xml lil bro'];
	try {
		xml = Xml.parse(Assets.getText(xmlPath)).firstElement();

		for (node in xml.elements()) {
			creds.push((node.get('name') ?? '???').toLowerCase());
		}

		// remove fallback credit
		creds.shift();
	} catch (e:Dynamic) {
		trace('Error while parsing credits.xml: ' + Std.string(e));
	}

	return creds;
}
