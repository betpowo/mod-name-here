function onEvent(e) {
	switch (e.event.name) {
		case 'Camera Toggle':
			var p = e.event.params;
			var cam = camGame;
			if (p[1] == 'camHUD')
				cam = camHUD;
			cam.visible = p[0];
	}
}

function onPostGameOver() {
	camGame.visible = true;
}
