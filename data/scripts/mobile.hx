import flixel.FlxObject;

// disableScript();
public var addInputs = true;

function postCreate() {
	downscroll = true;

	for (s in strumLines) {
		if (s.data.type == 2)
			continue;
		var x = FlxG.width * 0.5;
		var y = 100;
		var scale = 1;

		if (s.cpu) {
			x = (FlxG.width * 0.2) - 80;
			y = FlxG.height - 68;
			scale = 0.5;
		}

		if (PlayState.coopMode) {
			// shortcut
			x = FlxG.width * 0.5;
			y = FlxG.height * 0.5;
			scale = 1;
		}

		setStrumLineTransform(s, x, y, scale * s.strumScale);
		/*s.forEach((strum) -> {
			if (strum.scrollSpeed == null)
				strum.scrollSpeed = scrollSpeed;
			strum.scrollSpeed *= scale;
		});*/

		if (!PlayState.coopMode) {
			if (!s.cpu) {
				s.forEach((strum) -> {
					var newID = strum.ID - s.members.length / 2;
					strum.x += (80 + (60 * Math.abs(newID))) * FlxMath.signOf(newID) * s.strumScale;
				});
			}
		} else {
			s.forEach((strum) -> {
				strum.angle = 90 * (s.opponentSide ? 1 : -1);
				strum.y = ((s.opponentSide ? s.members.length - 1 - strum.ID : strum.ID) * Note.swagWidth * s.strumScale * 1.4);
				strum.x = 166;
				if (!s.opponentSide)
					strum.x = FlxG.width - strum.x - strum.height; // use height here becuse, its rotated
			});
			var gh = getGroupHeight(s);
			s.forEach((strum) -> {
				strum.y += (strum.camera.height - gh) * 0.5;
			});
		}

		if (addInputs) {
			s.forEach((strum) -> {
				addTouchInput(strum);
			});
		}
	}
}

function setStrumLineTransform(_lane:StrumLine, ?_x:Float, ?_y:Float, ?_scale:Float) {
	// hscript-improved considers root function arguments unknown when inside
	// another function inside this one. i hate everything
	var lane = _lane;
	var x = _x ?? FlxG.width * 0.5;
	var y = _y ?? 50;
	var scale = _scale ?? 1;

	var prev = lane.strumScale;
	lane.strumScale = scale;
	var scaleFactor = lane.strumScale / prev;

	lane.forEach((strum) -> {
		strum.x = (strum.ID * Note.swagWidth * lane.strumScale);
		strum.y = 0;
		strum.scale.x *= scaleFactor;
		strum.scale.y *= scaleFactor;
		strum.updateHitbox();
	});

	for (n in lane.notes.members) {
		n.scale.x *= scaleFactor;
		if (n.nextSustain == null)
			n.scale.y *= scaleFactor;
		n.updateHitbox();
	}

	if (FlxG.save.data.holdCovers) {
		for (c in lane.extra.get('holdCovers')) {
			c.scale.x *= scaleFactor;
			c.scale.y *= scaleFactor;
			c.updateHitbox();
		}
	}

	var gw = getGroupWidth(lane) * 0.5;
	var gh = getGroupHeight(lane) * 0.5;
	lane.forEach((strum) -> {
		strum.x -= gw;
		strum.y -= gh;

		strum.x += x;
		strum.y += y;
	});
}

var mercyBorderX = 66;
var mercyBorderY = 266;

function addTouchInput(strum) {
	var input = new FlxObject();
	strum.extra.set('input', input);
	input.scrollFactor = strum.scrollFactor;

	var overlapStatus = false;
	strum.getPressed = (strumLine) -> {
		// trol
		// is it a bad idea to base it on strum texture size?
		var hitbox = (Note.swagWidth * strumLine.strumScale);
		input.setSize(hitbox + (mercyBorderX * 2), hitbox + (mercyBorderY * 2));
		input.x = strum.x + (strum.width - input.width) * 0.5;
		input.y = strum.y + (strum.height - input.height) * 0.5;

		for (i in FlxG.touches.list) {
			if (i.pressed) {
				if (actuallyFuckingOverlaps(i, input, camHUD)) {
					return true;
				}
			}
		}
		return false;
	};
	strum.getJustPressed = (strumLine) -> {
		for (i in FlxG.touches.list) {
			if (actuallyFuckingOverlaps(i, input, camHUD) && (!overlapStatus || i.justPressed && !i.justReleased)) {
				overlapStatus = true;
				return true;
			}
		}
		return false;
	};
	strum.getJustReleased = (strumLine) -> {
		for (i in FlxG.touches.list) {
			if (i.justReleased || !actuallyFuckingOverlaps(i, input, camHUD)) {
				overlapStatus = false;
				return true;
			}
		}
		return false;
	};
}

var ip = FlxPoint.get();
var dump = new FlxObject();

public function actuallyFuckingOverlaps(input, object, camera):Bool {
	var ogz = camera.zoom;
	camera.zoom = 1;
	var screenI = camera.alterScreenPosition(dump, input.getScreenPosition(camera, ip));
	camera.zoom = ogz;
	var res = object.overlapsPoint(ip, false, camera);
	return res;
}

function postUpdate(elapsed) {
	downscroll = true; // el baile del troleo
}
