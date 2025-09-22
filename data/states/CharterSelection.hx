import hxvlc.flixel.FlxVideoSprite;
import funkin.menus.ui.Alphabet;
import funkin.menus.ui.effects.ShakeEffect;
import funkin.menus.ui.effects.ColorWaveEffect;
import funkin.menus.ui.effects.WaveEffect;
import funkin.savedata.FunkinSave;

var newOption;
function postCreate() {
    insert(1, video = new FlxVideoSprite());
    video.antialiasing = true;
    video.load(Paths.video('hijos de puta'), ['input-repeat=9999']);
    video.scrollFactor.set();

    // fuck yuo
    if (FunkinSave.getSongHighscore('weird-song', 'normal', null, []).score <= 0) {
        tree[0].remove(
            tree[0].members[
                tree[0].songList.indexOf('weird-song') + 1
                                                /*new + separator*/
            ],
        true);
    }


    video.bitmap.onPlaying.add(() -> {
        replaceSongs();
        for (k=>i in tree[0].members) {
            // do not affect new
            if (k == 0) {
                i.__text.text = "i'm killing myself";
                i.__text.effects.push(new WaveEffect(0, 7, 7));
                i.iconSpr.shader = new CustomShader('adjustColor');
                i.iconSpr.shader.hue = 0;
                newOption = i;
                continue; 
            }
            addRandomEffect(i.__text);
        }
    });

    video.play();
}

var did = true;
function replaceSongs() {
    if (did == (did = true)) return;
    while (tree[0].members.length > 1) {
        for (k => i in tree[0].members) {
            //trace(k);
            //trace(i.__text.text);
            if (k == 0) {
                continue; 
            }
            tree[0].remove(i, true);
            i.kill();
            i.destroy();
        }
    }

    tree[0].freeplayList.songs = [];
    tree[0].freeplayList.getSongsFromSource(false);

    for (i => s in tree[0].freeplayList.songs) tree[0].add(tree[0].makeSongOption(s));

    tree[0].curSelected = 0;
    tree[0].changeSelection(0, true);

}

var prevPosition = 0;
var time = 0.0;
function postUpdate(elapsed) {
    time += elapsed;
 	if (video.bitmap != null && video.bitmap.bitmapData != null)
 	{
 		final scale:Float = Math.min(FlxG.width / video.bitmap.bitmapData.width, FlxG.height / video.bitmap.bitmapData.height);

 		video.setGraphicSize(video.bitmap.bitmapData.width * scale, video.bitmap.bitmapData.height * scale);
 		video.updateHitbox();
 		video.screenCenter();
 	}

    if (prevPosition > (prevPosition = video.bitmap.position)) {
        onLoop();
    }

    if (newOption != null) {
        newOption.iconSpr.shader.hue += elapsed * 360;
        if (newOption.iconSpr.shader.hue > 360) newOption.iconSpr.shader.hue -= 360;
        newOption.__text.color = FlxColor.fromHSB(newOption.iconSpr.shader.hue + 60, 1, 1);
    }

    if (tree[1] != null) {
        for (k => i in tree[1].members) {
            if (i.__text == null) continue;
            i.__text.scale.set(1 + (Math.cos(time * 35) * 0.2), 1 + (Math.sin(time * 35) * 0.2));
            if (FlxG.random.bool(5)) {
                i.__text.angle += FlxG.random.float(-1, 1) * 6;
            }
        }
    }

}

function onLoop() {
    //trace('maybe?????');

    video.bitmap.rate += 0.1;
}

function addRandomEffect(a) {
    if (!(a is Alphabet)) return;
    if (FlxG.random.bool(67)) {
        for (i in 0...7) {
            var effect = new ColorWaveEffect(FlxG.random.color(), FlxG.random.color(), FlxG.random.float(4, 69));
            var min = FlxG.random.int(0, 16);
            effect.addRegion(min, Math.min(min + FlxG.random.int(0, 8), a.text.length));
            effect.speed = FlxG.random.float(0.5, 69);
            a.effects.push(effect);
        }
    }
    if (FlxG.random.bool(20)) {
        for (i in 0...7) {
            var effect = new ShakeEffect(FlxG.random.float(0, 10), FlxG.random.float(0, 10));
            var min = FlxG.random.int(0, 16);
            effect.addRegion(min, Math.min(min + FlxG.random.int(0, 8), a.text.length));
            a.effects.push(effect);
        }
    }
    if (FlxG.random.bool(67)) {
        for (i in 0...7) {
            var effect = new WaveEffect(FlxG.random.float(-20, 20), FlxG.random.float(-20, 20), FlxG.random.float(1, 69));
            var min = FlxG.random.int(0, 16);
            effect.addRegion(min, Math.min(min + FlxG.random.int(0, 8), a.text.length));
            effect.speed = FlxG.random.float(0.5, 69);
            a.effects.push(effect);
        }
    }

    if (FlxG.random.bool(30)) {
        a.font = 'normal';
    }
}