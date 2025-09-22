function rareDeath() {
    if (!canDie) return;
    if (!FlxG.random.bool(0.1)) return;
    health = -999; // ✔
}

function do1up() {
    displayRating('game/score/1up');
    var popup = CoolUtil.last(comboGroup.members); // comboGroup.members.last(), but i cant do that here since im on a script

    popup.scale.set(0.7, 0.7);
    popup.antialiasing = true;
    popup.updateHitbox();

    popup.setPosition(boyfriend.x + ((boyfriend.frameWidth - popup.width) * 0.5), boyfriend.y + boyfriend.globalOffset.y - 100);

    boyfriend.colorTransform.color = 0x66ff66;
    FlxTween.tween(boyfriend.colorTransform, {
        redMultiplier: 1, greenMultiplier: 1, blueMultiplier: 1,
        redOffset: 0,     greenOffset: 0,     blueOffset: 0
    }, 0.5);
}