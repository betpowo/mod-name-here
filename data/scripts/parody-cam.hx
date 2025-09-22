import flixel.FlxObject;

public var camGridSize:Float = 7;
public var followSpeed:Float = 500;
var camX, camY:Float = 0.0;
var camPoint = FlxPoint.get(0, 0);

function postCreate() {
	camX = camGame.scroll.x + (camGame.width * .5);
	camY = camGame.scroll.y + (camGame.height * .5);

    camPoint.set(camX, camY);
}

function postCameraMove(e) {
	if (shouldSnapCam) {
		camX = camFollow.x; 
		camY = camFollow.y;
		if (snipe) shouldSnapCam = false;
	} else {
		var foll:Float = FlxG.elapsed * followSpeed;
		var dx = camFollow.x - camX;
		var dy = camFollow.y - camY;
		var angleTo = Math.atan2(dy, dx);

		var length = Math.sqrt((dx * dx) + (dy * dy));

		if (Math.abs(length) >= camGridSize) {
			camX += foll * FlxMath.fastCos(angleTo);
			camY += foll * FlxMath.fastSin(angleTo);

			if (camX > camFollow.x)
				camX = Math.max(camX, camFollow.x);
			if (camX < camFollow.x)
				camX = Math.min(camX, camFollow.x);

			if (camY > camFollow.y)
				camY = Math.max(camY, camFollow.y);
			if (camY < camFollow.y)
				camY = Math.min(camY, camFollow.y);
		} else {
			// cheating
			shouldSnapCam = snipe = true;
		}
	}

	camPoint.set(Math.round(camX / camGridSize) * camGridSize, Math.round(camY / camGridSize) * camGridSize);
	camGame.focusOn(camPoint);
}

function onCamTweenFinished(e) {
	shouldSnapCam = false;
}

var shouldSnapCam = false;
var snipe = false;
var buh;
function onEvent(e) {
	if (e.event.name == 'Camera Movement') {
		shouldSnapCam = (buh ??= ['Instant', 'Tweened']).indexOf(e.event.params[4]) != -1;
		snipe = e.event.params[4] == 'Instant';
	}
}