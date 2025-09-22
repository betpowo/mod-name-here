import haxe.io.Path;

var defaultUIs = ['', 'pixel'];

// force these scripts to exist if they werent found
function create() {
	for (name in ['Camera Movement', 'Camera Zoom']) {
		if (scripts.getByName(name + '.hx') == null) {
			// trace('bah'+name);
			importScript('data/events/' + name);
		}
	}
}

function postCreate() { // ???????????????
	healthBar.unbounded = true;
	if (defaultUIs.indexOf(currentUI) == -1)
		return;
	for (i in iconArray) {
		i.bump = () -> {
			var iconScale = 1.2;
			i.scale.set(i.defaultScale * iconScale, i.defaultScale * iconScale);
		}
		i.updateBump = () -> {
			var iconLerp = 0.15 * (FlxG.elapsed / (1 / 60));
			var scaleX = FlxMath.lerp(Std.int(i.frameWidth * i.scale.x), i.defaultScale * i.frameWidth, iconLerp);
			var scaleY = FlxMath.lerp(Std.int(i.frameHeight * i.scale.y), i.defaultScale * i.frameHeight, iconLerp);
			i.setGraphicSize(scaleX, scaleY);
			if (i.isPlayer)
				i.extraOffsets.x *= -1;
			i.updateHitbox();
			i.height = i.defaultScale * i.frameHeight; // FUCK. downscroll
			var diffX = (i.scale.x - i.defaultScale);
			var diffY = (i.scale.y - i.defaultScale);
			i.offset.x += (i.extraOffsets.x * 0.5) * diffX * 0.5;
			i.offset.y += (i.frameHeight + (i.extraOffsets.y * 0.5)) * diffY * 0.5;
			if (i.isPlayer) {
				i.offset.x += (26 / i.defaultScale) * diffX;
			} else {
				i.offset.x -= (26 / i.defaultScale) * diffX;
			}
			if (i.isPlayer)
				i.extraOffsets.x *= -1;
		}
	}
	for (i in [scoreTxt, missesTxt, accuracyTxt]) {
		i.x = Std.int(i.x);
	}
	PauseSubState.script = 'data/states/pause/default';
}

function onPostCountdown(e) {
	if (defaultUIs.indexOf(currentUI) == -1)
		return;
	if (e.spriteTween != null) {
		e.spriteTween.cancel();
		var ev = e;
		e.spriteTween = FlxTween.tween(e.sprite, {alpha: 0}, Conductor.crochet * 0.0009, {
			ease: FlxEase.cubeInOut,
			onComplete: (_) -> {
				ev.sprite.destroy();
				remove(ev.sprite, true);
			}
		});
		e.sprite.camera = camHUD;
	}
}

function onChangeCharacter(e) {
	if (defaultUIs.indexOf(currentUI) == -1 || !e.event.params[3])
		return;

	if (e.memberIndex == 0) {
		if (e.strumIndex >= 2)
			return;
		var opp = (e.strumIndex == 0);
		var icon = opp ? iconP2 : iconP1;
		icon.setIcon(e?.character?.getIcon() ?? 'face');
		if (Options.colorHealthBar) {
			// ugly
			if (opp)
				healthBar.createColoredEmptyBar(e.character?.iconColor ?? (PlayState.opponentMode ? 0xFF66FF33 : 0xFFFF0000));
			else
				healthBar.createColoredFilledBar(e.character?.iconColor ?? (!PlayState.opponentMode ? 0xFF66FF33 : 0xFFFF0000));

			healthBar.updateFilledBar();
		}
	}
}