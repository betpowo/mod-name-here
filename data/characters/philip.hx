var toAdd:Bool = true; // Using this just to make sure

function update(elpased) {
	if (toAdd) {
		toAdd = false;
		if (PlayState.instance.boyfriend.curCharacter == this.curCharacter) {
			GameOverSubstate.script = 'data/characters/_philip-dead';
			disableScript();
		}
	}
}
