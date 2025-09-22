import openfl.ui.Mouse;
import funkin.backend.chart.Chart;

var house = null;
var doorHitbox;

function postCreate() {
    house = scripts.getByName('outside.hx').get('house');
    doorHitbox = new FlxSprite(house.x + 150, house.y + 275).makeSolid(111, 111, -1);
    doorHitbox.scrollFactor.set(house.scrollFactor.x, house.scrollFactor.y);
    add(doorHitbox);
    doorHitbox.visible = false;

    FlxG.mouse.visible = true;
    Mouse.cursor = 'arrow';
}

function the(enable) {
    // weird song pico mix isnt real yet (may / 10 / 2025)
    // dont worry ill make it soon
    if (Chart.loadChartMeta('weird-song').difficulties.indexOf(PlayState.difficulty) == -1) return;

    if (Std.int(enable) == 1) {
        house.animation.play('action', true);
        house.animation.finishCallback = () -> {
            house.animation.play('action-loop', true);
            house.animation.finishCallback = null;
        };
    } else {
        house.animation.play('action', true, true);
        house.animation.finishCallback = () -> {
            house.animation.play('idle', true);
            house.animation.finishCallback = null;
        };
    }
}
var overlapState = false;
var knocks = 0;
var fuckedUp = false;
function update(elapsed) {
    if (fuckedUp) return;
    if(FlxG.mouse.overlaps(doorHitbox) && StringTools.startsWith(house.animation.name, 'action') && StringTools.startsWith(dad.animation.name, 'die')) {
        if (!overlapState) {
            overlapState = true;
            Mouse.cursor = 'button';
        }
        if (FlxG.mouse.justPressed) {
            knocks += 1;
            if (knocks == 3) {
                if (FlxG.sound.music != null)
                {
                    for (strumLine in strumLines.members) strumLine.vocals.pause();
                    FlxG.sound.music.pause();
                    vocals.pause();
                }
                camGame.visible = camHUD.visible = false;
                new FlxTimer().start(2, (_) -> {
                    PlayState.loadSong('weird-song', PlayState.difficulty, false, false);
                    FlxG.switchState(new PlayState());
                });
                fuckedUp = true;
                Mouse.cursor = 'arrow';
            }
            FlxG.sound.play(Paths.sound('knock' + FlxG.random.int(1, 3)), 0.8);
        }
    } else {
        if (overlapState) {
            overlapState = false;
            Mouse.cursor = 'arrow';
        }
    }
}