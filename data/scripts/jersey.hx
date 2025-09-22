var doVocals = FlxG.save.data.breathing;

var kick = FlxG.sound.load(Paths.sound('jersey/kick'));
var squeak1 = FlxG.sound.load(Paths.sound('jersey/squeak1'));
var squeak2 = FlxG.sound.load(Paths.sound('jersey/squeak2'));
if (doVocals) {
    var pluh = FlxG.sound.load(Paths.sound('jersey/pluh'));
    var eh = FlxG.sound.load(Paths.sound('jersey/eh'));
}

var kickSteps = [0, 4, 8, 11, 14];
function stepHit(curStep) {
    if (curStep < 0 || noNotes()) return;
    if (curStep % 2 == 0) {
        if (curStep % 4 == 0) squeak1.play(true);
        else squeak2.play(true);
    }
    if (kickSteps.indexOf(curStep - (curMeasure * Conductor.stepsPerBeat * Conductor.beatsPerMeasure)) != -1) {
        kick.play(true);
        inst.volume = 0.0;
    }
}
function onNoteHit(e) {
    if (!doVocals) return;

    e.cancelVocalsUnmute();
    e.note.strumLine.vocals.volume = 0;
    vocals.volume = 0;
    if (e.note.isSustainNote) return;

    var snd = e.note.strumLine.opponentSide ? pluh : eh;
    snd.play(true);
    snd.pitch = FlxG.random.float(0.3, 2);
}
function postUpdate(elapsed) {
    inst.volume = FlxMath.bound(inst.volume + (elapsed / (Conductor.crochet * 0.001)), 0, 1);
}
var firstTime = null;
function onNoteCreation(e) {
    firstTime ??= inst.length;
    firstTime = Math.min(firstTime, e.note.strumTime);
}
function noNotes() {
    if (firstTime != null) {
        var uh = Math.floor((firstTime - 10) / (Conductor.crochet));
        return curBeat < uh;
    }
    return false;
}