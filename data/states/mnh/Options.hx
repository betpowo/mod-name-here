import funkin.options.OptionsMenu;
import funkin.options.type.TextOption;
import funkin.options.type.ArrayOption;
import funkin.options.type.Separator;
import flixel.FlxObject;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import CustomTreeScreen;
import FlxSoundFilter;
 
/*
	TreeMenu stuff
 */
var tree:Array<CustomTreeScreen> = [];
var treeLength:Int = 0;
var previousMenus:Array<CustomTreeScreen> = [];
var destroyMenus:Bool = true;
var __treeCreated:Bool = false;
/*
	TreeMenu stuff end
 */
var canSelect = true;
var menuGroup = new FlxSpriteGroup();
var camFollow = new FlxObject(0, 0, 0, 0);

function minX(group) {
	var minX = null;
	for (member in group.members) {
		if (member == null)
			continue;

		minX ??= member.x;
		minX = Math.min(minX, member.x);
	}
	return minX - group.x;
}

function addMenu(menu:CustomTreeScreen):CustomTreeScreen {
	if (menu == null)
		return null;
	if (tree.indexOf(menu) != -1)
		return menu;

	tree.push(menu);
	treeLength++;

	var prev = tree[treeLength - 2];
	menu.x = (prev == null ? 0 : (prev.x + prev.curOption.width + 50));

	destroyPreviousMenus();
	menuChanged();
	menu.inputEnabled = true;
	if (prev != null)
		prev.inputEnabled = false;

	menu.playSound = false;
	menu.onChangeSelection.add(() -> {
		penisText.text = menu.curOption.desc;
		CoolUtil.playMenuSFX(0).pitch = FlxG.random.float(0.95, 1.05);
		if (FlxG.sound.music != null && FlxG.sound.music.playing) {
			trackedBeat = Math.floor(Conductor.getStepForTime(FlxG.sound.music.time) / Conductor.stepsPerBeat);
			trackedHonestBeat = Conductor.curBeat;
		}
	});

	menu.changeSelection(0, true);
	menu.onClose.add(() -> {
		removeMenu(menu);
		if (treeLength > 0)
			penisText.text = tree[treeLength - 1].curOption.desc;
	});

	setupSillyTree(menu);
	menuGroup.add(menu);

	return menu;
}

function destroyPreviousMenus() {
	for (menu in previousMenus)
		menu.destroy();
	previousMenus.resize(0);
}

function menuChanged() {
	if (treeLength == 0)
		exit();
	else {
		for (menu in tree)
			if (menu != null)
				menu.transitioning = true;
		CoolUtil.last(tree).transitioning = false;
	}

	for (menu in previousMenus)
		if (menu != null)
			menu.transitioning = true;
}

function popMenu():CustomTreeScreen
	return removeMenuPosition(treeLength - 1);

function removeMenu(menu:CustomTreeScreen):CustomTreeScreen
	return if (menu == null) null; else removeMenuPosition(tree.indexOf(menu));

function removeMenuPosition(position:Int):CustomTreeScreen {
	if (position < 0 || position >= treeLength || treeLength == 0)
		return null;

	tree[position] = tree[tree.length - 1];
	var menu = tree.pop();

	previousMenus.push(menu);
	if (position == --treeLength) {
		menuChanged();
		menu.inputEnabled = false;
		if (treeLength > 0)
			tree[treeLength - 1].inputEnabled = true;
	} else {}

	return menu;
}

/////////////////////////////////////////
function col2rgba(col) {
	var is24Bit = (col & 0xffffff) == col;
	return [
		((col >> 16) & 0xff) / 255,
		((col >> 8) & 0xff) / 255,
		((col >> 0) & 0xff) / 255,
		is24Bit ? 1 : ((col >> 0) & 0xff) / 255
	];
}

function setupText(t) {
	if (t == null)
		return;
	var MAX_TITLE_WIDTH = FlxG.width * 0.7;
	if ((t.textWidth * t.scale.x) > MAX_TITLE_WIDTH) {
		t.scale.x = t.scale.y = MAX_TITLE_WIDTH / t.textWidth;
		t.updateHitbox();
	}
	t.origin.set(0, t.height * 0.5);
	t.offset.x += ((t.textWidth * t.scale.x) - t.textWidth) * 0.5;
	t.offset.y += ((t.textHeight * t.scale.y) - t.textHeight) * 0.5;
}

