import openfl.display.BlendMode;

var overlay:FlxSprite;
var hudStuff = ['testBar', 'rankTxt', 'accBar', 'accBG'];
var hud;
var ogZoom:Float;
var stageSprites = [];
var flash:FlxSprite;

disableScript(); // </3
function postCreate() {
	camGame.bgColor = 0xFFfccfdd;
	ogZoom = defaultCamZoom;

	overlay = new FlxSprite(-200, -200).makeSolid(FlxG.width * 2, FlxG.height * 2, -1);
	overlay.scrollFactor.set(0, 0);
	overlay.blend = BlendMode.MULTIPLY;
	add(overlay);

	for (i in [boyfriend, dad]) {
		i.setColorTransform(0, 0, 0, 1, 255, 51, 102);
	}
	gf.alpha = 0;

	for (i in stage.stageSprites) {
		i.alpha = 0.001;
	}

	for (strumline in strumLines) {
		for (strum in strumline) {
			strum.visible = false;
			// idk if i want this anymore - betty
			// strum.setColorTransform(-1,-1,-1,1,255,255,255);
		}
	}

	flash = new FlxSprite().makeSolid(FlxG.width, FlxG.height, FlxColor.WHITE);
	insert(0, flash);
	flash.camera = camHUD;
	flash.alpha = 0;

	// Why is it assets  - betty

	// because assets always gets replaced into the mod folder's name - hifish
	hud = scripts.getByPath('assets/interfaces/mnh/hx');
}

function onSongStart() {
	defaultCamZoom = 1.2;
}

function stepHit() {
	if (curStep >= 60)
		appear(1);
	if (curStep >= 62)
		appear(2);

	switch (curStep) {
		case 104:
			defaultCamZoom = ogZoom;
		case 128:
			defaultCamZoom = ogZoom * 1.1;
			camGame.bgColor = 0xFF330033;
			for (i in [boyfriend, dad]) {
				var ass = 300;
				var butt = 80;
				i.setColorTransform(-ass, -ass, -ass, 1, ass * butt, butt * (ass / (butt / 2)), ass * butt);
				i.blend = BlendMode.LIGHTEN;
			}
		case 380:
			camGame.bgColor = 0;
			defaultCamZoom = 1.2;
			for (i in [dad, boyfriend]) {
				i.alpha = 0.1;
				FlxTween.tween(i, {alpha: 1}, Conductor.crochet / 1000, {ease: FlxEase.circIn});
			}
		case 384:
			for (i in stage.stageSprites) {
				i.alpha = 1;
			}
			for (i in [boyfriend, dad]) {
				i.setColorTransform();
				i.blend = BlendMode.NORMAL;
			}
			FlxTween.tween(gf, {alpha: 1}, Conductor.crochet / 1000, {ease: FlxEase.quintOut});
			camGame.bgColor = -1;
			defaultCamZoom = ogZoom;
			coolFlash();
		case 576:
			snap = true;
			defaultCamZoom = camGame.zoom = 1.2;
		case 592:
			snap = false;
			defaultCamZoom = ogZoom;
		case 768:
			camGame.bgColor = 0;
			if (stage.getSprite('bg') != null) {
				stage.getSprite('bg').color = 0xFF2b2330;
			}
			stage.getSprite('ground').color = 0xFF2b2330;
			stage.getSprite('walls').color = 0xFF695678;
			for (i in [dad, boyfriend, gf]) {
				i.color = 0xFF695678;
			}
			snap = true;
			new FlxTimer().start(0.05, () -> {
				snap = false;
			}); // Dont Question Pls -hifish
			coolFlash(Conductor.crochet / 1000 * 2);
		case 1024 | 1280:
			defaultCamZoom = ogZoom;
		case 1008 | 1264:
			defaultCamZoom = 1;
	}
}

var cur_appear:Int = 0;

function appear(v:Int) {
	if (v == cur_appear)
		return;

	if (v == 1) {
		for (strumline in strumLines) {
			for (strum in strumline) {
				strum.visible = true;
			}
		}
	}
	if (v == 2) {
		hud.get('icons')[0].visible = true;
		hud.get('icons')[1].visible = true;

		hud.get('testBar').forEach((e) -> {
			e.visible = true;
		});
		hud.get('accBar').forEach((e) -> {
			e.visible = true;
		});
		hud.get('accBG').visible = true;

		hud.get('scoreBG').visible = true;

		for (i in ['score', 'misses', 'accuracy', 'rank']) {
			hud.get(i + 'Txt').visible = true;
		}
	}
	cur_appear = v;
}

function coolFlash(?time:Float, ?divide:Int) { // how retro
	time ??= Conductor.crochet / 1000;
	divide ??= 4;

	flash.alpha = 1;

	// trace('flash');

	var timer = new FlxTimer();
	timer.start(time / divide, () -> {
		flash.alpha -= 1 / divide;
	}, divide);
}

// setting stuf in post create wont work due to script loading order (?) - betty
var passed:Bool = false;
var time:Float = 0;
var snap:Bool = false;

function update(elapsed:Float) {
	// Fuck my gay stupid chud life
	FlxG.camera.zoom = lerp(FlxG.camera.zoom, defaultCamZoom, camGameZoomLerp);
	camHUD.zoom = lerp(camHUD.zoom, defaultHudZoom, camHUDZoomLerp);

	if (snap)
		camGame.snapToTarget();

	time = Conductor.songPosition * 0.001;
	if (time < 0)
		time = 0;

	if (!passed) {
		passed = true;

		hud.get('icons')[0].visible = false;
		hud.get('icons')[1].visible = false;

		hud.get('testBar').forEach((e) -> {
			e.visible = false;
		});
		hud.get('accBar').forEach((e) -> {
			e.visible = false;
		});
		hud.get('accBG').visible = false;

		hud.get('scoreBG').visible = false;

		for (i in ['score', 'misses', 'accuracy', 'rank']) {
			hud.get(i + 'Txt').visible = false;
		}
	}

	if (overlay.color != -1)
		overlay.color = FlxColor.fromRGBFloat(time * 0.24, time * 0.13, time * 0.22);
}

function onPostCountdown(e) {
	new FlxTimer().start(FlxG.elapsed, (_) -> {
		var spri = hud.get('prevSprite');
		if (spri != null)
			spri.setColorTransform(-1, -1, -1, spri.alpha, 255, 255, 255);
	});
}
