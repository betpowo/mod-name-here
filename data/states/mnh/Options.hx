import flixel.FlxLayer; // first time trying this . i hope i dont explode
import Xml;
import funkin.options.keybinds.KeybindsOptions;
import flixel.effects.FlxFlicker;
import haxe.ds.StringMap;
import Type;
import funkin.options.TreeMenu;
import funkin.options.OptionsMenu;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.FlxObject;
import funkin.backend.utils.NativeAPI;
import funkin.backend.system.updating.UpdateUtil;
import funkin.backend.system.updating.UpdateAvailableScreen;
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		WELCOME TO BACKEND LAND
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// base option type, for the helper functions so i dont have to make structs every time
// the "o" param shal look like
/*
	{
		onChange: (v) -> {},

		// menu only
		onOpen: () -> {},
		onClose: () -> {},

		// choice only, becomes the 3rd argument if type is menu
		options: ['a', 'b', 'c'],

		// number only
		min: 0,
		max: 69,
		step: 12,
		int: false
	}
 */
// all optional fields

function _____base(t, n, d, s, ?o, ?v) {
	return {
		type: t,
		name: n,
		description: d ?? 'no description provided',
		save: s,
		saveParent: Options,
		other: o ?? {},

		ignore: false,
		value: null,
		__parent: null,
		__selected: false,
		__objects: new StringMap(),
		__update: (elapsed) -> {},
		__extra: {}
	};
}

function num(n, d, s, ?o, ?v) {
	return _____base('num', n, d, s, o, v);
}

function choice(n, d, s, ?o, ?v) {
	return _____base('choice', n, d, s, o, v);
}

function checkbox(n, d, s, ?o, ?v) {
	return _____base('checkbox', n, d, s, o, v);
}

function menu(n, d, p, ?o, ?v) {
	(o ??= {options: []}).options = p;
	return _____base('menu', n, d, null, o, v);
}

function separator(n) {
	return _____base('separator', n, null, null, null, null);
}

function radio(n, d, s, ?o, ?v) {
	return _____base('radio', n, d, s, o, v);
}

function slider(n, d, s, ?o, ?v) {
	return _____base('slider', n, d, s, o, v);
}

