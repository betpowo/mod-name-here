import funkin.backend.scripting.EventManager;
import funkin.backend.scripting.events.CamMoveEvent;
import funkin.editors.charter.Charter;
import haxe.io.Path;

var p = [];
var curOffset = [0, 0];
var scheduleSnap = false;
public var snappedCamera = true;
var tweened = false;
var stepTimer = -1;
var ease = FlxEase.linear;

function onEvent(e) {
	switch (e.event.name) {
		case 'Camera Position':
			var _ = e.event.params;
			var result = [
				(_[6] ? curCameraTarget : -2),
				!_[6],
				_[0] + (_[6] ? curOffset[0] : 0),
				_[1] + (_[6] ? curOffset[1] : 0),
				{
					var res = 'Classic';
					if (!_[2]) res = 'Instant';
					if (_[4] != 'CLASSIC') res = 'Tweened';
					res;
				},
				_[3],
				_[4],
				_[5]
			];
			e.cancel();
			doThingy(result, e.event.time);

		case 'Camera Movement':
			e.cancel();
			doThingy(e.event.params, e.event.time);
	}
}

function doThingy(h, t) {
	p = h;
	curCameraTarget = p[0];
	if (p[1]) {
		// -2 cus i wanna make it so that
		// -1 does not update positions at all
		curCameraTarget = -2;
	}
	curOffset[0] = p[2];
	curOffset[1] = p[3];
	if (snappedCamera = (p[4] == 'Instant')) {
		scheduleSnap = true;
	}
	stepTimer = 0;
	postUpdate(-999); // Oh my god bruh
	if (p[4] == 'Tweened') {
		tweened = true; // ???
		stepTimer = p[5];
	}
	ease = CoolUtil.flxeaseFromString(p[6], p[7]);
	if (tweened) {
		resetPos = true;
	} else {
		lastFollowEnable = camGame.followEnabled;
	}
	if (PlayState.chartingMode && Charter.startHere && tweened) {
		if (t < Charter.startTime) {
			snappedCamera = scheduleSnap = true;
			tweened = false;
			return;
		}
	}
}

function new() {
	// trace(events[events.length - 1]);
	var name = Path.withoutExtension(__script__.fileName);
	for (e in events) {
		if (e.time <= 10 && e.name == name) {
			executeEvent(e);
			break;
		}
	}
}

function postCreate() {
	lastFollowEnable = camGame.followEnabled;
}

function update(elapsed) {
	if (inCutscene)
		return;
	if (curCameraTarget < -1) {
		var data = getStrumlineCamPos(0);
		data.pos.set(0, 0);
		data.amount = 0;
		onCameraMove(EventManager.get(CamMoveEvent).recycle(data.pos, null, data.amount));
		data.put();
	}
}

var lastLerpedPoint = FlxPoint.get(0, 0);
var lastFollowEnable = null;
var resetPos = false;
var awesomeEvent = null;

function onCameraMove(e) {
	awesomeEvent = e;

	e.position.x += curOffset[0];
	e.position.y += curOffset[1];

	if (tweened) {
		if (resetPos) {
			resetPos = false;
			lastLerpedPoint.set(camGame.scroll.x + (camGame.width * 0.5), camGame.scroll.y + (camGame.height * 0.5));
		}

		var g = lastLerpedPoint;
		var c = e.position; // lazy;
		var l = FlxMath.bound(1 - (stepTimer / p[5]), 0, 1); // normalize val
		l = ease(l);

		c.set(FlxMath.lerp(g.x, c.x, l), FlxMath.lerp(g.y, c.y, l));
		camGame.focusOn(c);
		camGame.followEnabled = false;
	}

	camFollow.setPosition(e.position.x, e.position.y);

	if (scheduleSnap && camGame.target != null) {
		camGame.snapToTarget();
		scheduleSnap = false;
	}

	scripts.event('postCameraMove', awesomeEvent);

	//trace(tweened);trace(e.position);

	e.cancel();
}

function postUpdate(elapsed) {
	if (tweened) {
		if (stepTimer > 0)
			if (tweened) {
				stepTimer -= (elapsed / (Conductor.stepCrochet * 0.001));
			} else {
				stepTimer = 0;
			}
		else {
			tweened = false;
			stepTimer = -1;
			camGame.followEnabled = lastFollowEnable;
			if (awesomeEvent != null) scripts.event('onCamTweenFinished', awesomeEvent);

			//trace('im old !');
		}
	}

	// dad.setPosition(Math.cos(curBeatFloat * Math.PI) * 69, Math.sin(curBeatFloat * Math.PI) * 420);
}
