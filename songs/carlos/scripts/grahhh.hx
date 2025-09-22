var sway = false;

function postUpdate(elapsed) {
    for (fuck in strumLines.members) {
        for (i in fuck.members) {
            i.angle = sway ? FlxMath.fastSin(curBeatFloat * Math.PI * 0.5) * 4 : 0;
        }
    }
}

function toggleSwaying() {
    sway = !sway;
}