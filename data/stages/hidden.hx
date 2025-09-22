function create() {
	camGame.bgColor = 0xFF330033;
}

function destroy() {
	camGame.bgColor = 0;
}

function postCreate() {
	// they have to be separate! cus it accounts for the resolution of their sheets
	// and since theyre different, gfs blocks will be larger
	// (they will be using bfs resolution if i do gf.shader = boyfriend.shader)
	for (s in strumLines.members) {
		for (i in s.characters) {
			i.shader = new CustomShader('jpeg');
			i.shaderEnabled = true;
			i.scripts.call('onJPEGSetup'); // lol !!!
		}
	}
}


function onPostGameOver() {
	FlxG.camera.bgColor = 0;
	new FlxTimer().start(FlxG.elapsed * 2, (_) -> {
		// subState.camera.angle = 40;
		subState.character.shader = boyfriend.shader;
		subState.character.scripts.call('onJPEGSetup'); // lol !!!
	});
}