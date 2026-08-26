import funkin.menus.ui.effects.ColorWaveEffect;
import funkin.menus.ui.effects.WaveEffect;

function postCreate() {

    var doExplosion = true;
    // category titles arent available as public objects
    forEachAlive((a) -> {
        if (!(a is Alphabet)) return;
        if (a.text.toLowerCase() == 'mod name here') { // oh my god bruh
            //a.angle = 4;
            ah = new WaveEffect(0, 5, 8);
            oh = new ColorWaveEffect(0xffffff, 0xfffffff, 4);
            a.effects.push(ah);
            a.effects.push(oh);

            if (!doExplosion) return;

            var initY = a.y;
            a.y = -400;
            a.angle = 1000;
            a.scale.set(0.2, 2.2);

            var explosion = new FunkinSprite();
            explosion.loadSprite(Paths.image('explosion'));
            explosion.addAnim('boom', '', 12, false);
            explosion.playAnim('boom', true);
            explosion.setGraphicSize(FlxG.width * 1.2, 400);
            explosion.updateHitbox();
            explosion.screenCenter();
            explosion.y = FlxG.height - 222;
            explosion.scrollFactor.set(0, 0.1);

            awesomeTween = FlxTween.tween(a, {y: initY, angle: 0}, 1, {ease: FlxEase.sineIn, onComplete: (_) -> {
                FlxTween.tween(a.scale, {x: 1, y: 1}, 1, {ease: FlxEase.elasticOut});
                FlxG.sound.play(Paths.sound('deltaruneExplosion'), Options.volumeSFX);
                add(explosion);
            }});
        }
    });
}

function postUpdate(e) {
    if (alphabets.members[curSelected] != null) {
		var alphabet = alphabets.members[curSelected];
		alphabet.p2Selected = p2Selected;
		alphabet.alpha = 1;
		var minH = FlxG.height / 2;
		var maxH = alphabets.members[alphabets.length-1].y + (alphabets.members[alphabets.length-1].height * 2) - (FlxG.height / 2);
		if (minH < maxH)
			camFollow.setPosition(FlxG.width / 2, CoolUtil.bound(alphabet.y + (alphabet.height / 2), minH, maxH));
		else
			camFollow.setPosition(FlxG.width / 2, FlxG.height / 2);
	}
    oh.color1 = FlxColor.fromHSB(Math.abs(Conductor.songPosition * 0.001) * 60, 0.6, 1);
    oh.color2 = FlxColor.fromHSB(Math.abs(Conductor.songPosition * 0.001) * 60, 0.2, 1);
}

function destroy() {
    if (awesomeTween != null) {
        awesomeTween.cancel();
    }
}