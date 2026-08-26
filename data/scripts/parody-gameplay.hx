import funkin.backend.scripting.events.CancellableEvent;

function postCreate() {
	for (s in strumLines.members) {
		for (i in s.characters) {
			if (i == null)
				continue;
			// lol !!!)
			if (i.scripts.event('onJPEGSetup', new CancellableEvent()).cancelled)
				continue;

			i.shader = new CustomShader('jpeg');
			i.useRenderTexture = true;
		}
	}
}

function onGameOver(e) {
	e.gameOverSong = 'parody/' + e.gameOverSong;
	e.retrySFX = 'parody/' + e.retrySFX;
}

function onPostGameOver() {
	FlxG.camera.bgColor = 0;
	new FlxTimer().start(FlxG.elapsed * 2, (_) -> {
		// subState.camera.angle = 40;
		subState.character.shader = boyfriend.shader;
		subState.character.scripts.event('onJPEGSetup', new CancellableEvent()); // lol !!!
	});
}
