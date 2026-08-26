import funkin.backend.system.macros.GitCommitMacro;
import funkin.menus.credits.CreditsMain;
import funkin.backend.utils.WindowUtils;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import funkin.backend.assets.ModsFolder;
import funkin.backend.MusicBeatTransition;
import funkin.options.OptionsMenu;
import flixel.tweens.FlxTweenManager;
import funkin.backend.system.Flags;
import funkin.options.PlayerSettings;
import funkin.backend.utils.ControlsUtil;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import funkin.options.keybinds.KeybindsOptions;
import haxe.io.Path;

static var Mod_Name_Here__firstBoot:Bool = true;
public static var currentUI:String = '';
public static final version:String = Flags.customFlags['MOD_VERSION'];
public static final mobile:Bool = FlxG.onMobile;

// customFlags will always be strings
var blehFlag = Flags.customFlags['AMAZING_EPIC_GAMER_FLAG'] == "true";

function preStateSwitch() {
	currentUI = '';
	if (Mod_Name_Here__firstBoot != (Mod_Name_Here__firstBoot = false)) {
		FlxG.game._requestedState = new ModState('StartSplash');
		if (blehFlag)
			Main.instance.addChild(devWatermark);
		return;
	}
}

function destroy() {
	FlxG.camera.bgColor = 0;

	for (i in KeybindsOptions.defaultCategories) {
		if (i.name == 'category.notes') {
			for (j in i.settings) {
				j.sparrowIcon = 'game/notes/default';
			}
		}
	}

	if (forcedTweenManager != null) {
		FlxG.plugins.remove(forcedTweenManager);
	}

	if (blehFlag) {
		Main.instance.removeChild(devWatermark);
	}
	Mod_Name_Here__firstBoot = true;
}

var buddyCategories;
var forcedTweenManager = new FlxTweenManager();

function new() {
	FlxG.save.data.compact ??= false;
	FlxG.save.data.pbot ??= true;
	FlxG.save.data.comboBreakGhost ??= true;
	FlxG.save.data.comboBreakText ??= 'adaptive';
	FlxG.save.data.enableSubs ??= true;
	FlxG.save.data.susLink ??= true;
	FlxG.save.data.holdCovers ??= true;
	FlxG.save.data.middleScroll ??= false;
	FlxG.save.data.touchGameplay ??= mobile;
	FlxG.save.flush();

	FlxG.plugins.list.push(forcedTweenManager);

	Flags.VERSION_MESSAGE = Flags.MOD_NAME + ' v' + version;

	if (blehFlag) {
		devWatermark = new TextField();
		devWatermark.defaultTextFormat = new TextFormat(Paths.getFontName(Paths.font('PAPYRUS.TTF')), 128, 0xFFFFFF, true, null, null, null, null,
			TextFormatAlign.LEFT);
		devWatermark.y = 0;
		devWatermark.selectable = false;
		devWatermark.mouseEnabled = false;
		devWatermark.autoSize = 1; // left
		devWatermark.text = 'Take a look, yall:\nIMG_0437.jpg';
		devWatermark.x = dvdPos.x = (window.width - devWatermark.width) / 2;
		devWatermark.y = dvdPos.y = (window.height - devWatermark.height) / 2;

		// cache for reasons im not getting into
		dvdPos.w = devWatermark.width;
		dvdPos.h = devWatermark.height;

		dvdPos.speed = 200;
	}

	for (i in KeybindsOptions.defaultCategories) {
		if (i.name == 'category.notes') {
			for (j in i.settings) {
				j.sparrowIcon = 'menus/note_keys';
			}
		}
	}
}

