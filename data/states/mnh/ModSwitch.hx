import flixel.system.FlxAssets;
import flixel.FlxObject;
import flixel.text.FlxTextBorderStyle;
import funkin.backend.assets.ModsFolder;
import openfl.filters.BlurFilter;

var mods = [];
var texts = [];
var blurs = [];
var selected = 0;
var canSelect = false;
var selector = null;
var statix = new FunkinSprite(0, 0, Paths.image('menus/static'));
var stxSound = FlxG.sound.load(Paths.sound('static'));
var camFollow:FlxObject = new FlxObject(0, 0, 0, 0);
var cam = new FlxCamera();
var beep = FlxG.sound.load(FlxAssets.getSound('flixel/sounds/beep'));

function create() {
	FlxG.cameras.add(cam, false);
	camera = cam;
	mods = ModsFolder.getModsList();
	mods.push(null);

	var bg = new FlxSprite(0, 0).makeSolid(FlxG.width, FlxG.height, 0xFF000000);
	bg.updateHitbox();
	bg.scrollFactor.set();
	add(bg);

	for (i => v in mods) {
		var targetText:String = v ?? '[ disable. ]';
		var t = setupText(targetText);
		t.alpha = 0.2;
		t.setPosition(50, 50 + (50 * i));
		texts.push(t);
		add(t);
	}

	selector = setupText('>');
	add(selector);

	changeSelection(mods.indexOf(ModsFolder.currentModFolder));

	add(statix);
	statix.visible = false;
	statix.scrollFactor.set();

	stxSound.looped = true;
	stxSound.play();
	stxSound.volume = 0;

	FlxG.sound.music.volume = FlxG.sound.music.pitch = 0;
	doStatic(0.25, () -> {
		canSelect = true;
	});

	camFollow.x = FlxG.width * 0.5;
	camFollow.y = FlxG.height * 0.5;

	camera.follow(camFollow, null, 0.4);
	var margin = 50;
	camera.deadzone.set(0, margin, camera.width, camera.height - (margin * 2.5));
}

function setupText(v) {
	var t = new FunkinText();
	var b = new FunkinText();

	for (i in [t, b]) {
		i.size = 40;
		i.font = Paths.font('5by7.ttf');
		i.borderColor = 0x000000;
		i.borderSize = 0;
		i.text = v;
		i.blend = 0;
	}

	b.textField.filters = [new BlurFilter(5, 5, 1)];
	blurs.push({text: b, tracker: t});
	add(b);

	return t;
}

function update(elapsed) {
	if (statix.visible) {
		statix.flipX = FlxG.random.bool(50);
		statix.flipY = FlxG.random.bool(50);
	}

	if (!canSelect)
		return;

	if (controls.DOWN_P || FlxG.mouse.wheel == -1)
		changeSelection(1);
	if (controls.UP_P || FlxG.mouse.wheel == 1)
		changeSelection(-1);
	if (controls.ACCEPT) {
		canSelect = false;
		if (mods[selected] != false) {
			doStatic(0.6, () -> {
				FlxG.camera.visible = false;
				ModsFolder.switchMod(mods[selected]);
			});
		} else {
			exit();
		}
	}

	if (controls.BACK) {
		canSelect = false;
		exit();
	}

	for (i in blurs) {
		i.text.setPosition(i.tracker.x, i.tracker.y);
		i.text.alpha = i.tracker.alpha * FlxG.random.float(0.7, 1);
	}
}

function exit() {
	doStatic(0.2, () -> {
		camFollow.setPosition(FlxG.width * 0.5, FlxG.height * 0.5);
		camera.snapToTarget();
		FlxG.sound.music.volume = FlxG.sound.music.pitch = 1;
		close();
	});
}

function changeSelection(ch) {
	var t = texts[selected];
	t.alpha = 0.2;

	selected = FlxMath.wrap(selected + ch, 0, mods.length - 1);

	var t = texts[selected];
	t.alpha = 1;

	selector.setPosition(t.x - 30, t.y - 4);
	camFollow.y = t.y;

	beep.play(true);
}

function doStatic(t, c) {
	statix.visible = true;
	stxSound.volume = 1;
	stxSound.pitch = FlxG.random.float(0.4, 2);
	var callback = c;
	new FlxTimer().start(t, (_) -> {
		statix.visible = false;
		stxSound.volume = 0;

		if (callback != null)
			callback();
	});
}

function destroy() {
	FlxG.cameras.remove(cam);
	cam.destroy();
}
