function create() {
    camGame.bgColor = 0xFFffcc66;
    //importScript('interfaces/mnh');
    //importScript('data/scripts/forceFPSshadow');
}
function destroy() {
    camGame.bgColor = 0;
}

function stepHit(s) {
    if (Options.lowMemoryMode) return;
    lights.alpha = FlxG.random.float(0.8, 1.0);
}