var tauntBG = new FunkinSprite();
function postCreate() {
	tauntBG.frames = this.frames;
	tauntBG.addAnim('idle', 'bg taunt', 0, true);
	tauntBG.playAnim('idle', true);
	tauntBG.updateHitbox();
}

function draw(_) {
	if (animation.name == 'taunt')  {
		tauntBG.antialiasing = this.antialiasing;
		tauntBG.draw();
	}
}

function update(e) {
	tauntBG.setPosition(x + globalOffset.x - 170, y + globalOffset.y - 160);
}

function onPlayAnim(e) {
	if (e.animName == 'taunt') {
		e.startingFrame = FlxG.random.int(0, this.animation._animations.get('taunt').numFrames);
		
		tauntBG.scale.set(0.8, 0.8);
		FlxTween.tween(tauntBG.scale, {x: 1, y: 1}, 0.2, {ease: FlxEase.bounceOut});
	}
}