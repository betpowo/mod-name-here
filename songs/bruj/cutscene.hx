final game = PlayState.instance;

function create() {
	game.camGame.visible = game.camHUD.visible = false;
	forceDisableZoomUpdate = true;
	startVideo(Paths.file('songs/bruj/start-cutscene.mp4'), () -> {
		game.camGame.visible = true;
		game.camGame.zoom *= 1.3;
		startDialogue(Paths.file('songs/bruj/dialogue' + (PlayState.difficulty == 'normal' ? '' : '-' + PlayState.difficulty) + '.xml'), () -> {
			close();
			game.camHUD.visible = true;
			game.camHUD.zoom = 3;
			FlxTween.tween(game.camHUD, {zoom: game.defaultHudZoom}, Conductor.crochet / 270, {ease: FlxEase.expoOut});
			FlxTween.tween(game.camGame, {zoom: game.defaultCamZoom}, Conductor.crochet / 270, {ease: FlxEase.sineInOut, onComplete: (_) -> {
				forceDisableZoomUpdate = false;
			}});
		});
	});
}
