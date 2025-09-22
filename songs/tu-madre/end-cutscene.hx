var sound = FlxG.sound.load(Paths.sound('tu-madre-end'));
final game = PlayState.instance;

function create() {
	sound.play();
	sound.onComplete = close;

	camZooming = game.camZooming = true;

	game.curCameraTarget = -1;
	game.defaultCamZoom *= 1.3;
	game.camFollow.x -= 300;
	game.camFollow.y -= -100;

	zoomOffsets[0] = game.camGame.zoom - game.defaultCamZoom;
	new FlxTimer().start(0.25, (_) -> {
		game.dad.playAnim('laser', 'LOCK');
	});
	new FlxTimer().start(3, (_) -> {
		game.dad.script.get('laser').angle = -6;
		game.health = 0.0001;

		var pos = game.getStrumlineCamPos(0);
		game.camFollow.setPosition(pos.pos.x, pos.pos.y);
		pos.put();

		game.dad.scripts.call('shoot');
		game.defaultCamZoom = 0.7;
		zoomOffsets[0] = game.camGame.zoom - game.defaultCamZoom;
		zoomOffsets[0] += 0.3;
		zoomOffsets[1] += 0.2;
		game.camFollow.x += 300;
		game.camFollow.y += -100;

		game.boyfriend.moves = game.gf.moves = true;
		game.boyfriend.velocity.set(1200, -100);
		game.gf.velocity.set(1000, -200);
		game.gf.playAnim('sad', 'LOCK');
		game.boyfriend.playAnim('singRIGHTmiss', 'LOCK');
		game.boyfriend.angularVelocity = 1440;
		game.gf.angularVelocity = -1440;

		game.camGame.shake(17 / game.camGame.width, 3);
		game.camHUD.shake(7 / game.camHUD.width, 3);
	});
	new FlxTimer().start(6, (_) -> {
		game.dad.playAnim('idle', 'LOCK');
	});
	new FlxTimer().start(7.5, (_) -> {
		FlxTween.tween(game, {defaultCamZoom: 0.9}, 3, {ease: FlxEase.sineInOut});
		var pos = game.getStrumlineCamPos(0);
		FlxTween.tween(game.camFollow, {x: pos.pos.x, y: pos.pos.y}, 4, {ease: FlxEase.sineInOut});
		pos.put();
	});
}

function update() {
	game.updateIconPositions();
	//game.camGame.updateScroll();

	game.persistentUpdate = true;
}