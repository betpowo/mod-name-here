import funkin.menus.ui.effects.WaveEffect;
import flixel.addons.display.FlxBackdrop;

final quotes = CoolUtil.coolTextFile(Paths.file('interfaces/mnh-pause-quotes.txt'));

final effect = new WaveEffect(2, 4, 3);
effect.speed = 0;

final pauseCam = new FlxCamera();

final bg = new FunkinSprite().makeSolid(FlxG.width, FlxG.width, -1);
final bgSwirl = new FunkinSprite().makeSolid(FlxG.width, FlxG.width, -1);
final songColor = CoolUtil.getColorFromDynamic(PlayState.SONG.meta.color ?? '#717171');
var whiteColor = FlxColor.interpolate(songColor, FlxColor.WHITE, 0.9);
var blackColor = FlxColor.interpolate(songColor, FlxColor.BLACK, 0.75);
var split = getRGBArray(blackColor);
blackColor = FlxColor.fromRGB(
	Std.int(Math.max(0.1, Math.min(split[0] * 2 * 0.8, 1)) * 255),
	Std.int(Math.max(0.1, Math.min(split[1] * 2 * 0.5, 1)) * 255),
	Std.int(Math.max(0.1, Math.min(split[2] * 2 * 1.0, 1)) * 255)
, 255);

function getInverted(inp) {
	var out = ((FlxColor.WHITE - inp) & 0xffffff) + (inp & 0xff000000);
	return out;
}
var increaseTime = 4;
var texts = [];
var itemHeight = 80;
var stupidTween;

var gmSong = new CustomShader('gradientMap');
var gmShadow = new CustomShader('gradientMap');
var gmDeselect = new CustomShader('gradientMap');
var gmSelect = new CustomShader('gradientMap');
gmDeselect.mult = 1;
gmSelect.mult = 1;
gmSong.mult = 1;
gmShadow.mult = 1;

gmDeselect.white = getRGBArray(getLuminance(blackColor) < 0.34 ? blackColor : getInverted(blackColor));
gmDeselect.black = getRGBArray(getLuminance(blackColor) < 0.34 ? 0xff000000 : getInverted(whiteColor));

gmShadow.white = gmShadow.black = getRGBArray(getInverted(blackColor));

gmSelect.white = getRGBArray(songColor);
gmSelect.black = getRGBArray(getLuminance(songColor) > 0.7 ? blackColor : whiteColor);

gmSong.white = getRGBArray(blackColor);
gmSong.black = getRGBArray(getLuminance(songColor) < 0.2 ? whiteColor : songColor);

var shadowText = new Alphabet(-999, -999, '', 'silly');
var ____empty = []; var wiggleEffect = [effect];
var backdrops = [];

// this fucking stinks
var songText = new Alphabet(-999, -999, PlayState.SONG.meta.displayName, 'silly');
var songTextShadow = new Alphabet(-999, -999, PlayState.SONG.meta.displayName, 'silly');
songText.shader = gmSong;
songTextShadow.shader = gmShadow;

var blueballsIcon = new FunkinSprite(0, 0, Paths.image('ui/mnh/blueballs-icon'));
var blueballsText = new FunkinText(0, 0, -1, PlayState.deathCounter, 28);
blueballsText.borderSize = 2.5;
blueballsText.borderColor = 0xff6666cc;
blueballsText.color = 0x99ccff;
blueballsText.font = Paths.font('sillyfont.ttf');

var composerText = new FunkinText(0, 0, -1, (PlayState.SONG.meta?.customValues?.composer ?? '???').toLowerCase(), 28);
composerText.borderSize = 2.5;
composerText.borderColor = getLuminance(songColor) > 0.7 ? whiteColor : songColor;
composerText.color = getLuminance(songColor) > 0.7 ? blackColor : whiteColor;
composerText.font = Paths.font('sillyfont.ttf');

var doEndFlash = true;
final flashers = ['Resume', 'Resume Cutscene', 'Skip Cutscene'];

