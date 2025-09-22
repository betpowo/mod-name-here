import funkin.backend.MusicBeatState;
import flixel.text.FlxTextFormat;
import flixel.text.FlxTextFormatMarkerPair;

var flixel = new FunkinSprite();
var flixelSnd = FlxG.sound.load(Paths.sound('flixel'));

public function getIntroTextShit() {
	var fullText = Assets.getText(Paths.txt('titlescreen/introText'));
	var firstArray = fullText.split('\n');
	var swagGoodArray = [];
	for (i in firstArray) {
		swagGoodArray.push(i.split('--'));
	}
	return swagGoodArray;
}

function create() {
	FlxG.camera.bgColor = 0x0;

	titleAlphabet = new Alphabet(0, 0, "WARNING", true);
	titleAlphabet.screenCenter(0x01);
	add(titleAlphabet);

	disclaimer = new FunkinText(16, titleAlphabet.y + titleAlphabet.height + 10, FlxG.width - 32, "", 32);
	disclaimer.alignment = 'center';
	disclaimer.applyMarkup('This mod is *not* funny, and has flashing lights.\nIt also uses lots of shaders, some can\'t be disabled.\nBy continuing, you agree to *all* that will happen.',
		[new FlxTextFormatMarkerPair(new FlxTextFormat(0xFF717171), "*")]);
	add(disclaimer);
	var off = Std.int((FlxG.height - (disclaimer.y + disclaimer.height)) / 2);
	disclaimer.y += off;
	titleAlphabet.y += off;

	flixel.antialiasing = true;
	flixel.loadSprite(Paths.image('haxeflixel'));
	flixel.addAnim('idle', 'haxeflixel', 12, true);
	flixel.playAnim('idle', true);
	flixel.scale.set(0.7, 0.7);
	flixel.updateHitbox();
	flixel.screenCenter();
	flixel.setPosition(Std.int(flixel.x), Std.int(flixel.y));
	flixel.visible = false;
	add(flixel);

	flixelSnd.onComplete = () -> {
		flixel.visible = false;
		var bleh = new Alphabet(0, 0, FlxG.random.getObject(getIntroTextShit()).join('\n'), true);
		bleh.scale.set(0.6, 0.6);
		bleh.alignment = 1;
		bleh.updateHitbox();
		bleh.screenCenter();
		bleh.alpha = 0.6;
		add(bleh);
	}
}

var elapsedTime = 0.0;
var waitTime = -1;

function update(elapsed) {
	elapsedTime += elapsed;

	var pressedEnter:Bool = controls.ACCEPT;

	if (mobile) {
		for (touch in FlxG.touches.list) {
			if (touch.justPressed) {
				pressedEnter = true;
			}
		}
	}

	if (pressedEnter) {
		if (waitTime == -1) {
			CoolUtil.playMenuSFX(2);
			flixelSnd.play(flixel.visible = !(disclaimer.visible = titleAlphabet.visible = false));
			waitTime = (flixelSnd.length * 0.001) + 0.8;
		} else {
			waitTime = 0;
		}
	}

	if (waitTime != -1) {
		waitTime = Math.max(waitTime - elapsed, 0);
		if (waitTime == 0) {
			waitTime = -1;
			MusicBeatState.skipTransIn = MusicBeatState.skipTransOut = true;
			FlxG.switchState(new TitleState());
		}
	}
}
