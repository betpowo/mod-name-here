import flixel.effects.FlxFlicker;
import funkin.backend.system.macros.GitCommitMacro;
import funkin.backend.week.Week;
import funkin.menus.credits.CreditsMain;
import funkin.options.OptionsMenu;
import flixel.text.FlxTextBorderStyle;
import funkin.editors.EditorPicker;
import funkin.menus.ModSwitchMenu;
import flixel.FlxObject;
import openfl.display.BitmapData;
import funkin.savedata.FunkinSave;
import funkin.backend.system.Flags;
import funkin.backend.system.Control;

var camFollow = new FlxObject(0, 0, 0, 0);

var items = [
	{
		id: 'story',
		x: -290,
		y: -105,
		titleX: 20,
		colors: [0xff6633, 0xffcc99]
	},
	{
		id: 'options',
		x: 183,
		y: -217,
		titleX: -50,
		titleY: -35,
		colors: [0x6699cc, 0x99ccff]
	},
	{
		id: 'freeplay',
		x: 265,
		y: -25,
		titleX: 140,
		titleY: -50,
		colors: [0x99ffcc, 0xffffcc]
	},
	{
		id: 'credits',
		x: 275,
		y: 290,
		titleX: -390,
		titleY: 0,
		colors: [0x6600ff, 0xff66ff]
	}
];

