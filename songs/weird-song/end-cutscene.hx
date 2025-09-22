import haxe.io.Path;

var graphPaths = [];
var curSelected = -1;

function getImages(pre) {
    var res = [];
    for (c in Paths.getFolderContent('songs/'+PlayState.SONG.meta.name+'/storyboard', true, true)) {
        if (StringTools.contains(Path.withoutDirectory(c), pre)) {
            res.push(c);
        }
    }
    return res;
}

var music = FlxG.sound.load(Paths.music('sprunki-type-beat'));
var sprite = new FunkinSprite();

var camera = new FlxCamera();
function create() {
    camera.bgColor = 0x0;
    FlxG.cameras.add(camera, false);
    graphPaths = getImages('outro-');

    for (i in graphPaths) {
        PlayState.instance.graphicCache.cache(Paths.getPath(i));
    }

    sprite.antialiasing = true;
    sprite.camera = camera;
    add(sprite);

    changeSelection();

    music.looped = true;
    music.play(true);
}
var maxed = false;
function changeSelection() {
    curSelected++;

    if (curSelected >= graphPaths.length || maxed) {
        maxed = true;
        remove(sprite);
        FlxTween.tween(music, {pitch: 0}, 0.3);
        new FlxTimer().start(2, (_) -> {
            close();
        });
        return;
    }

    sprite.loadSprite(Paths.getPath(graphPaths[curSelected]));
    sprite.setGraphicSize(FlxG.width, FlxG.height);
    sprite.updateHitbox();
    sprite.screenCenter();

    if (curSelected != 0) {
        FlxG.sound.play(Paths.sound('dialogue/next'));
    }
}

function update(e) {
    if (FlxG.mouse.justPressed) changeSelection();
}

function destroy() {
    FlxG.cameras.remove(camera);
    sprite.destroy();
    music.stop();
    FlxG.sound.list.remove(music);
    music.destroy();
}