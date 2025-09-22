import funkin.backend.MusicBeatTransition;
import funkin.backend.utils.FunkinParentDisabler;
import haxe.io.Path;

static var _______________st__icke___r_______Trans___Da_t______________________a = [
	/*
		{
			// timing is based on array index
			image: 'sticker-set-1/bfSticker1'
			x: 69,
			y: 420,
			angle: 3
		}
	 */
];

var grpStickers = new FlxSpriteGroup();

var set = {
	stickers: []
}

var soundKeys = [
	for (i in Paths.getFolderContent('sounds/stickers/', true))
		Paths.sound(Path.withoutExtension(StringTools.replace(i, 'sounds/', '')))
];

var sounds = [];

// for setting outside a state
var stickerSet = null;

function create(e) {
	var _stickerSet = PlayState.SONG?.meta?.customValues?.stickers ?? getDefault();
	set = Json.parse(Assets.getText(Paths.json('stickerpacks/' + _stickerSet)));

	for (i in soundKeys) {
		// trace(i);
		var snd = FlxG.sound.load(i);
		sounds.push(snd);
		FlxG.sound.list.remove(snd);
	}

	if (e.transOut) {
		_______________st__icke___r_______Trans___Da_t______________________a = [];
		fillStickers();
	}
	add(grpStickers);
	makeStickers(e.transOut);

	e.cancel();

	// kill itself
	if (!e.transOut) {
		MusicBeatTransition.script = '';
	}
}

function postCreate(e) {
	if (members[0] is FunkinParentDisabler) {
		for (s in members[0].__sounds) {
			s.play();
		}
	}
}

function getDefault() {
	switch (PlayState.difficulty.toLowerCase()) {
		case 'pico':
			return 'standard-pico';
	}
	return stickerSet ?? 'standard-bf';
}

function fillStickers() {
	// Initialize stickers at each point on the screen, then shuffle up the order they will get placed.
	// This ensures stickers consistently cover the screen.
	var xPos:Float = -500;
	var yPos:Float = -100;
	var interval:Int = FlxG.random.int(70, 100);
	while (xPos <= FlxG.width + 500) {
		var stickerPath = FlxG.random.getObject(set.stickers);

		xPos += (FlxG.width / interval);
		yPos = FlxG.random.int(0, FlxG.height);

		_______________st__icke___r_______Trans___Da_t______________________a.push({
			image: stickerPath,
			x: xPos,
			y: yPos,
			angle: FlxG.random.int(-60, 70),
			scale: FlxG.random.float(0.97, 1.02)
		});
	}

	FlxG.random.shuffle(_______________st__icke___r_______Trans___Da_t______________________a);

	var last = _______________st__icke___r_______Trans___Da_t______________________a[_______________st__icke___r_______Trans___Da_t______________________a.length
		- 1];
	last.x = FlxG.width * 0.5;
	last.y = FlxG.height * 0.5;
	last.angle = 0;
	last.scale = 1;
}

function makeStickers(o) {
	var out = o;
	var total = _______________st__icke___r_______Trans___Da_t______________________a.length - 1;
	for (k => i in _______________st__icke___r_______Trans___Da_t______________________a) {
		var sticker = new FunkinSprite();
		sticker.loadSprite(Paths.image(i.image));
		sticker.updateHitbox();
		sticker.setPosition(i.x, i.y);
		sticker.x -= sticker.frameWidth * 0.5;
		sticker.y -= sticker.frameHeight * 0.5;
		sticker.antialiasing = true;
		sticker.visible = !out;
		grpStickers.add(sticker);

		sticker.angle = i.angle;

		if (sticker.visible) {
			sticker.scale.x = sticker.scale.y = i.scale;
		}

		new FlxTimer().start(Math.max(k / total, 0.001), (_) -> {
			sticker.visible = !sticker.visible;
			// KILL
			new FlxTimer().start(1 / 24, (__) -> {
				sticker.scale.x = sticker.scale.y = i.scale;
			});
			FlxG.random.getObject(sounds).play();
		});
	}
	new FlxTimer().start(2, (_) -> {
		finish();
	});
}

function onFinish(e) {
	if (!e.cancelled) {
		e.cancel();

		if (newState != null)
			FlxG.switchState(newState);
		else close();

		transitionScript.call('onPostFinish');
	}
}
