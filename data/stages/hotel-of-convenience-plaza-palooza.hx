function create() {
	camGame.bgColor = 0xFFddffee;
}

function destroy() {
	camGame.bgColor = 0;
}

function onPostGameOver() {
	FlxG.camera.bgColor = 0xFF330066;
}