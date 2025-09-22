import flixel.text.FlxTextBorderStyle;

importScript('data/scripts/pixel');
enablePauseMenu = enableCameraHacks = pixelSplashes = false;
function create() {
	currentUI = 'pixel';
}

function postCreate() {
	var game = PlayState.instance;
	var hbOffY = -15;

	for (i in [game.scoreTxt, game.missesTxt, game.accuracyTxt]) {
		i.font = Paths.font('pixel.otf');
		i.fieldWidth = 700;
		i.screenCenter(0x01);
		i.borderSize = 2;
		i.y += Std.int(hbOffY / 2);
		i.borderQuality = 0;
	}

	game.healthBar.y += hbOffY;
	game.healthBarBG.y += hbOffY;
	game.iconP1.y += hbOffY;
	game.iconP2.y += hbOffY;

	var shads = scripts.getByName('NoteHandler.hx').get('shaderMap');
	for (i => v in [
		[0xE276FF, 0xFFF9FF, 0x60008D],
		[0x3DCAFF, 0xF4FFFF, 0x003060],
		[0x71E300, 0xF6FFE6, 0x003100],
		[0xFF884E, 0xFFFAF5, 0x6C0000]
	]) {
		shads.get(i).r = getFUCKINGcolor(v[0]);
		shads.get(i).g = getFUCKINGcolor(v[1]);
		shads.get(i).b = getFUCKINGcolor(v[2]);
	}

	for (content in Paths.getFolderContent('images/stages/school/ui/', true, null))
		graphicCache.cache(Paths.getPath(content));
}

function onNoteCreation(e) {
	e.note.splash = 'pixel-default';
}

/*function onPostNoteCreation(e) {
	var lane = e.note.strumLine;
	e.note.scale.x *= lane.strumScale;
	e.note.scale.y *= lane.strumScale;
	e.note.updateHitbox();
}

function onPostStrumCreation(e) {
	var lane = strumLines.members[e.player];
	e.strum.scale.x *= lane.strumScale;
	e.strum.scale.y *= lane.strumScale;
	e.strum.updateHitbox();
}*/

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

function getFUCKINGcolor(col) {
	return [redf(col), greenf(col), bluef(col)];
}

var ratingScale:Float = 5;

function onNoteHit(e) {
	e.numScale = e.ratingScale = ratingScale;
}

function onHoldCoverCreation(e) {
	e.data.x = 27.5;
	e.data.y = 1;
	e.data.sprite = 'stages/school/ui/hold';
	e.data.scale = daPixelZoom;
}

function onPostHoldCoverCreation(e) {
	e.data.cover.antialiasing = false;
}

function showSplash(e) {
	var sprite = new FunkinSprite();
	sprite.loadGraphic(Paths.image('stages/school/ui/holds-and-splashes'), true, 31, 25);
	sprite.animation.add('splash', [0, 1, 2, 2, 3, 3], 24, false);
	sprite.animation.play('splash', true);
	sprite.animation.finishCallback = (a) -> {
		sprite.kill();
		remove(sprite, true);
		new FlxTimer().start(0.03, (_) -> {
			sprite.destroy();
		}); // ???
	}
	sprite.scale.set(daPixelZoom, daPixelZoom);
	sprite.updateHitbox();
	sprite.setPosition(-sprite.origin.x, -sprite.origin.y);
	return sprite;
}

function postUpdate(elapsed) {
	if (comboGroup.members.length > 0) {
		comboGroup.forEachAlive((s) -> {
			s.frameOffset.x = ((s.x - comboGroup.x) % s.scale.x) / ratingScale;
			s.frameOffset.y = ((s.y - comboGroup.y) % s.scale.y) / ratingScale;
			s.alpha = Math.floor(s.alpha * ratingScale) / ratingScale;
		});
	}
}

function onLyricSetup(e) {
	e.text.font = Paths.font('pixel.otf');
	e.text.updateHitbox();
	e.text.screenCenter();
	e.text.y = FlxG.height - 150 - e.text.height;
}