if (mobile) {
	items.push({
		id: 'back',
		x: -420,
		y: 196,
		titleX: -25,
		titleY: -10,
		colors: [0x990033, 0xff6699]
	});
}
var buttons = [];
var bg = new FunkinSprite();
var devModeWarning = new FunkinText();
function create() {
	FlxG.camera.bgColor = 0xFF003366;
	CoolUtil.playMenuSong();
	FlxG.mouse.visible = true;

	bg.makeSolid(FlxG.camera.width, FlxG.camera.width, 0xffffff);
	add(bg);

	// https://www.shadertoy.com/view/4st3WX ; comment by coyote on 2016-01-15
	bg.shader = new FunkinShader('
	#pragma header
	uniform float iTime;
	void main()
	{
		vec2 uv = openfl_TextureCoordv;
		vec2 U = uv;
		vec4 f = openfl_TextureSize.xyxy;
		f = length(U += U - f.xy) / f;
		f = vec4(sin(6.0 / f + atan(U.x, U.y) * 4.0 - iTime).w < 0.0);
		f *= sin(2.0 * length(U) - 0.1);

		float col = f.r / f.a;
		gl_FragColor = applyFlixelEffects(vec4(col, col, col, 1.0) * f.a);
	}
	');
	bg.antialiasing = true;
	bg.shader.iTime = 0;
	bg.zoomFactor = 0;
	bg.scrollFactor.set();
	bg.shader.whRemap = [bg.width, bg.height];
	bg.screenCenter();
	bg.blend = 0;

	var meme = new FunkinSprite();
	meme.loadSprite(FlxG.random.getObject(Paths.getFolderContent('images/menus/mainmenu/memes/', true)));
	meme.setGraphicSize(245, 90);
	meme.updateHitbox();
	meme.screenCenter();
	meme.x += -420;
	meme.y += 145;
	add(meme);
	var ver = new FunkinText();
	ver.size = 18;
	ver.text = [
		'mnh v' + version,
		'codename v' + Flags.VERSION,
		'[' + controls.getKeyName(Control.SWITCHMOD).toLowerCase() + '] to switch mods,',
		'but why would you?'
	].join('\n');
	ver.font = Paths.font('sillyfont.ttf');
	ver._defaultFormat.leading = -4;
	ver.updateDefaultFormat();
	add(ver);
	ver.fieldWidth = 300;
	ver.alignment = 'right';
	ver.screenCenter();
	ver.x += -444;
	ver.y += 250;

	camFollow.screenCenter();
	camera.follow(camFollow, null, 0.04);

	var col = FlxG.camera.bgColor;
	var whiteColor = [red(col) / 255, green(col) / 255, blue(col) / 255];
	var blackColor = whiteColor.copy();

	for (w in 0...whiteColor.length) {
		whiteColor[w] *= 1.75;
	}

	for (w in 0...blackColor.length) {
		blackColor[w] *= 0.66666666;
	}

	blackColor[0] *= 0.75;
	blackColor[1] *= 0.5;

	whiteColor.push(1);
	blackColor.push(1);

	for (i => b in [
		FunkinSave.getWeekHighscore('weekidk', 'normal').score > 0, // week idk beaten
		false, // all story mode beaten (no other weeks yet so make it false for now lol!!)
		false, // all extra songs (same reason as above, but for extra songs instead)
		false // true ending . you can already see why its false
	]
	) {
		var star = new FunkinSprite();
		star.antialiasing = true;
		star.loadSprite(Paths.image('menus/mainmenu/assets'));
		star.addAnim('idle', 'star', 12, true, true, [(i % 2) + (b ? 2 : 0)]);
		star.playAnim('idle');
		star.updateHitbox();
		star.screenCenter();
		add(star);

		star.x += 440 - (Math.floor(i / 2) * 4) + ((i % 2) * star.width * 1.05);
		star.y += -270 + ((Math.floor(i / 2) * star.height)) + ((i % 2) * star.height * 0.25);
	}

	for (k => i in items) {
		var test = new MNHMenuItem(0, 0, null, i.id);
		add(test);
		test.centerToScreen();

		test.gm.black = blackColor;
		test.gm.white = whiteColor;

		test.x += i.x ?? 0;
		test.y += i.y ?? 0;
		test.bgShader.top = [red(i.colors[0]) / 255, green(i.colors[0]) / 255, blue(i.colors[0]) / 255, 1];
		test.bgShader.bottom = [red(i.colors[1]) / 255, green(i.colors[1]) / 255, blue(i.colors[1]) / 255, 1];

		test.titleSprite.x = test.x + (test.width - test.titleSprite.width) * 0.5;
		test.titleSprite.y = test.y + 20;

		test.titleSprite.x += i.titleX ?? 0;
		test.titleSprite.y += i.titleY ?? 0;

		test.mobile = mobile;

		test.ID = k;
		test.onClick = () -> {
			curSelected = test.ID;
			selectItem(i.id);
		}

		buttons.push(test);
	}

	ver.color = FlxColor.fromRGBFloat(whiteColor[0] * 2, whiteColor[1] * 3, whiteColor[2] * 3);
	ver.antialiasing = meme.antialiasing = true;
	ver.borderColor = FlxColor.fromRGBFloat(blackColor[0] * 0.5, blackColor[1] * 0.5, blackColor[2] * 0.5);

	bg.color = FlxColor.fromRGBFloat(whiteColor[0] * 0.5, whiteColor[1] * 0.5, whiteColor[2] * 0.5);
	bg.alpha = 0.4;

	devModeWarning.setPosition(0, FlxG.height - 80);
	devModeWarning.fieldWidth = 1280;
	devModeWarning.text = 'you have to enable DEVELOPER MODE in the miscellaneous settings!';
	devModeWarning.size = 24;
	devModeWarning.alignment = 'center';
	devModeWarning.alpha = 0;
	devModeWarning.font = Paths.font('sillyfont.ttf');
	devModeWarning.antialiasing = true;
	devModeWarning.borderSize = 4;
	devModeWarning.borderColor = 0xff3f0048;
	add(devModeWarning);
}

public function red(col) {
	return (col >> 16) & 0xff;
}

public function green(col) {
	return (col >> 8) & 0xff;
}

public function blue(col) {
	return (col & 0xff);
}

var chosen = false;

// controls.DEV_ACCESS will only become true if pressing the key AND devmode is on .
// i dont want it to be devmode only so use this workaround
function getDevAccessKeys() {
	var res = [];
	for (i in controls.getActionFromControl(Control.DEV_ACCESS).inputs) {
		res.push(i.inputID);
	}
	return res;
}
var devModeCount:Int = 0;
function update(elapsed) {
	FlxG.sound.music.volume = Math.min(FlxG.sound.music.volume + (elapsed), 1);

	camFollow.setPosition((camera.width * 0.5) + ((FlxG.mouse.x - (camera.width * 0.5)) * 0.01),
		(camera.height * 0.5) + ((FlxG.mouse.y - (camera.height * 0.5)) * 0.01));

	if (controls.BACK)
		FlxG.switchState(new TitleState());

	if (FlxG.keys.anyJustPressed(getDevAccessKeys())) {
		if (Options.devMode) {
			persistentUpdate = false;
			persistentDraw = true;
			openSubState(new EditorPicker());
		} else {
			FlxG.sound.play(Paths.sound(Flags.DEFAULT_EDITOR_DELETE_SOUND));
			if (devModeCount++ == 2) {
				FlxTween.tween(devModeWarning, {alpha: 1}, 0.4);
			}
			FlxTween.completeTweensOf(devModeWarning);
			FlxTween.color(devModeWarning, 0.2, 0xFFFF3366, 0xFFffffcc);
			FlxTween.shake(devModeWarning, 0.005, 0.3);
			devModeWarning.y = FlxG.height - 75;
			FlxTween.tween(devModeWarning, {y: FlxG.height - 50}, 0.4);
		}
	}
	if (controls.SWITCHMOD) {
		openSubState(new ModSubState('mnh/ModSwitch'));
		persistentUpdate = false;
		persistentDraw = true;
	}

	bg.shader.iTime += elapsed;
}

function changeSelection(ch) {
	unselectedFormat(texts[curSelected]);
	curSelected = FlxMath.wrap(curSelected + ch, 0, options.length - 1);
	selectedFormat(texts[curSelected]);

	CoolUtil.playMenuSFX(0, 0.7);
}

function unselectedFormat(t) {
	t.color = 0xffffff;
	t.shadowOffset.set(0, 0);
}

function selectedFormat(t) {
	t.color = 0xffff00;
	t.shadowOffset.set(t.size / 8, t.size / 8);
}

function selectItem(i) {
	chosen = true;
	var choice = i;

	switch (choice) {
		case 'back':
			FlxG.switchState(new ModSubState('mnh/ModSwitch'));
			return;
	}

	FlxTween.tween(camera, {zoom: 0.94}, 1, {ease: FlxEase.expoOut});
	CoolUtil.playMenuSFX(1, 0.7);

	for (k => i in buttons) {
		i.enableOverlapCheck = false;
		if (k == curSelected) {
			i.moves = true;

			i.velocity.set(FlxG.random.float(-1, 1) * 200, -250 - FlxG.random.float(0, 50));
			i.acceleration.y = FlxG.random.float(0.5, 1) * 1200;

			i.titleSprite.velocity.set(i.velocity.x, i.velocity.y);
			i.titleSprite.acceleration.set(i.acceleration.x, i.acceleration.y);

			i.titleSprite.moves = true;

			if (Options.flashingMenu) {
				for (j in [i, i.titleSprite, i.bg]) {
					FlxFlicker.flicker(j, 1.1, 0.05, false);
				}
			}
		} else {
			for (j in [i, i.titleSprite, i.bg]) {
				FlxTween.tween(j, {alpha: 0.0}, 0.4, {
					ease: FlxEase.sineIn,
					onComplete: (_) -> {
						j.visible = false;
					}
				});
			}
		}
	}

	switch (choice) {
		case 'story':
			FlxTween.tween(FlxG.sound.music, {pitch: 0}, 0.4, {ease: FlxEase.expoOut});
	}

	new FlxTimer().start(1.3, (_) -> {
		switch (choice) {
			case 'story':
				var week = Week.loadWeek('weekidk', false);
				PlayState.loadWeek(week, 'normal');
				FlxG.switchState(new PlayState());
			case 'freeplay':
				FlxG.switchState(new FreeplayState());
			case 'options':
				FlxG.switchState(new OptionsMenu());
			case 'credits':
				FlxG.switchState(new CreditsMain());
		}
	});
}

class MNHMenuItem extends funkin.backend.FunkinSprite {
	public var titleSprite:FunkinSprite;
	public var bg:FunkinSprite;

	public var onClick:Void->Void;
	public var gm:CustomShader;
	public var bgShader:FunkinShader;
	public var bgUV = null;

	public var enableOverlapCheck:Bool = true;

	// bandaid fix
	public var mobile = false;

	public function new(blehx, blehy, blehgraph, sprite) {
		super();
		var asset = Paths.image('menus/mainmenu/assets');
		antialiasing = true;

		loadSprite(asset);
		addAnim('off', sprite + '0', 12, true, true, [0]);
		addAnim('on', sprite + '0', 12, true, true, [2]);
		playAnim('off');

		updateHitbox();
		_updateHitbox();

		titleSprite = new FunkinSprite();
		titleSprite.antialiasing = true;
		titleSprite.loadSprite(asset);
		titleSprite.addAnim('off', sprite + '-title', 12, true, true, [0]);
		titleSprite.addAnim('on', sprite + '-title', 12, true, true, [1, 2]);
		titleSprite.playAnim('off');
		titleSprite.updateHitbox();

		bg = new FunkinSprite();
		bg.antialiasing = true;
		bg.loadSprite(asset);
		bg.addAnim('bg-mask', sprite + '0', 12, true, true, [1]);
		bg.addAnim('bg', sprite + '0', 12, true, true, [3]);
		bg.playAnim('bg-mask');
		bg.updateHitbox();

		gm = new CustomShader('gradientMap');
		gm.black = [0, 0, 0, 1];
		gm.white = [1, 1, 1, 1];
		gm.mult = 1;
		shader = titleSprite.shader = gm;

		bgShader = new FunkinShader('
		#pragma header
		uniform vec3 top;
		uniform vec3 bottom;
		uniform float texOffset;
		uniform vec4 bgUV;
		uniform vec2 texSize;
		void main() {
			vec2 uv = getCamPos(openfl_TextureCoordv);
			vec4 col = textureCam(bitmap, uv);

			gl_FragColor = vec4(mix(top.rgb, bottom.rgb, uv.y), 1.0) * col.a;

			float ratio = _camSize.z / texSize.x;

			vec2 resUV = vec2(
				mix(bgUV.x, bgUV.x + bgUV.z, fract((texOffset / bgUV.z) + (uv.x * ratio))),
				mix(bgUV.y, bgUV.y + bgUV.w, uv.y)
			);
			vec4 tex = flixel_texture2D(bitmap, resUV);
			float al = tex.a;
			if (al <= 0.0) tex = vec4(0.0, 0.0, 0.0, 0.0);
			else tex = vec4(tex.r / al, tex.g / al, tex.b / al, 1.0);
			
			gl_FragColor = vec4(mix(gl_FragColor.rgb, tex.rgb, al).rgb, 1.0) * gl_FragColor.aaaa;
		}
		');
		bgShader.top = [0.0, 0.0, 0.0];
		bgShader.bottom = [1.0, 1.0, 1.0];
		bgShader.texOffset = 0;

		bg.shader = bgShader;

		bg.playAnim('bg');

		bgShader.bgUV = [
			bg.frame.frame.x / bg.graphic.width,
			bg.frame.frame.y / bg.graphic.height,
			bg.frame.frame.width / bg.graphic.width,
			bg.frame.frame.height / bg.graphic.height
		];
		bgShader.texSize = [bg.frame.frame.width, bg.frame.frame.height];

		/*trace(sprite);
			trace(bgShader.bgUV); */

		bg.playAnim('bg-mask');

		bg.offset = titleSprite.offset = offset;
		bg.frameOffset = titleSprite.frameOffset = frameOffset;
		titleSprite.setPosition(x, y);
	}

	public var overlapped:Bool = false;
	public var extraOffsets:FlxPoint = FlxPoint.get(0, 0);

	public override function update(elapsed:Float) {
		super.update(elapsed);

		bg.update(elapsed);
		bg.shader.texOffset += (elapsed * 0.05);
		bg.setPosition(x, y);

		var pressed = FlxG.mouse.justPressed;
		if (mobile) {
			for (touch in FlxG.touches.list) {
				if (touch.justReleased) {
					pressed = true;
				}
			}
		}

		if (enableOverlapCheck) {
			if (overlapped != (overlapped = FlxG.mouse.overlaps(this))) {
				updateToggle();
			}

			if (overlapped) {
				if (pressed || FlxG.state.controls.ACCEPT)
					onClick();
			}
		}

		elapsedTime += elapsed;

		offset.x = FlxMath.lerp(offset.x, extraOffsets.x + (overlapped ? 7 : 0), 12 * elapsed);
		offset.y = FlxMath.lerp(offset.y, extraOffsets.y + (overlapped ? 15 : 0), 12 * elapsed);

		titleSprite.update(elapsed);
	}

	public var elapsedTime:Float = 0.0;

	public function updateToggle() {
		var ani = overlapped ? 'on' : 'off';
		playAnim(ani);
		titleSprite.playAnim(ani);
		gm.mult = overlapped ? 0 : 1;

		if (overlapped) {
			CoolUtil.playMenuSFX(0, 0.7);
		}
	}

	public override function draw() {
		var ogx = offset.x;
		var ogy = offset.y;
		var oganim = animation.name;
		var ogalpha = alpha;

		playAnim('off');
		offset.set(extraOffsets.x, extraOffsets.y);
		colorTransform.color = FlxColor.fromHSB(elapsedTime * 180, 0.3, 1);
		super.draw();

		offset.set(ogx, ogy);
		if (overlapped)
			bg.draw();

		playAnim(oganim);
		setColorTransform();
		alpha = ogalpha;
		super.draw();

		titleSprite.draw();
	}

	public function centerToScreen() {
		x = (FlxG.width - frame.frame.width) * 0.5;
		y = (FlxG.height - frame.frame.height) * 0.5;
	}

	public function _updateHitbox() {
		width = frame.frame.width * scale.x;
		height = frame.frame.height * scale.y;
		extraOffsets.set(frame.offset.x, frame.offset.y);
		offset.set(extraOffsets.x, extraOffsets.y);
	}
}
