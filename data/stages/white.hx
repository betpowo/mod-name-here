function create() {
	camGame.bgColor = -1;
}

function destroy() {
	camGame.bgColor = 0;
}

function onPostGameOver() {
	FlxG.camera.bgColor = 0;
}