function create(event) {
	event.cancel();
	event.music = 'breakfast-mnh';

	FlxG.cameras.add(pauseCam, false);
	pauseCam.bgColor = 0;
	cameras = [pauseCam];

	bg.zoomFactor = 0;
	bg.scrollFactor.set();
	bg.screenCenter();
	bg.blend = BlendMode.SUBTRACT;
	bg.color = getInverted(blackColor);
	add(bg);

	var offsetX = 0;
	if (!PlayState.coopMode && !FlxG.save.data.middleScroll) {
		offsetX = -0.25 * (PlayState.opponentMode ? -1 : 1);
	}

	bgSwirl.shader = new CustomShader('mainBGSwirl');
	bgSwirl.antialiasing = true;
	bgSwirl.shader.iTime = -increaseTime;
	bgSwirl.shader.offset = [0, 0];
	bgSwirl.zoomFactor = 0;
	bgSwirl.scrollFactor.set();
	bgSwirl.screenCenter();
	bgSwirl.blend = BlendMode.SCREEN;
	bgSwirl.color = blackColor;
	add(bgSwirl);

	var dumpTxt = new FunkinText();
	dumpTxt.font = Paths.font('sillyfont.ttf');
	dumpTxt.borderSize = 0;
	dumpTxt.borderColor = 0x0;
	dumpTxt.size = 40;
	dumpTxt.text = StringTools.replace(FlxG.random.getObject(quotes), '\\n', '\n');
	dumpTxt.drawFrame(true);

	for (i in 0...2) {
		var txt = new FlxBackdrop().makeGraphic(dumpTxt.width, dumpTxt.height, FlxColor.TRANSPARENT);
		txt.y = dumpTxt.height * 1.15 * i;
		txt.spacing.y = dumpTxt.height * 1.3;
		txt.spacing.x = 100;
		txt.stamp(dumpTxt);
		txt.antialiasing = true;
		txt.rotation = offsetX * 20;
		txt.velocity.x = (0.5 - i) * 200;
		txt.alpha = 0;
		txt.blend = BlendMode.SCREEN;
		txt.color = blackColor;
		backdrops.push(txt);
		add(txt);
	}

	dumpTxt.destroy();

	bg.alpha = 0;
	bgSwirl.alpha = 0;

	FlxTween.tween(bg, {alpha: 1}, 0.3, {startDelay: 0.1});
	FlxTween.tween(bgSwirl, {alpha: 0.6}, 0.45);
	stupidTween = FlxTween.num(0, offsetX, 8, {ease: (t) -> { return FlxEase.expoOut(FlxEase.expoOut(t)); }}, (num) -> {
		bgSwirl.shader.offset[0] = num;
	});

	shadowText.shader = gmShadow;
	shadowText.blend = BlendMode.SUBTRACT;
	shadowText.effects = wiggleEffect;
	add(shadowText);
	var startY = (FlxG.height - (itemHeight * menuItems.length)) * 0.5;
	for (i => v in menuItems) {
		var t = new Alphabet(0, 0, translate('pause.'+TranslationUtil.raw2Id(v)).toLowerCase(), 'silly');
		t.scale.set(0.8, 0.8);
		t.updateHitbox();
		t.x = t.textWidth * t.scale.x * -1.3;
		t.y = startY + itemHeight * i;
		texts.push(t);
		t.shader = gmDeselect;
		t.blend = getLuminance(blackColor) < 0.34 ? BlendMode.SCREEN : BlendMode.SUBTRACT;
		add(t);
	}

	songTextShadow.blend = BlendMode.SUBTRACT;
	songTextShadow.effects = wiggleEffect;
	add(songTextShadow);
	add(songText);
	songText.scale.x = songText.scale.y = Math.min(1, 900 / songText.textWidth);
	songText.updateHitbox();
	songTextShadow.scale.copyFrom(songText.scale);
	songTextShadow.updateHitbox();
	songText.x = FlxG.width - songText.width - 60;
	blueballsText.x = FlxG.width - blueballsText.width - 60;
	blueballsIcon.x = blueballsText.x - blueballsIcon.width - 12;
	composerText.x = blueballsIcon.x - composerText.width - 12;

	composerText.antialiasing = blueballsText.antialiasing = true;

	add(blueballsText);
	add(blueballsIcon);
	add(composerText);

	changeSelection(0);
	FlxG.sound.play(Paths.sound('quick-panel/open-tab-click'), Options.volumeSFX);
}

var effectTimer = 0;
var fps = 1 / 3;
var timer = 0;

// just so scrolling extremely fast with mouse doesnt hurt the ears
var stupidTimer = 0;

