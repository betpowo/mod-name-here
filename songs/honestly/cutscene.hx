final game = PlayState.instance;
var a = !PlayState.isStoryMode;

function create() {
	if (a) {
		game.camGame.visible = true;
		game.camHUD.visible = false;
		game.camGame.zoom *= 1.3;
		forceDisableZoomUpdate = true;
	}
	startDialogue(Paths.file('songs/honestly/dialogue' + (PlayState.difficulty == 'normal' ? '' : '-' + PlayState.difficulty) + '.xml'), () -> {
		close();
		if (a) {
			game.camHUD.visible = true;
			game.camHUD.zoom = 3;
			FlxTween.tween(game.camHUD, {zoom: game.defaultHudZoom}, Conductor.crochet / 270, {ease: FlxEase.expoOut});
			FlxTween.tween(game.camGame, {zoom: game.defaultCamZoom}, Conductor.crochet / 270, {ease: FlxEase.sineInOut, onComplete: (_) -> {
				forceDisableZoomUpdate = false;
			}});
		}
	});
}
