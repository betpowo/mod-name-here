function create() {
	camGame.bgColor = 0xFF1f008e;
}

function destroy() {
	camGame.bgColor = 0;
}

function postCreate() {
	for (s in strumLines.members) {
		for (i in s.characters) {
			i.shader = new CustomShader('jpeg');
			i.shaderEnabled = true;
			i.scripts.call('onJPEGSetup'); // lol !!!
		}
	}

	camGridSize = 14;
}

function onPostGameOver() {
	FlxG.camera.bgColor = 0;
	new FlxTimer().start(FlxG.elapsed * 2, (_) -> {
		// subState.camera.angle = 40;
		subState.character.shader = boyfriend.shader;
		subState.character.scripts.call('onJPEGSetup'); // lol !!!
	});
}