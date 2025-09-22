import funkin.backend.system.macros.GitCommitMacro;
import funkin.menus.credits.CreditsMain;
import funkin.backend.utils.WindowUtils;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import funkin.backend.assets.ModsFolder;
import funkin.backend.MusicBeatTransition;
import funkin.options.OptionsMenu;
import flixel.tweens.FlxTweenManager;
import funkin.backend.system.Flags;

static var Mod_Name_Here__firstBoot:Bool = true;
public static var currentUI:String = '';
public static final version:String = Flags.customFlags['MOD_VERSION'];
public static final mobile:Bool = FlxG.onMobile;

function preStateSwitch() {
	currentUI = '';
	if (Mod_Name_Here__firstBoot != (Mod_Name_Here__firstBoot = false)) {
		FlxG.game._requestedState = new ModState('StartSplash');
		return;
	}
}

function destroy() {
	FlxG.camera.bgColor = 0;
	// Main.framerateSprite.codenameBuildField.text = 'Codename Engine ' + Main.releaseCycle + '\nVersion ' + Main.releaseVersion;

	if (forcedTweenManager != null) {
		FlxG.plugins.remove(forcedTweenManager);
	}
	// todo: comment this out
	Mod_Name_Here__firstBoot = true;
}

var forcedTweenManager = new FlxTweenManager();

function new() {
	FlxG.save.data.compact ??= false;
	FlxG.save.data.pbot ??= true;
	FlxG.save.data.cbreak ??= false;
	FlxG.save.data.enableSubs ??= true;
	FlxG.save.data.susLink ??= true;
	FlxG.save.data.holdCovers ??= true;
	FlxG.save.data.middleScroll ??= false;
	FlxG.save.data.touchGameplay ??= mobile;
	FlxG.save.flush();

	FlxG.plugins.list.push(forcedTweenManager);
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

	var scan = n;
	while (scan.isSustainNote) {
		scan = scan.prevNote;
		// prevNote fur sustains will always be a sustain, unless its the head (the parent)
	}
	return scan;
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
