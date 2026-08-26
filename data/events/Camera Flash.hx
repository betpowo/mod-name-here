import funkin.editors.charter.Charter;
 

// flixel camera color thing breaks when the last sprite in members has a different blend mode.
// it copies it    . and i    i Dont want that

var fadeSprite = new FunkinSprite();
fadeSprite.zoomFactor = 0;
fadeSprite.scrollFactor.set();
fadeSprite.alpha = 0;

fadeSprite.makeGraphic(1, 1, 0xffffffff, true);
fadeSprite.updateHitbox();

function postUpdate(elapsed) {
	// idk this is probably bad
	if (members[members.length - 1] != fadeSprite) {
		remove(fadeSprite, true);
		add(fadeSprite);
		//trace('hi guys');
	}
	if (fadeSprite.visible) {
		var cam = fadeSprite.cameras[0];
		fadeSprite.scale.set(cam.width, cam.height);
		fadeSprite.updateHitbox();
		fadeSprite.screenCenter();
	}
}

function onEvent(e) {
	switch (e.event.name) {
		case 'Camera Flash':
			e.cancel();

			var fade = fadeSprite; // not typing all that
			var event = e.event;
			var camera = event.params[3] == "camHUD" ? camHUD : camGame;
			var persist = event.params[4] ?? false;
			fade.cameras = [camera];

			var reversed = event.params[0];
			var from = reversed ? 0 : 1; var to = reversed ? 1 : 0;
			fade.blend = BlendMode.fromString((event.params[5] ?? 'NORMAL').toLowerCase());
			FlxTween.cancelTweensOf(fade, ['alpha']);
			fade.alpha = from;
			fade.color = event.params[1];

			if (event.params[2] > 0) {
				FlxTween.tween(fade, {alpha: to}, (Conductor.stepCrochet / 1000) * event.params[2], {
					onComplete: (_) -> {
						if (!persist) fade.alpha = 0;
					}
				});
			} else {
				fade.alpha = to;
			}

			if (PlayState.chartingMode && Charter.startHere) {
				if (e.event.time < Charter.startTime) {
					FlxTween.completeTweensOf(fade, ['alpha']);
				}
			}
	}
}
