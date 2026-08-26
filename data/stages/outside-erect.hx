import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
 

var speakers = null;

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
		grid.color = 0xccffdd;
		grid.active = grid.moves = false;
		grid.zoomFactor = 1.08;
	}
	stageSprites.set('grid', grid);
	for (i in [floorTile1, floorTile2, floorTile3]) {
		i.scrollFactor.set(0, 0.9);
	}
	floorTile1.scrollFactor.y = 0.3;

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
}

function newAdjustColor(h:Float, s:Float, b:Float, c:Float) {
	var shad = new CustomShader('adjustColor');
	shad.hue = h ?? 0;
	shad.saturation = s ?? 0;
	shad.brightness = b ?? 0;
	shad.contrast = c ?? 0;
	return shad;
}
