import haxe.io.Path;
import flixel.tweens.misc.VarTweenProperty;

public var zoomTweens = [null, null];
public var zoomOffsets = [0.0, 0.0];
public var forceDisableZoomUpdate = false;
public var camZooming = false;

function onEvent(e) {
	switch (e.event.name) {
		case 'Add Camera Zoom':
			e.cancel();
			zoomOffsets[e.event.params[1] == "camHUD" ? 1 : 0] += e.event.params[0];
		case 'Camera Bop':
			e.cancel();
			bumpCam(e.event.params[0]);
		case 'Camera Zoom':
			e.cancel();
			var p = e.event.params;

			var def = Std.parseFloat(stage?.stageXML?.get("zoom") ?? '1');
			if (p[1] || p[2])
				def = 1;
			
			var oldZoom = p[2] ? defaultHudZoom : defaultCamZoom;

			if (!p[2]) {
				if (zoomTweens[0] != null) zoomTweens[0].cancel();
				defaultCamZoom = def * p[0];
				if (p[3] == 'Classic')
					zoomOffsets[0] = camGame.zoom - defaultCamZoom;
			} else {
				if (zoomTweens[1] != null) zoomTweens[1].cancel();
				defaultHudZoom = p[0];
				if (p[3] == 'Classic')
					zoomOffsets[1] = camHUD.zoom - defaultHudZoom;
			}

			if (p[3] == 'Instant') {
				zoomOffsets[p[2] ? 1 : 0] = 0.0;
			}

			if (p[3] == 'Tweened') {
				var dcz = {defaultCamZoom: defaultCamZoom}; var dhz = {defaultHudZoom: defaultHudZoom};

				if (!p[2]) defaultCamZoom = oldZoom;
				else defaultHudZoom = oldZoom;

				var zoomTween = zoomTweens[!p[2] ? 0 : 1];
				if (zoomTween != null) zoomTween.cancel();
				zoomTween = FlxTween.tween(PlayState.instance,
					!p[2] ? dcz : dhz,
				p[4] * (Conductor.stepCrochet * 0.001), {
					onComplete: (_) -> { zoomTween = null; },
					ease: CoolUtil.flxeaseFromString(p[5], p[6]),
				});
				zoomTweens[!p[2] ? 0 : 1] = zoomTween; // ensure it works
			}

	}
}

function new() {
	//trace(events[events.length - 1]);
	var name = Path.withoutExtension(__script__.fileName);
	for (e in events) {
		if (e.time <= 10 && e.name == name) {
			executeEvent(e);
			break;
		}
	}
}

function postCreate() {
	zoomOffsets[0] = camGame.zoom - defaultCamZoom;
}

function onNoteHit(e) {
	if (e.enableCamZooming) {
		camZooming = true;
		e.enableCamZooming = false;
	}
}

function doBeatZoom() {
	var beat = Conductor.getBeats(camZoomingEvery, camZoomingInterval, camZoomingOffset);
	if (camZoomingLastBeat != beat) {
		camZoomingLastBeat = beat;
		bumpCam();
	}
}

function bumpCam(?mult) {
	mult ??= 1;
	zoomOffsets[0] += camGameZoomMult * camZoomingStrength * mult;
    zoomOffsets[1] += camHUDZoomMult * camZoomingStrength * mult;
}

function postUpdate(elapsed) {
	if ((inCutscene && !persistentUpdate) || forceDisableZoomUpdate) return;

	if (camZooming) {
		zoomOffsets[0] = lerp(zoomOffsets[0], 0.0, camGameZoomLerp);
		zoomOffsets[1] = lerp(zoomOffsets[1], 0.0, camHUDZoomLerp);

		if (Options.camZoomOnBeat) doBeatZoom();
	}

    var res = defaultCamZoom + zoomOffsets[0];
    camGame.zoom = res;

	res = defaultHudZoom + zoomOffsets[1];
    camHUD.zoom = res;
}