if (blehFlag) {
	var dvdPos = {
		x: 0,
		y: 0,
		w: 1,
		h: 1,
		vx: 1,
		vy: 1,
		speed: 0
	};
	function update(elapsed) {
		dvdPos.x += dvdPos.vx * dvdPos.speed * elapsed;
		dvdPos.y += dvdPos.vy * dvdPos.speed * elapsed;

		if (dvdPos.x < 0) {
			dvdPos.vx = 1;
			dvdPos.x = 0;
		}
		if (dvdPos.x > (window.width - dvdPos.w)) {
			dvdPos.vx = -1;
			dvdPos.x = (window.width - dvdPos.w);
		}
		if (dvdPos.y < 0) {
			dvdPos.vy = 1;
			dvdPos.y = 0;
		}
		if (dvdPos.y > (window.height - dvdPos.h)) {
			dvdPos.vy = -1;
			dvdPos.y = (window.height - dvdPos.h);
		}

		devWatermark.x = dvdPos.x;
		devWatermark.y = dvdPos.y;
	}
}
// will make a new tween that does not freeze when FunkinParentDisabler exists
public static function forceTween() {
	return forcedTweenManager;
}

public static function getGroupWidth(group) {
	var minX = null;
	var value = 0;
	for (member in group.members) {
		if (member == null)
			continue;

		value = Math.max(value, member.x + member.width);
		minX ??= member.x;
		minX = Math.min(minX, member.x);
	}
	return value - minX;
}

public static function getGroupHeight(group) {
	var minY = null;
	var value = 0;
	for (member in group.members) {
		if (member == null)
			continue;

		value = Math.max(value, member.y + member.height);
		minY ??= member.y;
		minY = Math.min(minY, member.y);
	}
	return value - minY;
}

// to do: add these everywhere
public static function findParentNote(n) {
	if (!n.isSustainNote) {
		return n;
	}
	return n.sustainParent;
}

public static function findTailNote(n) {
	if (!n.isSustainNote) {
		n = n.nextNote;

		// not the same note
		if (!n.isSustainNote)
			return;
	}

	var scan = n;
	while (scan.nextSustain != null) {
		scan = scan.nextSustain;
		// prevNote fur sustains will always be a sustain, unless its the head (the parent)
	}
	return scan;
}

// thanks hifish
public static function getModKeyName(name:String, ?idx:Int) {
	idx ??= 0;
	return CoolUtil.keyToString(ControlsUtil.getControl(PlayerSettings.solo.controls, name).inputs[idx].inputID);
}

import flixel.input.FlxPointer;

// #if flixel will not work as it is always "git"
public static function touchPos(fuck:FlxPointer) {
	if (FlxG.VERSION.minor >= 9)
		return FlxPoint.get(fuck.viewX, fuck.viewY);
	else
		return FlxPoint.get(fuck.screenX, fuck.screenY);
}

// returns an aray of rgb channels (normalized if second arg is true)
// should automatically support alpha (i hope)
public static function getRGBArray(col:FlxColor, ?norm:Bool) {
	// in case i forget
	if (col == -1)
		col = 0xffffff;
	norm ??= true;
	var res = [(col >> 16) & 0xff, (col >> 8) & 0xff, (col >> 0) & 0xff];
	// is 24 bit (alpha channel)
	if ((col != col & 0xffffff))
		res.push((col >> 24) & 0xff);
	if (norm) {
		for (x => i in res)
			res[x] = i / 255;
	}
	return res;
}

// returns luminance of color, 0-1
public static function getLuminance(col:FlxColor) {
	return (0.2126 * (((col >> 16 & 0xff)) / 255) // red
		+ 0.7152 * (((col >> 8) & 0xff) / 255) // green
		+ 0.0722 * (((col >> 0) & 0xff) / 255) // blue
	);
}

/*
 gets all addon overrides of a file (idk how 2 explain it)
 rn only meant for text/data files
 */
public static function getAddonFileContents(path:String, ?options) {
	options ??= {baseFirst: true};
	var contents = [];
	var array = ModsFolder.getLoadedMods();
	if (options.noBase || options.baseFirst) {
		array.remove(ModsFolder.currentModFolder, true);
		if (options.baseFirst) array.insert(0, ModsFolder.currentModFolder);
	}
	if (options.reverse) array.reverse();
	for (i in array) {
		var p = Path.withoutExtension(path);
		var e = Path.extension(path);
		var libPath = p + '/LIB_' + i + (e.length > 0 ? ('.' + e) : '');
		if (Assets.exists(libPath)) {
			//trace('exists', libPath);
			contents.push(Assets.getText(libPath));
		}
	}
	return contents;
}

function onScriptCreated(script:Script, type:String) {
	script.set('BlendMode', BlendMode);
}