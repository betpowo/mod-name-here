// Took the one inside the BaseGame source as a base  - Nex

var deathSpriteNene = null;
function postCreate() {
	if (PlayState.instance == null) return;

	var game = PlayState.instance.subState;

	deathSpriteRetry = new FunkinSprite(0, 0, Paths.image("characters/picoStuff/picoGameover/Pico_Death_Retry"));
	deathSpriteRetry.animation.addByPrefix('idle', "Retry Text Loop0", 24, true);
	deathSpriteRetry.animation.addByPrefix('confirm', "Retry Text Confirm0", 24, false);
	//FlxG.debugger.track(deathSpriteRetry);
	this.animation.callback = function(name:String, frameNumber:Int, frameIndex:Int) {
		if (name == "firstDeath" && frameNumber == 35) {
			game.add(deathSpriteRetry);
			deathSpriteRetry.animation.play('idle');
			deathSpriteRetry.visible = true;
			if(!game.isEnding) CoolUtil.playMusic(Paths.music(game?.gameOverSong));
			// force the deathloop to play in here, since we are starting the music early it
			// doesn't check this in gameover substate !
			// also no animation suffix 🤔
			playAnim("deathLoop", true, "DANCE");

			deathSpriteRetry.x = this.x + globalOffset.x + 380;
			deathSpriteRetry.y = this.y + globalOffset.y + 42;
			// trace('Pico x: ' + this.x + ', y: ' + this.y);
			// trace("Death sprite x: " + deathSpriteRetry.x + ", y: " + deathSpriteRetry.y);
		}
	}

	var gf = PlayState.instance.gf;
	if(gf == null || gf.curCharacter != "nene") return;
	deathSpriteNene = new FunkinSprite(0, 0, Paths.image("characters/picoStuff/picoGameover/NeneKnifeToss"));
	deathSpriteNene.x = gf.x + gf.globalOffset.x + 280;
	deathSpriteNene.y = gf.y + gf.globalOffset.y + 70;
	deathSpriteNene.antialiasing = gf.antialiasing;
	deathSpriteNene.animation.addByPrefix('throw', "knife toss0", 24, false);
	deathSpriteNene.animation.finishCallback = function(name:String) {
		deathSpriteNene.visible = false;
	}

	game.add(deathSpriteNene);
	deathSpriteNene.animation.play("throw");
}

function onPlayAnim(event) {
	switch(event.animName) {
		case 'deathConfirm':
			deathSpriteRetry.animation.play('confirm');
			// I think the glow makes the overall animation larger,
			// but a plain FlxSprite doesn't have an animation offset option so we do it manually.
			deathSpriteRetry.x -= 250;
			deathSpriteRetry.y -= 200;
			event.animName = 'deathLoop';
	}
}

function update(_) {
	if (PlayState.instance == null) return;
	deathSpriteRetry.antialiasing = this.antialiasing;
	deathSpriteRetry.scale = this.scale;
	deathSpriteRetry.scrollFactor = this.scrollFactor;
	deathSpriteRetry.alpha = this.alpha;
	deathSpriteRetry.visible = this.visible;
}

function onJPEGSetup() {
	for (i in [deathSpriteNene, deathSpriteRetry]) {
		if (i != null) {
			i.shader = new CustomShader('jpeg');
			i.shaderEnabled = true;
		}
	}
}