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
		grid.color = 0xfdffd1;
		grid.active = grid.moves = false;
		grid.zoomFactor = 1.08;
	}
	stageSprites.set('grid', grid);
}