function func(n, d, c) {
	var c_ = c;
	return _____base('func', n, d, null, {
		onOpen: () -> {
			if (c_ != null)
				c_();
		}
	});
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		WELCOME TO FRONTEND LAND
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

function parseSettingsXML(xml) {
	var result = [];
	try {
		for (node in xml.elements()) {
			var name = node.get("name");
			var desc = node.get("desc");
			var id = node.get("id");

			if ((name == null) || (node.nodeName != 'menu' && id == null))
				continue;

			name = name.toLowerCase();
			if (desc != null)
				desc = desc.toLowerCase();

			var op = null;
			switch (node.nodeName) {
				case "checkbox":
					op = checkbox(name, desc, id);

				case "number":
					op = num(name, desc, id, {
						min: node.get('min'),
						max: node.get('max'),
						step: node.get('change')
					});

				case "choice":
					var optionOptions:Array<Dynamic> = [];
					var optionDisplayOptions:Array<String> = [];

					for (choice in node.elements()) {
						optionOptions.push(choice.get('value'));
						optionDisplayOptions.push(choice.get('name') ?? choice.get('value'));
					}

					if (optionOptions.length > 0)
						op = choice(name, desc, id, {
							options: optionOptions,
							displayedOptions: optionDisplayOptions
						});
					else
						continue;

				case "menu":
					op = menu(name, desc, parseSettingsXML(node));
			}
			op.saveParent = FlxG.save.data;
			result.push(op);
		}
		return result;
	} catch (e:Dynamic) {
		trace(e);
		trace('FUCKJ YOU!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
	}
	return [];
}

var mainOptions = menu('options', 'descriptions will appear here', [
	/*checkbox('checkbox', 'awesome description', 'dumpVar', {
			onChange: (a) -> {
				trace('hi guys');
			}
		}),
		num('number', 'whar..', 'dumpVar2', {
			min: -3,
			max: 9,
			step: 4
		}),
		choice('choice', 'a', 'dumpVar3', {
			// I'm sorry. I'm genuinely sorry.
			options: ['tralalero tralala', 'bombardiro crocodilo', 'ballerina capuccina', 'brr brr patapim', 'tung tung sahur']
		}),
		menu('menu', 'wharrr', [
			checkbox('level of idk', 'aeiou', 'dumpVar'),
			num('number! again!', 'whar..', 'dumpVar2'),
			menu('submenu?', 'wharrr', [
				num('holyyy shitttt', 'whar..', 'dumpVar2')
			])
		], {
			onOpen: () -> {
				trace('oh');
			}
		}),
		func('func', 'oh', () -> {
			trace('hu');
	}),*/
	{
		var opt = (mobile) ? 
		menu('controls', 'change controls... i guess?', [
			func('navigation help', 'whar????', () -> {
				persistentUpdate = false;
				persistentDraw = true;
				var sub = new ModSubState('mnh/OptionsMobile');
				sub.cameras = [overlayCam];
				openSubState(sub);
			}),
			{
				var chk = checkbox('touchscreen gameplay', 'if checked, will move arrows to the center, forces downscroll, and enables tapping on the strums to hit notes. if your cne port already has the Four Dreaded Rectangular Lanes, or if it hinders performance, disable this', 'touchGameplay');
				chk.saveParent = FlxG.save.data;
				chk;
			}
		]) : 
		func('controls', 'change controls for player 1 and player 2!', () -> {
			persistentUpdate = false;
			persistentDraw = true;
			openSubState(new KeybindsOptions());
		});
		opt;
	},
	menu('gameplay', 'change gameplay options such as downscroll, offset, naughtyness...', [
		checkbox('downscroll', 'if checked, will flip the ui', 'downscroll'),
		checkbox('ghost tapping', 'if UNchecked, pressing any key while there are no notes will fucking kill you', 'ghostTapping'),
		checkbox('naughtyness', 'they don\'t call it "friday night fucking" for nothing', 'naughtyness'),
		checkbox('camera zoom on beat', 'if UNchecked, the camera will not bump', 'camZoomOnBeat'),
		checkbox('auto pause', 'pauses the game when out of focus, as all fucking games should be', 'autoPause'),
		{
			var opt = num('song offset', 'audio delay, in case you use cheap bluetooth headphones', 'songOffset', {
				min: -999,
				max: 999
			});
			var __metronome = FlxG.sound.load(Paths.sound('editors/charter/metronome'));
			var trackedBeat = -1;
			opt.__update = (elapsed) -> {
				var beat = Math.floor(Conductor.getStepForTime(FlxG.sound.music.time) / Conductor.stepsPerBeat);
				if (trackedBeat != beat) {
					trackedBeat = beat;
					__metronome.play();
				}
				var text = opt.__objects.get('text');
				if (text != null) {
					var guh = FlxMath.fastSin(Conductor.curBeatFloat * Math.PI);
					text.angle = FlxEase.expoOut(Math.abs(guh)) * FlxMath.signOf(guh) * 3;
				}
			};
			opt.other.onSelect = () -> {
				trackedBeat = Math.floor(Conductor.getStepForTime(FlxG.sound.music.time) / Conductor.stepsPerBeat);
			}
			opt.other.onUnselect = () -> {
				var text = opt.__objects.get('text');
				if (text != null) {
					text.angle = 0;
				}
			}
			opt;
		},
		slider('music volume', 'how loud it is', 'volumeMusic', {
			min: 0,
			max: 1,
			segments: 5,
			onChange: (v) -> {
				FlxG.sound.defaultMusicGroup.volume = v;
			}
		}),
		slider('sfx volume', 'how loud stuff is', 'volumeSFX', {
			min: 0,
			max: 1,
			segments: 5
		}),
		separator(60),
		menu('advanced', 'for the big brains', [
			checkbox('streamed music', 'streams the music', 'streamedMusic'),
			checkbox('streamed vocals', 'streams the vocals', 'streamedVocals'),
		])
	]),
	menu('appearance', 'change appearance options such as flashing menus...', [
		#if desktop
		num('framerate', 'EXTREME GAMING ACTIVATE', 'framerate',
			{
				min: 30,
				max: 240,
				step: 10,
				onChange: (change) -> {
					// if statement cause of the flixel warning
					if (FlxG.updateFramerate < Std.int(change))
						FlxG.drawFramerate = FlxG.updateFramerate = Std.int(change);
					else
						FlxG.updateFramerate = FlxG.drawFramerate = Std.int(change);
				}
			}),
		#end
		checkbox('flashing menu', 'disable if you\'re sensitive to flashing lights.', 'flashingMenu'),
		checkbox('colored healthbar', 'that newgrounds sovl going thru my veins rn.......ouggghh', 'colorHealthBar'),
		{
			var opt = checkbox('pixel perfect effect (ignored)', 'this has no effects on the mod but i kept it here cus why not', 'week6PixelPerfect');
			opt.ignore = true;
			opt;
		},
		separator(60),
		menu('advanced', 'for the big brains', {
			var fuck = [];
			var qualityOptions = [
				checkbox('antialiasing', 'if UNchecked it will make everything CRUNChy ok', 'antialiasing'),
				checkbox('low memory mode', 'removes some sprites from the stage if they are too big idk', 'lowMemoryMode'),
				checkbox('gameplay shaders', 'effects on the screen that do fancy shit, if you\'re on a potato pc, disable this', 'gameplayShaders'),
			];
			var doneTheDeed = qualityOptions.length;
			var updateQoptions = () -> {
				for (i in qualityOptions) {
					i.ignore = Options.quality != 2;
					var tracked = doneTheDeed;
					i.__update = (elapsed) -> {
						var text = opt.__objects.get('text');
						if (text != null) {
							text.alpha = i.ignore ? 0.3 : 1;
						}
					};
					i.__update(0);
				}
			}
			updateQoptions();
			var quality = choice('quality', 'a', 'quality', {
				options: [0, 1, 2],
				displayedOptions: ['low', 'high', 'custom'],
				onChange: (v) -> {
					updateQoptions();
				}
			});
			fuck.push(quality);
			for (i in qualityOptions) {
				fuck.push(i);
			}
			#if sys
			fuck.push(checkbox('vram-only sprites',
				'stores all bitmaps in gpu, at the cost of removing 50% of blend modes available GRAHHHH I FUCKIGN HATE OPENFL', 'gpuOnlyBitmaps'));
			#end
			fuck;
		})
	]),
	// todo: add languages (if possible)
	/*menu('language', 'o', [
			for (lang in TranslationUtil.foundLanguages) {
				var split = lang.split("/");
				var langId = split[0], langName = split[split.length - 1];
				var rad = radio(langName.toLowerCase(), 'idk', 'language');
				rad.other.selected = Options.language == langId;
				rad.value = langId;
				// trace(rad);
				rad;
			}
		]), */
	menu('miscellaneous', 'use this menu to reset save data or engine settings.', [
		checkbox('developer mode', '*enters own password* i\'m in.', 'devMode', {
			onChange: (v) -> {
				if (debugOptionsMenu != null) {
					debugOptionsMenu.ignore = !Options.devMode;
				}
			}
		}),
		checkbox('show modpack warning', '"modpack.ini not found" sybau 💔🥀', 'allowConfigWarning'),
		#if UPDATE_CHECKING
		checkbox('nightly updates', 'i need it bruh', 'betaUpdates'), func('check for updates', 'please ... please do', () -> {
			var report = UpdateUtil.checkForUpdates(true);
			if (report.newUpdate)
				FlxG.switchState(new UpdateAvailableScreen(report));
			else {
				CoolUtil.playMenuSFX(2);
			}
		}),
		#end
		separator(60),
		func('reset save data', 'IF YOU PRESS IT EARTH WILL BLOW UP', () -> {
			// lol
		})
	]),
	{
		debugOptionsMenu = menu('debug options', 'something something dev settings', [
			/*func("i'm not fucking filling this up", 'lol', () -> {
				// lol
			})*/
			// yea well too bad we gotta
			#if windows
			func('show console', "enter hacker mode! ...even though you can't type anything.", NativeAPI.allocConsole),
			#end
			{
				resi = checkbox('resizable editors', "i don't CARE if the game is 1280x720 i WILL adapt to whatever i can. Fucj yo", 'editorsResizable');
				resi.other.onChange = (v) -> {
					bypa.ignore = !Options.editorsResizable;
				};
				resi;
			},
			{
				bypa = checkbox('bypass editor resize', "FUCK the minimum resolution man i dont. i Dont gaf", 'bypassEditorsResize');
				resi.other.onChange(Options.editorsResizable);
				bypa;
			},
			checkbox('editor sfx', "I HATE THE WINDOW OPEN SOUND GRAHHHH", 'editorSFX'),
			separator(60),
			{
				var f = func('- pretty prints -', '???', () -> {
					trace('How did you do it.');
				});
				f.ignore = true;
				f;
			},
			checkbox('charter', "if UNchecked chart files become a mess but it's optimized so who cares", 'editorCharterPrettyPrint'),
			checkbox('character', "if UNchecked character files become a mess but it's optimized so who cares", 'editorCharacterPrettyPrint'),
			checkbox('stage', "if UNchecked stage files become a mess but it's optimized so who cares", 'editorStagePrettyPrint'),
			separator(60),
			checkbox('intensive blur', "DO NOT . TURN THIS ON *cough* FUCK,.  *cough* DO NOT   . TUR NTHIS ON", 'intensiveBlur'),
			checkbox('editor autosaves', "hmm yes. save my work for me so i don't lose my marbles", 'charterAutoSaves'),
			num('autosaving time', 'how often it should save (in seconds...)', 'charterAutoSaveTime', {
				min: 60,
				max: 600,
				step: 1,
			}),
			num('save warning time', 'how long until Impending Doom Arrives. (in seconds...)', 'charterAutoSaveWarningTime',
				{
					min: 0,
					max: 15,
					step: 1,
				}),
			checkbox('autosaves folder', "if you don't like your files being overwritten by autosaving, use this", 'charterAutoSavesSeparateFolder'),
			checkbox('offset in charter', "hm yes.  delay my audio time in the chart editor  . yes. it makes sense", 'songOffsetAffectEditors'),
		]);
		debugOptionsMenu.ignore = !Options.devMode;
		debugOptionsMenu;
	},
	menu('mod name here', 'finally . the good settings', parseSettingsXML(Xml.parse(Assets.getText(Paths.xml('config/options'))).firstElement()))
]);
var cameraTracker:FlxObject = new FlxObject(0, 0, 0, 0);
var awesomeCam = new FlxCamera();
var overlayCam = new FlxCamera();

function create() {
	CoolUtil.playMenuSong();

	cameraTracker.x = camera.width * 0.5;
	cameraTracker.y = camera.height * 0.5;
	camera.bgColor = 0xff669999;

	shit = new FlxBackdrop(FlxGridOverlay.createGrid(1, 1, 2, 2, true, 0x33ffffff, 0xffffffff));
	shit.scale.set(60, 60);
	shit.updateHitbox();
	shit.screenCenter();
	shit.scrollFactor.set(0.4, 0.4);
	shit.velocity.set(-30, 0);
	shit.blend = 0;
	shit.alpha = 0.1;

	initValues(mainOptions);
	addOptionTexts(mainOptions, 90, 70);
	curMenu = mainOptions;

	insert(0, shit);

	FlxG.cameras.add(awesomeCam, false);
	FlxG.cameras.add(overlayCam, false);

	for (i in [camera, awesomeCam]) {
		i.follow(cameraTracker, null, 0.1);
	}
	for (i in [awesomeCam, overlayCam]) {
		i.bgColor = 0;
	}

	var title = makeText(-20, 0, 'option');
	title.size = 128;
	title.updateHitbox();
	title.borderColor = 0;
	title.scrollFactor.set(0.03, 0.03);
	title.x = FlxG.width - title.width;
	title.y = FlxG.height - title.height * 0.67;
	add(title);

	var ohmygodbruh = 8;
	title.onDraw = (t) -> {
		var og = ohmygodbruh;
		var oga = t.alpha;
		var ogy = t.y;
		t.draw();
		while (ohmygodbruh > 0) {
			ohmygodbruh--;
			t.alpha *= 0.5;
			t.y -= 50;
			t.draw();
		}
		t.alpha = oga;
		t.y = ogy;
		ohmygodbruh = og;
	}

	// awesomeCam.angle = 3;

	var penisBG = new FunkinSprite();
	penisBG.makeSolid(1, 1, 0x33ffffff);
	add(penisBG);
	penisBG.blend = 14;
	penisBG.scrollFactor.set();

	penisText = makeText(0, 0, 'burp');
	add(penisText);
	penisText.alignment = 'center';
	penisText.fieldWidth = 1000;
	penisText.screenCenter();
	penisText.color = 0xffffff;
	penisText.borderColor = 0xff000000;
	penisText.size = 32;
	penisText.scrollFactor.set();
	penisText.borderSize = 3;
	penisText.x = Std.int(penisText.x); // no ugly

	curSelected = mainOptions.other.options.length;
	changeSelection(0);

	penisText.text = 'same controls as the original menu, man up';
	penisText.onDraw = (a) -> {
		var border = 7;
		penisBG.setGraphicSize(a.width + (border * 2), a.height + (border * 2));
		penisBG.updateHitbox();
		penisBG.setPosition(a.x - border, a.y - border);
		penisBG.draw();
		a.draw();
	}

	penisBG.cameras = penisText.cameras = [overlayCam];

	var border = 20;
	awesomeCam.width += border * 2;
	awesomeCam.height += border * 2;
	awesomeCam.x -= border;
	awesomeCam.y -= border;
	awesomeCam.addShader(new FunkinShader('
		#pragma header

		vec2 offset = vec2(8.0, 12.0);

		void main() {
			vec2 uv = openfl_TextureCoordv;
			vec4 og = flixel_texture2D(bitmap, uv);
			vec4 color = flixel_texture2D(bitmap, uv - (offset / openfl_TextureSize));
			color.rgb = vec3(0.0);
			color.a *= 0.5;

			gl_FragColor = mix(color, og, og.a);
		}
	'));
}

function initValues(opps) {
	for (i in opps.other.options) {
		switch (i.type) {
			case 'menu':
				initValues(i);

			default:
				if (i.type != 'radio') {
					i.value = Reflect.getProperty(i.saveParent, i.save);
				}
				i.other ??= {};
				var og = i.other.onChange;
				i.other.onChange = (a) -> {
					Reflect.setProperty(i.saveParent, i.save, a);
					if (og != null)
						og(a);
				}
		}
	}
}

var curSelected:Int = -1;
var curMenu = null;
var oldMenu = null;
var finalYOffset = 0.0;
var idYOffset = 0;

function addOptionTexts(opps, x, y) {
	x ??= 0;
	y ??= 0;
	var group = new FlxSpriteGroup();
	group.setPosition(x, y);
	group.camera = awesomeCam;

	for (k => i in opps.other.options) {
		i.parent = opps;

		if (i.type == 'separator') {
			finalYOffset += Std.int(i.name); // ???
			idYOffset += 1;
			continue;
		}

		var text = makeText(0, ((k - idYOffset) * 75) + finalYOffset, i.name);
		group.add(text);
		i.__objects.set('text', text);
		i.__objects.set('group', group);

		var ogu = i.__update;
		var ogus = i.other.onUnselect;

		switch (i.type) {
			case 'choice':
				i.other.displayedOptions ??= i.other.options.copy();
				i.value ??= i.other.options[0] ?? 'huh???';
				var num = Math.max(0, i.other.options.indexOf(i.value));
				var numText = makeText(text.x, text.y, ' ' + i.value + ' ');
				var lt = makeText(text.x, text.y, '←');
				var gt = makeText(text.x, text.y, '→');
				var tim = 0.0;

				lt.health = gt.health = numText.health = 0;
				i.__update = (elapsed) -> {
					if (i.__selected) {
						var change = (leftC.pressed ? -1 : (rightC.pressed ? 1 : 0));
						num = FlxMath.bound(num + change, 0, i.other.options.length - 1);
						var newv = i.other.options[num];
						if (i.value != newv) {
							i.value = newv;
							numText.health = change;
							CoolUtil.playMenuSFX().pitch = FlxMath.lerp(1, 1.25, change + FlxG.random.float(-0.2, 0.2));
							if (i.other.onChange != null)
								i.other.onChange(newv);
						}
					}

					// visuals
					numText.update(elapsed);
					lt.update(elapsed);
					gt.update(elapsed);

					numText.text = ' ' + i.other.displayedOptions[i.other.options.indexOf(i.value)].toLowerCase() + ' ';
					tim += elapsed;
					numText.color = FlxColor.fromHSB(tim * 60, 0.1, 1);
					numText.borderColor = FlxColor.fromHSB(tim * 100, 1, 0.333);
					if (i.__selected) {
						if (leftC.pressed)
							lt.health = 1;
						if (rightC.pressed)
							gt.health = 1;
					}

					lt.health = lerp(lt.health, 0, 0.2);
					gt.health = lerp(gt.health, 0, 0.2);
					numText.health = lerp(numText.health, 0, 0.1);

					if (ogu != null)
						ogu(elapsed);
				}
				text.onDraw = (t) -> {
					t.draw();

					numText.blend = lt.blend = gt.blend = t.blend;

					numText.setPosition(text.x + (text.width * text.scale.x) + 60, text.y);
					numText.alpha = t.alpha;

					lt.color = gt.color = numText.color;
					lt.borderColor = gt.borderColor = numText.borderColor;
					if (i.__selected) {
						if (leftC.held)
							swapBorderAndFill(lt);
						if (rightC.held)
							swapBorderAndFill(gt);
					}
					if (num != 0) {
						lt.setPosition(numText.x - lt.width + 10 - (10 * lt.health), numText.y);
						lt.alpha = t.alpha;
						lt.draw();
					}

					if (num != i.other.options.length - 1) {
						gt.setPosition(numText.x + numText.width - 10 + (10 * gt.health), numText.y);
						gt.alpha = t.alpha;
						gt.draw();
					}

					numText.y += numText.health * -5;
					numText.draw();
				}
				i.other.onUnselect = () -> {
					numText.text = ' ' + i.other.displayedOptions[i.other.options.indexOf(i.value)].toLowerCase() + ' ';
					numText.color = 0x006633;
					numText.borderColor = 0xffcfffcc;
					if (ogus != null)
						ogus();
				}
				i.__objects.set('option', numText);
				i.__objects.set('left', lt);
				i.__objects.set('right', gt);

				numText.camera = lt.camera = gt.camera = group.camera;

			case 'slider':
				i.value ??= i?.other?.min ?? 0;
				i.other ??= {};
				i.other.percent ??= FlxMath.remapToRange(i.value, i?.other?.min ?? 0, i?.other?.max ?? 1, 0, 1);

				var barText = makeText(text.x, text.y, [for (i in 0...(i?.other?.segments ?? 1)) '-'].join(''));
				var numText = makeText(text.x, text.y, '%');
				var fuck = 0.0;
				var fuckingWidth = i.other.width ??= 960 - text.width;
				var tim = 0.0;
				var settingFuck = false;
				i.__update = (elapsed) -> {
					if (i.__selected) {
						var change = (leftC.held ? -1 : (rightC.held ? 1 : 0));
						var newv = FlxMath.bound(i.other.percent + (FlxG.elapsed * (i?.other?.step ?? 1) * change), 0, 1);

						if (leftC.pressed || rightC.pressed) {
							settingFuck = false;
						}

						if (FlxG.mouse.pressed) {
							var mouse = FlxG.mouse.getScreenPosition(group.camera);
							var xx = text.x - group.camera.scroll.x + (text.width * text.scale.x) + 30;
							if (Math.abs(mouse.y - (group.camera.height * 0.5)) <= text.height * 0.5) {
								if (mouse.x >= xx) {
									newv = FlxMath.bound((mouse.x - xx) / fuckingWidth, 0, 1);
								}
							}
							mouse.put();
						}

						if (i.other.percent != newv) {
							i.other.percent = newv;
							i.value = FlxMath.lerp(i?.other?.min ?? 0, i?.other?.max ?? 1, i.other.percent);
							if (i.other.onChange != null)
								i.other.onChange(newv);
						} else if (!settingFuck) {
							fuck = change;
							settingFuck = true;
						}
					}

					// visuals
					tim += elapsed;
					barText.color = numText.color = FlxColor.fromHSB(tim * 100, 0.1, 1);
					barText.borderColor = numText.borderColor = FlxColor.fromHSB(tim * 60, 1, 0.333);

					fuck = lerp(fuck, 0, elapsed * 6);

					if (ogu != null)
						ogu(elapsed);
				}
				import flixel.math.FlxRect;

				barText.clipRect = new FlxRect(0, 0, barText.width, barText.height);
				var borderSize = 15;
				text.onDraw = (t) -> {
					t.draw();

					barText.blend = t.blend;
					var _x = text.x + (text.width * text.scale.x) + 30 + (fuck * 5);
					barText.setPosition(_x, text.y);
					barText.updateHitbox();
					barText.alpha = t.alpha;

					// I'm sorry.
					barText.clipRect = barText.clipRect.set(0, 0, borderSize, barText.height);
					barText.updateHitbox();
					barText.draw();
					barText.x += borderSize;
					barText.clipRect = barText.clipRect.set(borderSize, 0, barText.frameWidth - (borderSize * 2), barText.height);
					barText.scale.x = (fuckingWidth - (borderSize * 2)) / barText.clipRect.width;
					barText.x -= borderSize * barText.scale.x;
					barText.updateHitbox();
					barText.draw();
					barText.x += borderSize * barText.scale.x;
					barText.clipRect = barText.clipRect.set(barText.frameWidth - borderSize, 0, borderSize, barText.height);
					barText.scale.x = 1;
					barText.x -= borderSize;
					barText.x -= barText.clipRect.x + barText.clipRect.width;
					barText.x += fuckingWidth;
					barText.updateHitbox();
					barText.draw();

					numText.setPosition(_x - (numText.width * 0.5), barText.y);
					numText.alpha = t.alpha;
					numText.x += (fuckingWidth * i.other.percent);
					numText.draw();
				}
				i.other.onUnselect = () -> {
					barText.color = numText.color = 0xcc6633;
					barText.borderColor = numText.borderColor = 0xffffffdd;
					holdTime = -1.0;
					if (ogus != null)
						ogus();
				}
				i.__objects.set('bar', barText);
				i.__objects.set('option', numText);
				numText.camera = barText.camera = group.camera;

			case 'num':
				i.value ??= 0;

				var numText = makeText(text.x, text.y, ' ' + i.value + ' ');
				var tim = 0.0;
				numText.health = 0;
				var holdTime = -1.0;
				i.__update = (elapsed) -> {
					if (i.__selected) {
						var change = (leftC.pressed ? -1 : (rightC.pressed ? 1 : 0));

						if (change != 0) {
							if (holdTime == -1.0)
								holdTime = 0.4;
						}

						if (leftC.released || rightC.released) {
							holdTime = -1.0;
						}

						if (leftC.held || rightC.held) {
							if (holdTime >= 0.0) {
								holdTime -= elapsed;
								if (holdTime < 0) {
									change = (leftC.held ? -1 : (rightC.held ? 1 : 0));
									holdTime = 1 / 18;
								}
							}
						}

						var newv = FlxMath.bound(i.value + (i?.other?.step ?? 1) * change, i?.other?.min ?? null, i?.other?.max ?? null);

						if (i.value != newv) {
							i.value = newv;
							numText.health = change;
							CoolUtil.playMenuSFX().pitch = FlxMath.lerp(1, 1.25, change + FlxG.random.float(-0.2, 0.2));
							if (i.other.onChange != null)
								i.other.onChange(newv);
						}
					}

					// visuals
					numText.update(elapsed);
					numText.text = ' ' + i.value + ' ';
					tim += elapsed;
					numText.color = FlxColor.fromHSB(tim * 100, 0.1, 1);
					numText.borderColor = FlxColor.fromHSB(tim * 60, 1, 0.333);
					numText.health = lerp(numText.health, 0, 0.1);

					if (ogu != null)
						ogu(elapsed);
				}
				text.onDraw = (t) -> {
					t.draw();

					numText.blend = t.blend;
					numText.setPosition(text.x + (text.width * text.scale.x) + 30, text.y);
					numText.alpha = t.alpha;
					numText.y += numText.health * -5;
					numText.draw();
				}
				i.other.onUnselect = () -> {
					numText.color = 0xcc3366;
					numText.borderColor = 0xffffddff;
					holdTime = -1.0;
					if (ogus != null)
						ogus();
				}
				i.__objects.set('option', numText);
				numText.camera = group.camera;

			case 'checkbox':
				i.value ??= false;

				// will use a sprite later
				var numText = makeText(text.x, text.y, i.value ? ' yah ' : ' nah ');
				numText.health = 0;
				var og = i.other.onOpen;
				i.other.onOpen = () -> {
					i.value = !i.value;
					numText.health = 1;
					CoolUtil.playMenuSFX(i.value ? 3 : 4);
					if (i.other.onChange != null)
						i.other.onChange(i.value);
					if (og != null)
						og();
				}
				i.__update = (elapsed) -> {
					// visuals
					numText.update(elapsed);
					numText.text = i.value ? ' yah ' : ' nah ';
					var hue = i.value ? 160 : 300;
					numText.color = FlxColor.fromHSB(hue, 0.1, 1);
					numText.borderColor = FlxColor.fromHSB(hue, 1, 0.333);
					if (ogu != null)
						ogu(elapsed);
				}
				text.onDraw = (t) -> {
					t.draw();
					numText.health = lerp(numText.health, 0, 0.1);
					numText.blend = t.blend;
					numText.setPosition(text.x + (text.width * text.scale.x) + 30, text.y);
					numText.alpha = t.alpha;
					numText.y += numText.health * -5;
					numText.draw();
				}
				i.other.onUnselect = () -> {
					var hue = i.value ? 160 : 300;
					numText.color = FlxColor.fromHSB(hue, 0.1, 1);
					numText.borderColor = FlxColor.fromHSB(hue, 1, 0.333);

					swapBorderAndFill(numText);
					if (ogus != null)
						ogus();
				}
				i.__objects.set('option', numText);
				numText.camera = group.camera;

			case 'radio':
				// will use a sprite later
				var numText = makeText(text.x, text.y, i.other.selected ? 'O' : '|');
				i.other.selected ??= false;
				var tim = 0.0;
				var og = i.other.onOpen;
				i.other.onOpen = () -> {
					for (l => j in opps.other.options) {
						if (k == l)
							continue;
						if (j.other.selected) {
							j.__objects.get('option').health = 5;
						}
						j.other.selected = false;
						j.__update(0);
						j.other.onUnselect();
					}
					i.other.selected = true;
					numText.health = 5;

					CoolUtil.playMenuSFX(3);
					if (i.other.onChange != null)
						i.other.onChange(i.value);

					// trace(i.value);
				}

				i.__update = (elapsed) -> {
					// visuals
					numText.update(elapsed);
					numText.text = i.other.selected ? 'O' : '|';
					numText.color = FlxColor.fromHSB(tim * 100, 0.1, 1);
					numText.borderColor = FlxColor.fromHSB(tim * 60, 1, 0.333);
					if (ogu != null)
						ogu(elapsed);
				}
				text.onDraw = (t) -> {
					t.offset.x -= 90;
					t.draw();
					t.offset.x += 90;
					numText.health = lerp(numText.health, 0, 0.1);
					numText.blend = t.blend;
					numText.setPosition(text.x + (40 - (numText.width * 0.5)), text.y);
					numText.alpha = t.alpha;
					numText.x += FlxG.random.float(-1, 1) * numText.health;
					numText.y += FlxG.random.float(-1, 1) * numText.health;
					numText.draw();
				}
				i.other.onUnselect = () -> {
					var hue = i.value ? 160 : 300;
					numText.color = 0x006699;
					numText.borderColor = 0xfffdffef;

					if (ogus != null)
						ogus();
				}
				i.__objects.set('option', numText);
				numText.camera = group.camera;

			case 'func':
				text.color = 0xfdffef;
				text.borderColor = 0xff003366;
				var og = i.other.onOpen;
				i.other.onOpen = () -> {
					FlxFlicker.flicker(text, 0.5, 0.05, true);
					CoolUtil.playMenuSFX(1);
					if (og != null)
						og();
				}

			case 'menu':
				text.color = 0xfffdef;
				text.borderColor = 0xff990066;

				text.text += ' >';
				text.updateHitbox();
				text.origin.x = 0; // for scaling effect
				var _x = text.x + (text.width * 1.1) + 60, _y = text.y;
				var ogid = idYOffset;
				var ogy = finalYOffset;
				idYOffset = finalYOffset = 0;
				var newGroup = addOptionTexts(i, _x, _y); // ???
				idYOffset = ogid;
				finalYOffset = ogy;
				newGroup.visible = false;
				var saved_curSelected = 0;
				var this_curSelected = -1;
				var og = i.other.onOpen;
				i.other.onOpen = () -> {
					saved_curSelected = curSelected;
					newGroup.visible = true;
					oldMenu = curMenu;
					curMenu = i;

					group.alpha = 0.4;
					group.forEach((a) -> {
						a.blend = 12;
					});

					for (i in curMenu.other.options) {
						if (i.other.onUnselect != null)
							i.other.onUnselect();
					}
					curSelected = -1;
					changeSelection(1);
					if (curMenu.other.options[this_curSelected] != null) {
						swapBorderAndFill(curMenu.other.options[this_curSelected].__objects.get('text'));
						curMenu.other.options[this_curSelected].__objects.get('text').scale.set(1, 1);
					}
					FlxG.sound.play(Paths.sound('pixel/clickText'), 0.7);
					if (og != null)
						og();
				}
				i.other.onClose = () -> {
					this_curSelected = curSelected;
					newGroup.visible = false;
					group.alpha = 1;
					group.forEach((a) -> {
						a.blend = 10;
					});

					curSelected = -1;
					changeSelection(saved_curSelected + 1);
					swapBorderAndFill(curMenu.other.options[curSelected].__objects.get('text'));

					CoolUtil.playMenuSFX(2);
				}
		}

		var og = text.onDraw;
		text.onDraw = (t) -> {
			if (i.ignore)
				text.alpha *= 0.3;
			if (og != null)
				og(t);
			else
				t.draw();
			if (i.ignore)
				text.alpha /= 0.3;
		}
	}
	finalYOffset = 0.0;
	idYOffset = 0;
	insert(0, group);
	return group;
}

var TEXT_COLOR = 0xffefffff;
var TEXT_OUTLINE = 0xff000099;

function swapBorderAndFill(t) {
	if (t == null)
		return;

	var _borderColor = t.borderColor;
	t.borderColor = (t.color & 0xffffff) + 0xff000000;
	t.color = _borderColor;
}

function makeText(x, y, t) {
	var text = new FunkinText();
	text.font = Paths.font('sillyfont.ttf');
	text.borderSize = 5;
	text.borderColor = TEXT_OUTLINE;
	text.color = TEXT_COLOR;
	text.text = t;
	text.size = 64;
	text.antialiasing = true;
	text.setPosition(x, y);
	text.updateHitbox();
	text.origin.x = 0; // for scaling effect
	text.active = text.moves = false;
	return text;
}

if (mobile) {
	var prevX = null;
	var prevY = null;
	var hasMovedThisPress = false;
	var hasMovedBackwards = false;
	var scrolled = false;
	var pressedSides = false;
}

var leftC = {pressed:false, held:false, released:false};
var rightC = {pressed:false, held:false, released:false};

function update(elapsed) {
	if (!mobile) {
		for (camera in [camera, awesomeCam]) {
			var mousePos = FlxG.mouse.getScreenPosition(camera);
			camera.targetOffset.set(((mousePos.x - (camera.width * 0.5)) * 0.01), ((mousePos.y - (camera.height * 0.5)) * 0.01));
		}
		awesomeCam.targetOffset.x += awesomeCam.x;
		awesomeCam.targetOffset.y += awesomeCam.y;
	}

	var up = controls.UP_P || FlxG.mouse.wheel == 1;
	var down = controls.DOWN_P || FlxG.mouse.wheel == -1;
	var pressed = controls.ACCEPT || FlxG.mouse.justPressed;
	var back = controls.BACK || FlxG.mouse.justPressedRight;

	leftC.pressed = controls.LEFT_P;
	leftC.held = controls.LEFT;
	leftC.released = controls.LEFT_R;

	rightC.pressed = controls.RIGHT_P;
	rightC.held = controls.RIGHT;
	rightC.released = controls.RIGHT_R;

	if (mobile) {
		for (touch in FlxG.touches.list) {
			if (hasMovedThisPress && !touch.justPressed) {
				scrolled = true;
			}

			if (touch.justPressed) {
				hasMovedThisPress = hasMovedBackwards = scrolled = pressedSides = false;
				prevX = touch.screenX;
				prevY = touch.screenY;
			}
			var diff = prevY - touch.screenY;

			var minScroll = 12;
			var diffX = prevX - touch.screenX;
			if (Math.abs(diffX) > 20) {
				hasMovedThisPress = true;
			}

			if (touch.pressed) {
				if (diff <= -minScroll) up = true;
				if (diff >= minScroll) down = true;

				if (Math.abs(diff) >= minScroll) {
					hasMovedThisPress = true;
				}
			}

			if (scrolled) {
				up = down = false;
			}

			if (diffX < -20 && !hasMovedBackwards && !scrolled) {
				back = !(up = down = pressed = false);
				hasMovedBackwards = true;
			}

			var diffScreenX = touch.screenX - (FlxG.width * 0.5);
			if (Math.abs(diffScreenX) >= (FlxG.width * 0.25)) {
				if (touch.justPressed) {
					pressedSides = true;
				}
			}

			if (pressedSides) {
				var buh = (diffScreenX < 0) ? leftC : rightC;
				buh.pressed = touch.justPressed;
				buh.held = touch.pressed;
				buh.released = touch.justReleased;
			}

			if (touch.justReleased && (hasMovedThisPress || hasMovedBackwards)) {
				pressed = false;
				pressedSides = false;
			}

			prevX = touch.screenX;
			prevY = touch.screenY;
		}
	}

	if (up)
		changeSelection(-1);
	if (down)
		changeSelection(1);
	if (pressed) {
		var g = curMenu.other.options[curSelected];
		if (g.other != null && g.other.onOpen != null)
			g.other.onOpen();
	}

	curMenu.other.options[curSelected].__update(elapsed);

	if (back) {
		if (curMenu.parent == null) {
			exit();
		} else {
			oldMenu = curMenu;
			curMenu = curMenu.parent;
			if (oldMenu.other.onClose != null)
				oldMenu.other.onClose();
		}
	}
}

function changeSelection(c) {
	var old = curSelected;
	var candidate = FlxMath.wrap(old + c, 0, curMenu.other.options.length - 1);

	while (curMenu.other.options[candidate].type == 'separator' || curMenu.other.options[candidate].ignore) {
		candidate = FlxMath.wrap(candidate + c, 0, curMenu.other.options.length - 1);
	}

	curSelected = candidate;

	CoolUtil.playMenuSFX(0).pitch += FlxG.random.float(-1, 1) * 0.02;

	var tweenTxt = (a, s) -> {
		FlxTween.cancelTweensOf(a.scale);
		FlxTween.tween(a.scale, {x: s, y: s}, 0.5, {ease: FlxEase.elasticOut});
	}

	var oldText = null;
	var text = null;

	// TORTURE AND MIGRAINE
	if (curMenu.other.options[old] != null) {
		oldText = curMenu.other.options[old].__objects.get('text');
		curMenu.other.options[old].__selected = false;
		if (curMenu.other.options[old].other.onUnselect != null)
			curMenu.other.options[old].other.onUnselect();
	}
	if (curMenu.other.options[curSelected] != null) {
		text = curMenu.other.options[curSelected].__objects.get('text');
		curMenu.other.options[curSelected].__selected = true;
		if (curMenu.other.options[curSelected].other.onSelect != null)
			curMenu.other.options[curSelected].other.onSelect();
	}
	if (oldText != null) {
		swapBorderAndFill(oldText);
		tweenTxt(oldText, 1);
	}
	if (text != null) {
		swapBorderAndFill(text);
		tweenTxt(text, 1.1);

		cameraTracker.setPosition(text.x + (FlxG.width / 2.5), text.y + 64);
	}

	penisText.text = curMenu.other.options[curSelected].description;
	penisText.y = FlxG.height - penisText.height - 50;
}

function exit() {
	Options.save();
	Options.applySettings();

	if (data != null && data?.exitCallback != null) {
		return data.exitCallback(this);
	}

	FlxG.switchState(new MainMenuState());
}