function update(elapsed) {
	bgSwirl.shader.iTime += elapsed * increaseTime;
	increaseTime = Math.max(increaseTime - elapsed, 1);

	stupidTimer = Math.max(stupidTimer - elapsed * 2, 0);

	if (mobile) {
		// todo
	} else {
		if (controls.DOWN_P)
			changeSelection(1);
		if (controls.UP_P)
			changeSelection(-1);

		if (FlxG.mouse.wheel != 0) {
			changeSelection(-FlxG.mouse.wheel);
		}
	}

	if (!mobile && FlxG.mouse.justPressedRight) {
		close();
		FlxG.sound.play(Paths.sound('quick-panel/close-tab-click'), Options.volumeSFX).persist = true;
	}
	if ((!mobile && controls.ACCEPT || FlxG.mouse.justPressed) || (mobile && (curSelected != -1 && FlxG.mouse.justReleased))) {
		doEndFlash = flashers.contains(menuItems[curSelected]);
		selectOption();
		FlxG.sound.play(Paths.sound('quick-panel/close-tab-click'), Options.volumeSFX).persist = true;
	}

	timer += elapsed;
	effectTimer += elapsed;
	if (effectTimer > fps) {
		effectTimer = 0;
		effect.intensityX = FlxG.random.float(1, 2);
		effect.intensityY = FlxG.random.float(2, 3);
		effect.period = FlxG.random.float(1, 3);
		effect.effectTime += fps;
	}

	for (i in backdrops) {
		i.velocity.x = lerp(i.velocity.x, 5 * FlxMath.signOf(i.velocity.x), 0.03);
		i.alpha = lerp(i.alpha, 0.6, 0.05);
	}

	songText.y = lerp(songText.y, 50 + Math.pow(Math.max(0, 1 - (timer * 1.5)), 2) * 240, 0.1);
	songTextShadow.setPosition(songText.x + Math.cos(timer * 4) * 3, songText.y + 8 + Math.sin(timer * 4) * 3);
	for (i in [blueballsText, blueballsIcon, composerText]) {
		i.y = songText.y + songText.height + 35 - Std.int(i.height * 0.5);
	}

	var startY = (FlxG.height - (itemHeight * menuItems.length)) * 0.5;
	for (i => t in texts) {
		var diff = i - curSelected;
		t.updateHitbox();
		t.x = lerp(t.x, 60 + (diff == 0 ? (20 + Math.cos(timer * 2) * 3) : 0) + Math.pow(Math.max(0, 1 - (timer * 2)), 2) * 150, 0.15);
		t.y = lerp(t.y, (
			(diff == 0) ? (Math.sin(timer * 2) * 3) : 0
		) + startY + (itemHeight * i) + (itemHeight - t.height) * 0.5, 0.2);
	}
	if (curText != null) {
		if (shadowText.text != curText.text) {
			shadowText.text = curText.text;
		}
		shadowText.setPosition(curText.x + 5, curText.y + 9);
		shadowText.scale.set(curText.scale.x, curText.scale.y);
		shadowText.updateHitbox();
	}
}

var curText:Alphabet;
var scrollSound = FlxG.sound.load(Paths.sound('quick-panel/menu-scroll'), Options.volumeSFX);
function changeSelection(change) {
	curSelected = FlxMath.wrap(curSelected + change, 0, menuItems.length - 1);

	if (curText != null) {
		FlxTween.cancelTweensOf(curText.scale);
		FlxTween.tween(curText.scale, {x: 0.8, y: 0.8}, 0.6, {ease: FlxEase.elasticOut});
		curText.shader = gmDeselect;
		curText.blend = getLuminance(blackColor) < 0.34 ? BlendMode.SCREEN : BlendMode.SUBTRACT;
		curText.effects = ____empty;
	}
	curText = texts[curSelected];
	if (curText != null) {
		remove(curText, true);
		FlxTween.cancelTweensOf(curText.scale);
		FlxTween.tween(curText.scale, {x: 0.9, y: 0.9}, 0.4, {ease: FlxEase.elasticOut});
		curText.shader = gmSelect;
		curText.blend = BlendMode.NORMAL;
		curText.effects = wiggleEffect;
		add(curText);
	}

	if (change != 0) {
		scrollSound.pitch = FlxG.random.float(0.95, 1.05);
		scrollSound.play(true, Math.floor(stupidTimer * 18));
		scrollSound.volume = 0.85 * Options.volumeSFX + Math.min(stupidTimer * 0.7, 0.3);
		stupidTimer = Math.min(stupidTimer + 0.4, 1);
	}
}

function destroy() {
	stupidTween.cancel();
	if (doEndFlash) {
		var fadeSprite = new FunkinSprite();
		fadeSprite.zoomFactor = 0;
		fadeSprite.scrollFactor.set();
		fadeSprite.makeSolid(FlxG.width, FlxG.height, -1, true);
		fadeSprite.updateHitbox();
		fadeSprite.blend = BlendMode.SUBTRACT;
		fadeSprite.color = getInverted(blackColor);
		fadeSprite.alpha = bg.alpha;
		PlayState.instance.add(fadeSprite);
		forceTween().tween(fadeSprite, {alpha: 0}, 0.15, {
			// crazy
			onUpdate: (_) -> {
				if (PlayState.instance.members[PlayState.instance.members.length - 1] != fadeSprite) {
					PlayState.instance.remove(fadeSprite, true);
					PlayState.instance.add(fadeSprite);
					//trace('hi guys');
				}
			},
			onComplete: (_) -> {
				_.cancel();
				
				PlayState.instance.remove(fadeSprite, true);
				fadeSprite.destroy();
			}
		});
	}
}