var gm_enabled = new CustomShader('gradientMap');

gm_enabled.black = col2rgba(0x993366);
gm_enabled.white = col2rgba(0xfff1f7);
gm_enabled.mult = 1;
function setupSillyTree(menu) {
	menu.forEach((a) -> {
		if (a is Separator)
			return;
		a.camera = awesomeCam;
		a.itemHeight = 100;
		var gm = new CustomShader('gradientMap');
		var color_black = col2rgba(0x000099);
		var color_white = col2rgba(0xefffff);
		gm.mult = 1;
		a.__text.shader = gm;
		a.__text.font = 'silly';
		setupText(a.__text);

		var trackedSelectState = 0;
		var targetScale = a.__text.scale.x;
		var trackedScale = targetScale;
		var extra = [];

		import funkin.menus.ui.effects.WaveEffect;
		var effect = new WaveEffect(0, 0, 6);
		effect.speed = 7;
		a.__text.effects.push(effect);

		var typeString = CoolUtil.last(Type.getClassName(Type.getClass(a)).split('.'));
		// trace(typeString);

		switch (typeString) {
			case 'Checkbox':
				a.text = a.text;

				a.checkbox.frames = Paths.getFrames('menus/silly-options/checkbox');
				a.checkbox.animation.addByPrefix("unchecked", "Check Box unselected0", 8);
				a.checkbox.animation.addByPrefix("checked", "Check Box Selected Static0", 8);
				a.checkbox.animation.addByPrefix("unchecking", "Check Box deselect animation0", 10, false);
				a.checkbox.animation.addByPrefix("checking", "Check Box selecting animation0", 10, false);
				a.checkbox.antialiasing = true;
				a.checkbox.scale.set(1, 1);
				a.checkbox.updateHitbox();

				a.offsets['unchecked'].set(0, 0);
				a.offsets['checked'].set(3, 13);
				a.offsets['checking'].set(12, 28);
				a.offsets['unchecking'].set(10, 9);

				a.checkbox.y = a.y + 26;
				a.checkbox.animation.play(a.checked ? "checked" : "unchecked", true);

				a.checkbox.shader = gm;

				extra.push(() -> {
					a.checkbox.x = a.__text.x + ((a.__text.textWidth * a.__text.scale.x) + (32 * a.__text.health));
					a.checkbox.shader = a.checked ? gm_enabled : gm;
				});

			case 'LanguageRadio' | 'RadioButton':
				color_black = col2rgba(0x006699);
				color_white = col2rgba(0xfdffef);
				var og = a.selectCallback;
				a.selectCallback = () -> {
					// die
					new FlxTimer().start(0.001, (_) -> {
						FlxG.sound.play(Paths.sound('deltaruneExplosion'), Options.volumeSFX);

						if (!Options.lowMemoryMode) {
							var explosion = new FunkinSprite();
							explosion.loadSprite(Paths.image('explosion'));
							explosion.addAnim('boom', '', 12, false);
							explosion.playAnim('boom', true);
							explosion.scale.set(5, 5);
							explosion.updateHitbox();
							explosion.setPosition(a.radio.x + (a.radio.width * 0.5), a.radio.y + (a.radio.height * 0.5));
							explosion.x -= explosion.width * 0.5;
							explosion.y -= explosion.height * 0.5;
							add(explosion).cameras = [awesomeCam];
							explosion.animation.finishCallback = (a) -> {
								remove(explosion, true);
								explosion.kill();
							}
						}
						if (typeString == 'LanguageRadio') {
							for (menu in menuGroup.members) {
								menu.reloadStrings();
								menu.forEach((b) -> {
									setupText(b.__text);
								});
							}
						}
						if (Options.flashingMenu) {
							for (i in [camera, awesomeCam]) {
								i.shake(12 / i.width, 0.5);
								i.flash(0x44ffffff, 0.4, null, true);
							}
						}
					});
					if (og != null)
						og();
				}
				a.radio.shader = gm;
				a.radio.frames = Paths.getFrames('menus/silly-options/radio');
				a.radio.animation.addByPrefix("unchecked", "Radio unselected0", 8);
				a.radio.animation.addByPrefix("checked", "Radio Selected Static0", 8);
				a.radio.animation.addByPrefix("unchecking", "Radio deselect animation0", 12, false);
				a.radio.animation.addByPrefix("checking", "Radio selecting animation0", 8, false);
				a.radio.antialiasing = true;
				a.radio.scale.set(1, 1);
				a.radio.updateHitbox();
				a.offsets['unchecked'].set(0, 0);
				a.offsets['checked'].set(8, 13);
				a.offsets['checking'].set(16, 30);
				a.offsets['unchecking'].set(20, 9);
				a.radio.y = a.y + 26;
				extra.push(() -> {
					a.radio.shader = a.checked ? gm_enabled : gm;
				});

			case 'NumOption':
				var gm_stupid = new CustomShader('gradientMap');
				gm_stupid.black = col2rgba(0x9900cc);
				gm_stupid.white = col2rgba(0xffeeff);
				gm_stupid.mult = 1;
				var lastVal = a.currentValue;
				var og = a.changedCallback;
				var effect2 = new WaveEffect(0, 0, 3);
				a.__number.effects.push(effect2);
				a.changedCallback = (b) -> {
					if (og != null)
						og(b);
					a.__number.origin.set(0, a.__number.height * 0.5);
					a.__number.x = a.__text.x;
					a.__number.health = FlxMath.signOf(lastVal - b) * 10;
					lastVal = b;
					effect2.intensityY = 7;
					effect2.speed = 9;
					effect2.effectTime = FlxG.random.float(-1, 1);
					effect2.period = FlxG.random.float(3, 5);
				}
				var sel = null;
				extra.push(() -> {
					a.__number.frameOffset.x = -((a.__text.textWidth * a.__text.scale.x) + (60 * a.__text.health));
					if (sel != a.selected) {
						sel = a.selected;
						var bleh = gm_stupid.black;
						gm_stupid.black = gm_stupid.white;
						gm_stupid.white = bleh;
					}
					a.__number.health = lerp(a.__number.health, 0, 0.1);
					a.__number.frameOffset.y = a.__number.health * -1;
					effect2.speed = lerp(effect2.speed, 1, 0.02);
					effect2.intensityY = lerp(effect2.intensityY, 0, 0.1);
				});
				a.changedCallback(a.currentValue);
				a.__number.font = 'silly';
				a.__number.shader = gm_stupid;

			case 'SliderOption':
				a.slider.frames = Paths.getFrames('menus/silly-options/slider');
				a.slider.resetHelpers(); // ???
				a.slider.scale.set(1, 1);
				a.slider.updateHitbox();
				a.slider.shader = gm_enabled;
				extra.push(() -> {
					a.slider.x = a.x + ((a.__text.textWidth * a.__text.scale.x) + (40 * a.__text.health));
				});

			case 'ArrayOption':
				var gm_stupid = new CustomShader('gradientMap');
				gm_stupid.black = col2rgba(0xcc0066);
				gm_stupid.white = col2rgba(0xffefcf);
				gm_stupid.mult = 1;
				var effect2 = new WaveEffect(0, 0, 6);
				a.__selectionText.effects.push(effect2);
				var og = a.changedCallback;
				var lastVal = a.currentSelection;
				a.changedCallback = (b) -> {
					if (og != null)
						og(b);
					a.__selectionText.origin.set(0, a.__selectionText.height * 0.5);
					a.__selectionText.x = a.__text.x;
					a.__selectionText.health = FlxMath.signOf(lastVal - b) * 10;
					lastVal = b;
					effect2.intensityX = 4;
					effect2.intensityY = 7;
					effect2.speed = 12;
					effect2.effectTime = FlxG.random.float(-1, 1);
					effect2.period = FlxG.random.float(3, 5);
				}
				var sel = null;
				extra.push(() -> {
					a.__selectionText.frameOffset.x = -((a.__text.textWidth * a.__text.scale.x) + (60 * a.__text.health));
					if (sel != a.selected) {
						sel = a.selected;
						var bleh = gm_stupid.black;
						gm_stupid.black = gm_stupid.white;
						gm_stupid.white = bleh;
					}
					a.__selectionText.health = lerp(a.__selectionText.health, 0, 0.1);
					a.__selectionText.frameOffset.y = a.__selectionText.health * -1;
					effect2.speed = lerp(effect2.speed, 1, 0.02);
					effect2.intensityX = lerp(effect2.intensityX, 0, 0.06);
					effect2.intensityY = lerp(effect2.intensityY, 0, 0.1);
				});
				a.changedCallback(a.options[a.currentSelection]);
				a.__selectionText.font = 'silly';
				a.__selectionText.shader = gm_stupid;

			case 'TextOption':
				if (a.suffix == ' >') {
					color_black = col2rgba(0x990066);
					color_white = col2rgba(0xfffdef);
				} else {
					color_black = col2rgba(0x003366);
					color_white = col2rgba(0xfdffef);
				}
		}
		var displayShit = 0;
		a.__text.onDraw = (t) -> {
			displayShit += FlxG.elapsed * trackedSelectState;
			var selectState = (a.selected ? 1 : -1);
			// trace(trackedSelectState + ' - ' + a.ID);
			if (trackedSelectState != selectState) {
				trackedSelectState = selectState;
				trackedScale = targetScale;
				targetScale = ((selectState == -1) ? 0.9 : 1);
				displayShit = 0;
				gm.white = (selectState == 1) ? color_black : color_white;
				gm.black = (selectState == 1) ? color_white : color_black;
			}
			effect.intensityY = lerp(effect.intensityY, a.selected ? 5 : 0, 0.04);
			var intendedScale = FlxMath.lerp(trackedScale, targetScale, FlxEase.elasticOut(Math.min(1, Math.abs(displayShit * 2))));
			t.health = intendedScale;

			t.scale.x *= intendedScale;
			t.scale.y *= intendedScale;

			if (extra.length > 0) {
				var ii = 0;
				while (ii < extra.length)
					extra[ii++]();
			}
			t.draw();
			t.scale.x /= intendedScale;
			t.scale.y /= intendedScale;
		}
	});
	var lerpSelected = 0;
	var updateItem = (object:FlxSprite, itemHeight:Float, centerY:Float, lerpRatio:Float) -> {
		var rel = object.ID - lerpSelected;
		object.y = CoolUtil.fpsLerp(object.y, centerY - itemHeight * 0.5, lerpRatio);
		object.x = menu.x - Math.abs(rel * rel * 5);
		object.alpha = menu.alpha;
	}
	menu.updateItems = function(force = false) {
		var members = menu.members;
		var curSelected = menu.curSelected;

		var r = force ? 1 : 0.15, initY = FlxG.height * 0.5;
		var i = curSelected, y = initY, object:FlxSprite = null, itemHeight:Float = 0;

		lerpSelected = CoolUtil.fpsLerp(lerpSelected, curSelected, r);

		while (i < members.length) if ((object = members[i++]) != null) {
			itemHeight = object.height;
			updateItem(object, itemHeight, y, r);
			y += itemHeight;
		}

		y = initY;
		i = curSelected;
		while (i-- > 0) if ((object = members[i]) != null) {
			y -= (itemHeight = object.height);
			updateItem(object, itemHeight, y, r);
		}
	}
}

