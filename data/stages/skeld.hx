if (Options.lowMemoryMode) {
	disableScript();
	return;
}
var particleGroup = new FlxSpriteGroup();

function postCreate() {
	insert(members.indexOf(bg), particleGroup);

	for (i in 0...50) {
		var part = particleGroup.recycle(FunkinSprite);
		part.loadSprite(Paths.image('stages/skeld/stupid FUCKING particle'));
		part.moves = true;
		particleGroup.add(part);
		part.antialiasing = true;

		resetParticle(part);
	}
}

function resetParticle(part) {
	var size = FlxG.random.float(0.1, 1);

	part.setPosition(FlxG.random.int(0, FlxG.width * 1.5), FlxG.random.int(0, FlxG.height * 0.8));
	part.zoomFactor = size * 0.4;
	part.scale.set(size, size);
	part.scrollFactor.set(size * 0.5, size * 0.5);
	part.updateHitbox();
	part.velocity.x = 600 * size;
}

function postUpdate(e) {
	particleGroup.forEachAlive((p) -> {
		if (p.x >= FlxG.width * 2) {
			resetParticle(p);
			p.x = 0;
		}
	});
}
