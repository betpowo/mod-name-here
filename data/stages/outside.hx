import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import openfl.display.BlendMode;

var speakers = null;

function create() {
	camGame.bgColor = -1;
}

function postCreate() {
	var stageSprites = PlayState.instance.stage.stageSprites;

	var grid;
	if (!Options.lowMemoryMode) {
		grid = new FunkinSprite().loadGraphic(FlxGridOverlay.createGrid(1, 1, 100, 1, true, -1, 0));
		insert(members.indexOf(floorTile3) + 1, grid);
		grid.scrollFactor.set(1.15, 1.15);
		grid.antialiasing = false;
		grid.scale.set(100, 10);
		grid.updateHitbox();
		grid.screenCenter();
		grid.y = 900;
		grid.color = 0xfdffd1;
		grid.active = grid.moves = false;
		grid.zoomFactor = 1.08;
	}
	stageSprites.set('grid', grid);
	for (i in [floorTile1, floorTile2, floorTile3]) {
		i.scrollFactor.set(0, 0.9);
	}
	floorTile1.scrollFactor.y = 0.3;

	if (PlayState.difficulty != 'normal') {
		var charShader = newAdjustColor(-10, -3, -4, 20);

		for (_ in strumLines.members) {
			for (i in _.characters) {
				i.shader = charShader;
			}
		}

		var bgShader = newAdjustColor(-30, 100, 20, 40);

		house.shader = cardboard.shader = bgShader;
		if (!Options.lowMemoryMode) {
			bg.color = 0xFF99eeee;
			grid.color = 0xFFccffdd;
		}

		floorTile1.makeSolid(floorTile1.width, floorTile1.height, 0xFFccffdd);
		floorTile2.makeSolid(floorTile2.width, floorTile2.height, 0xFF66ffbb);
		floorTile3.makeSolid(floorTile3.width, floorTile3.height, 0xFF66ccdd);

		/////////////////////////////////////////////////////////////////////////

		// im startingto liek it without them actually
		if (false && !Options.lowMemoryMode) {
			var clouds = new FunkinSprite().loadGraphic(Paths.image('stages/outside/clouds'));
			clouds.antialiasing = true;
			// clouds.scale.set(0.5, 0.5);
			clouds.scale.set(6, 6);
			clouds.updateHitbox();
			clouds.screenCenter(0x01);
			clouds.moves = true;
			clouds.velocity.x = -3;
			clouds.scrollFactor.set(0.1, 0.1);
			clouds.y = -50;
			clouds.color = 0xbcfffc;
			clouds.blend = BlendMode.HARDLIGHT;
			clouds.zoomFactor = 0.04;
			clouds.x = 50;
			insert(0, clouds);
			stageSprites.set('clouds', clouds);
		}

		FlxG.camera.bgColor = 0xFF1e717b;

		var grad = new FunkinSprite().loadGraphic(Paths.image('menus/transitionSpr'));
		grad.antialiasing = true;
		grad.setGraphicSize(camGame.width * 1.5, camGame.height * 0.7);
		grad.updateHitbox();
		grad.screenCenter(0x01);
		grad.scrollFactor.set(0, 0.3);
		grad.zoomFactor = 0;

		grad.flipY = true;
		grad.colorTransform.color = 0xbcfffc;

		/*var FUCK = new CustomShader('gradientMap');
			FUCK.black = getRGBAarray(0x1e717b);
			FUCK.white = getRGBAarray(0xbcfffc);
			FUCK.mult = 1;

			grad.shader = FUCK;
		 */
		grad.blend = BlendMode.ADD;
		grad.alpha = 0.5;

		grad.y -= 40;

		insert(0, grad);
	}
}

function alpha(col) {
	return (col >> 24) & 0xff;
}

function red(col) {
	return (col >> 16) & 0xff;
}

function green(col) {
	return (col >> 8) & 0xff;
}

function blue(col) {
	return col & 0xff;
}

function alphaf(col) {
	return alpha(col) / 255;
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

function getRGBAarray(col:FlxColor) {
	return [redf(col), greenf(col), bluef(col), (col == col & 0xffffff) ? 1 : alphaf(col)];
}

function newAdjustColor(h:Float, s:Float, b:Float, c:Float) {
	var shad = new CustomShader('adjustColor');
	shad.hue = h ?? 0;
	shad.saturation = s ?? 0;
	shad.brightness = b ?? 0;
	shad.contrast = c ?? 0;
	return shad;
}

function newBGSprite(image, x, y, scrollx, scrolly) {
	var sprite = new FlxSprite();
	sprite.loadGraphic(Paths.image(image));
	sprite.setPosition(x, y);
	sprite.scrollFactor.set(scrollx, scrolly);
	sprite.antialiasing = true;
	sprite.updateHitbox();
	return sprite;
}

function destroy() {
	camGame.bgColor = 0;
}

function onPostGameOver() {
	FlxG.camera.bgColor = 0xFF330066;
}