var awesomeCam = new FlxCamera();
var overlayCam = new FlxCamera();

TextOption.OPTION_VALUE_PREFIX = '';
ArrayOption.EMPTY_ARROW_STRING = '   ';
ArrayOption.LEFT_ARROW_STRING = '← ';
ArrayOption.RIGHT_ARROW_STRING = ' →';

var offsetOption = null;

function create() {
	FlxG.camera.bgColor = 0xFF669999;
	camFollow.screenCenter();

	import funkin.options.categories.DebugOptions;
	var options = OptionsMenu.mainOptions.copy();
	var debugMenuIndex = options.push({
		name: 'optionsTree.debug-name',
		desc: 'optionsTree.debug-desc',
		state: DebugOptions
	}) - 1;

	if (mobile) {
		options[0] = {
			name: 'optionsTree.controls-name',
			desc: 'optionsTree.controls-desc',
			func: () -> {
				var fuck = (a) -> {
					return 'MobileControls.' + a;
				}
				addMenu(new CustomTreeScreen('a', 'o', [
					// disable until i can get mobile controls to work on deez

					/*
						new TextOption(fuck('navigationHelp-name'), fuck('navigationHelp-desc'), '', () -> {
							persistentUpdate = false;
							persistentDraw = true;
							var sub = new ModSubState('mnh/OptionsMobile');
							sub.cameras = [overlayCam];
							openSubState(sub);
					}),*/
					new Checkbox(fuck('touchGameplay-name'), fuck('touchGameplay-desc'), 'touchGameplay', null, FlxG.save.data)
				]));
			}
		}
	}

	penisText = new FunkinText(0, 0, 0, 'burp');

	var mainMenu;
	mainMenu = new CustomTreeScreen('a', 'o', [
		for (o in options)
			new TextOption(o.name, o.desc, o.suffix ?? ' >', () -> {
				// fetch base menus and remove them later
				if (o.state != null) {
					var og = Type.createInstance(o.state, [o.name, o.desc]);
					var newMenu = addMenu(new CustomTreeScreen(o.name, o.desc, og.members));
					switch (CoolUtil.last(Type.getClassName(o.state).split('.'))) {
						case 'GameplayOptions':
							var advanced = CoolUtil.last(newMenu.members);
							advanced.selectCallback = () -> {
								import funkin.options.categories.AdvancedGameplayOptions;
								var og = Type.createInstance(AdvancedGameplayOptions, []);
								var newMenu = addMenu(new CustomTreeScreen(advanced.rawText, advanced.rawDesc, og.members));
							};

							offsetOption = newMenu.members[5];
						case 'MiscOptions':
							var dev = CoolUtil.first(newMenu.members);
							dev.selectCallback = () -> {
								mainMenu.members[debugMenuIndex].locked = !Options.devMode;
							};
						case 'AppearanceOptions':
							var advanced = CoolUtil.last(newMenu.members);
							advanced.selectCallback = () -> {
								import funkin.options.categories.AdvancedAppearanceOptions;
								var og = Type.createInstance(AdvancedAppearanceOptions, []);
								var newMenu = addMenu(new CustomTreeScreen(advanced.rawText, advanced.rawDesc, og.members));
							};
					}
				} else if (o.substate != null) {
					persistentUpdate = false;
					persistentDraw = true;
					openSubState(Type.createInstance(o.substate, []));
				} else if (o.func != null) {
					o.func();
				}
			})
	]);
	var first = mainMenu;
	import funkin.backend.assets.ModsFolder;
	for (i in ModsFolder.getLoadedMods()) {
		var xmlPath = Paths.xml('config/options/LIB_' + i);
		if (Paths.assetsTree.existsSpecific(xmlPath, "TEXT")) {
			try
				access = Xml.parse(Paths.assetsTree.getSpecificAsset(xmlPath, "TEXT"))
			catch (e:Dynamic)
				trace(e);
			if (access != null)
				for (o in parseOptionsFromXML(first, access))
					first.add(o);
		}
	}
	addMenu(mainMenu);
	mainMenu.members[debugMenuIndex].locked = !Options.devMode;

	shit = new FlxBackdrop(FlxGridOverlay.createGrid(1, 1, 16, 16, true, 0x33ffffff, 0xffffffff));
	shit.scale.set(60, 60);
	shit.updateHitbox();
	shit.screenCenter();
	shit.scrollFactor.set(0.4, 0.4);
	shit.velocity.set(-30, 0);
	shit.blend = BlendMode.ADD;
	shit.alpha = 0.1;
	add(shit);
	add(menuGroup);

	FlxG.cameras.add(awesomeCam, false);
	FlxG.cameras.add(overlayCam, false);

	for (i in [camera, awesomeCam]) {
		i.follow(camFollow, null, 0.1);
		i.scroll.x = -500;
	}
	for (i in [awesomeCam, overlayCam]) {
		i.bgColor = 0;
	}

	menuGroup.cameras = [awesomeCam];
	var fuckShader = new FunkinShader('
		#pragma header

		void main() {
			vec2 uv = openfl_TextureCoordv;
			vec4 og = flixel_texture2D(bitmap, uv);
			vec4 color = texture2D(bitmap, uv - vec2(0.0, 0.015), 2.0);
			color.rgb = vec3(0.0);
			color.a *= 0.5;

			gl_FragColor = mix(color, og, og.a);
		}
	');
	fuckShader.data.bitmap.mipFilter = 0;
	awesomeCam.addShader(fuckShader);

	var penisBG = new FunkinSprite();
	penisBG.makeSolid(1, 1, -1);
	penisBG.alpha = 0.3;
	add(penisBG);
	penisBG.blend = BlendMode.SUBTRACT;
	penisBG.scrollFactor.set();

	add(penisText);
	penisText.alignment = 'center';
	penisText.font = Paths.font('sillyfont.ttf');
	penisText.fieldWidth = 1200;
	penisText.screenCenter();
	penisText.color = 0xffffff;
	penisText.borderColor = 0xff000000;
	penisText.size = 32;
	penisText.scrollFactor.set();
	penisText.borderSize = 3;
	penisText.antialiasing = true;
	penisText.x = Std.int(penisText.x); // no ugly

	penisText.text = translate('optionsMenu.start-message');
	penisText.onDraw = (a) -> {
		var border = 7;
		penisText.y = FlxG.height - penisText.height - 50;
		penisBG.setGraphicSize(FlxG.width, a.height + (border * 2) + 50);
		penisBG.updateHitbox();
		penisBG.setPosition(0, FlxG.height - penisBG.height);
		penisBG.draw();
		a.draw();
	}

	penisText.cameras = penisBG.cameras = [overlayCam];

	CoolUtil.playMenuSong();
	FlxG.sound.music.pitch = 1; // ???
	filter = new FlxSoundFilter(FlxG.sound.music);
    filter.filterType = FlxSoundFilterType.BANDPASS;
    filter.gainHF = 1.0;
    add(filter); //add so the filter will be destroyed automatically by the state (or destroy manually when not needed)
}
var filter = null;

var __metronome = FlxG.sound.load(Paths.sound('editors/charter/metronome'));
var trackedBeat = -1;
var trackedHonestBeat = -1;
function update(elapsed) {
	var menu = CoolUtil.last(tree);
	camFollow.x = menu.x + (camera.width * 0.5) - 80;
	var mouse = touchPos(FlxG.mouse);
	for (i in [camera, awesomeCam]) {
		i.targetOffset.set((mouse.x - i.width) * 0.01, (mouse.y - i.height) * 0.01);
	}
	for (i in tree) {
		i.alpha = lerp(i.alpha, (i.inputEnabled ? 1 : 0.4), 0.1);
	}
	shit.zoom = lerp(shit.zoom, 1, 0.05);
	shit.alpha = lerp(shit.alpha, 0.1, 0.05);
	shit.velocity.x = lerp(shit.velocity.x, -30, 0.05);
	var isShitSelected = false;
	if (offsetOption != null) {
		if (tree[treeLength - 1].curOption == offsetOption) {
			final guh = Math.sin(Conductor.curBeatFloat * Math.PI);
			offsetOption.__text.angle = FlxEase.expoOut(Math.abs(guh)) * FlxMath.signOf(guh) * 3;
			isShitSelected = true;
			var beat = Math.floor(Conductor.getStepForTime(FlxG.sound.music.time) / Conductor.stepsPerBeat);
			if (trackedBeat != beat) {
				trackedBeat = beat;
				__metronome.play();
				FlxG.sound.music.volume -= 0.1;
			}

			if (trackedHonestBeat != Conductor.curBeat) {
				trackedHonestBeat = Conductor.curBeat;
				shit.zoom = 0.98;
				if (Options.flashingMenu) {
					shit.color = FlxColor.fromHSB(Conductor.curBeat * 14, 0.3, 1);
					shit.alpha = 0.16;
					shit.velocity.x = -140;
				}
			}
			FlxG.sound.music.volume = lerp(FlxG.sound.music.volume, 0.67, 0.15);
			filter.gainHF = lerp(filter.gainHF, 0.25, 0.1);
		} else {
			offsetOption.__text.angle = lerp(offsetOption.__text.angle, 0, 0.12);
		}
	} 
	if (!isShitSelected) {
		filter.gainHF = lerp(filter.gainHF, 1.0, 0.06);
		FlxG.sound.music.volume = lerp(FlxG.sound.music.volume, 1, 0.4);
		shit.color = FlxColor.interpolate(shit.color, 0xffffffff, elapsed * 5);
	}
}

function exit() {
	canSelect = false;
	Options.save();
	Options.applySettings();
	TextOption.OPTION_VALUE_PREFIX = ': ';
	ArrayOption.EMPTY_ARROW_STRING = '  ';
	ArrayOption.LEFT_ARROW_STRING = '< ';
	ArrayOption.RIGHT_ARROW_STRING = ' >';
	if (data != null && data?.exitCallback != null) {
		return data.exitCallback(this);
	}
	FlxG.switchState(new MainMenuState());
}

import funkin.options.type.Checkbox;
import funkin.options.type.NumOption;
import funkin.options.type.ArrayOption;
import funkin.options.type.RadioButton;
import funkin.options.type.SliderOption;

// XML STUFF
function parseOptionsFromXML(screen, xml):Array<FlxSprite> {
	var options:Array<FlxSprite> = [];

	for (node in xml.elements()) {
		switch (node.nodeName) {
			case "separator":
				options.push(new Separator(node.get("height") != null ? Std.parseFloat(node.get("height")) : 67));
		}

		if (!node.get("name")) {
			Logs.warn("An option node requires a name attribute.");
			continue;
		}
		var name = node.get("name");
		var desc = (node.get("desc")?.toLowerCase()) ?? ("optionsMenu.desc-missing");

		switch (node.nodeName) {
			case "checkbox":
				if (!node.get("id")) {
					continue;
				}
				options.push(new Checkbox(name, desc, node.get("id"), null, FlxG.save.data));
			case "number":
				if (!node.get("id")) {
					continue;
				}
				var step = node.get("change") != null ? Std.parseFloat(node.get("change")) : (node.get("step") != null ? Std.parseFloat(node.get("step")) : null);
				options.push(new NumOption(name, desc, Std.parseFloat(node.get("min")), Std.parseFloat(node.get("max")), step, node.get("id"), null,
					FlxG.save.data));
			case "choice":
				if (!node.get("id")) {
					continue;
				}

				var optionOptions:Array<Dynamic> = [];
				var optionDisplayOptions:Array<String> = [];

				for (choice in node.elements()) {
					optionOptions.push(choice.get('value'));
					optionDisplayOptions.push(choice.get('name'));
				}

				if (optionOptions.length > 0)
					options.push(new ArrayOption(name, desc, optionOptions, optionDisplayOptions, node.get("id"), null, FlxG.save.data));
			case 'radio':
				if (!node.get("id")) {
					Logs.warn("A radio option requires an \"id\" for option saving.");
					continue;
				}
				var v:Dynamic = Std.parseFloat(node.get("value"));
				options.push(new RadioButton(screen, name, desc, node.get("id"), v != null ? v : node.get("value"), null, FlxG.save.data,
					node.get("forId") != null ? node.get("forId") : null));
			case 'slider':
				if (!node.get("id")) {
					Logs.warn("A slider option requires an \"id\" for option saving.");
					continue;
				}
				var step = node.get("change") != null ? Std.parseFloat(node.get("change")) : (node.get("step") != null ? Std.parseFloat(node.get("step")) : null);
				var segments = node.get("segments") != null ? Std.parseInt(node.get("segments")) : 5;
				options.push(new SliderOption(name, desc, Std.parseFloat(node.get("min")), Std.parseFloat(node.get("max")), step, segments, node.get("id"),
					Std.parseInt(node.get("barWidth")), null, FlxG.save.data));
			case "menu":
				options.push(new TextOption(name, desc, ' >', () -> {
					var screen = new CustomTreeScreen(name, desc, []);
					for (o in parseOptionsFromXML(screen, node))
						screen.add(o);
					addMenu(screen);
				}));
		}
	}

	return options;
}
