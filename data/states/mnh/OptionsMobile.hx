import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;

function create() {
	var bg = new FunkinSprite();
	bg.makeSolid(FlxG.width, FlxG.height, -1);
	add(bg);

	var leftBG = new FunkinSprite();
	leftBG.makeSolid(FlxG.width * 0.25, FlxG.height, -1);
	add(leftBG);

	var rightBG = new FunkinSprite();
	rightBG.makeSolid(FlxG.width * 0.25, FlxG.height, -1);
	add(rightBG);

	rightBG.x = FlxG.width - rightBG.width;

	leftBG.color = 0xab52ff;
	rightBG.color = 0xff439e;
	bg.color = 0x000000;

	leftBG.alpha = rightBG.alpha = bg.alpha = 0.6;

	var leftArrowBG = makeTextBackdrop('← ←\n ← ', 128, -100);
	add(leftArrowBG);

	var rightArrowBG = makeTextBackdrop('→ →\n → ', 128, -100);
	add(rightArrowBG);

	var left = makeTextBackdrop(' - this part of the screen - \nsimulates the [LEFT] key', 32, -2);
	add(left);

	var right = makeTextBackdrop(' - this part of the screen - \nsimulates the [RIGHT] key', 32, -2);
	add(right);

	for (i in [left, right]) {
		i.angle = -90;
		i.repeatAxes = 0x10;
		i.velocity.y = 100;
		i.spacing.y = i.width * 0.95;
		i.scrollFactor.set();
		i.screenCenter();
		i.x = (i.width * -0.5) + 150;
		i.blend = 0;
	}

	for (i in [leftArrowBG, rightArrowBG]) {
		i.repeatAxes = 0x10;
		i.velocity.y = 100;
		i.scrollFactor.set();
		i.screenCenter();
		i.spacing.y = i.height * -0.33;
		i.x = (i.width * -0.5) + 150;
		i.blend = 0;
		i.alpha = 0.6;
	}
	rightArrowBG.velocity.y *= -1;
	rightArrowBG.x = FlxG.width - rightArrowBG.x - rightArrowBG.width;

	right.velocity.y *= -1;
	right.angle *= -1;
	right.x = FlxG.width - (right.width * 0.5) - 150;

	add(makeText(0, -200, '← for choice/number options →', 32));
	add(makeText(0, -150, '(sliders are bugged as hell but\ni\'m too lazy to fix)', 16));
	add(makeText(0, -40, 'swipe ↑ ↓ = move ↑ ↓', 64));
	add(makeText(0, 40, 'tap = accept/select', 64));
	add(makeText(0, 200, 'swipe → = go back a menu', 32));
}
function makeTextBackdrop(text, ?s, ?l) {
	s ?? 32;
	l ?? -2;
	var dumpTxt = new FunkinText();
	dumpTxt.font = Paths.font('sillyfont.ttf');
	dumpTxt.borderSize = 1.5;
	dumpTxt.borderColor = 0xffffffff;
	dumpTxt.color = 0xff333333;
	dumpTxt.size = s;
	dumpTxt.alignment = 'center';
	dumpTxt._defaultFormat.leading = l;
	dumpTxt.updateDefaultFormat();
	dumpTxt.text = text;


	// thank you rozebud
	dumpTxt.drawFrame(true);
	var txt = new FlxBackdrop(dumpTxt.pixels);
	txt.antialiasing = true;
	dumpTxt.destroy();
	return txt;
}
function makeText(x, y, t, s) {
	var text = new FunkinText();
	text.font = Paths.font('sillyfont.ttf');
	text.alignment = 'center';
	text.borderSize = 5;
	text.borderColor = 0xff480048;
	text.color = 0xffffcc;
	text.text = t;
	text.size = s;
	text.antialiasing = true;
	text.screenCenter();
	text.x += x; text.y += y;
	text.updateHitbox();
	text.moves = false;
	return text;
}
function update(elapsed) {
	var pressedEnter:Bool = controls.ACCEPT;

	if (mobile) {
		for (touch in FlxG.touches.list) {
			if (touch.justReleased) {
				pressedEnter = true;
			}
		}
	}

	if (pressedEnter) {
		close();
	}
}