var toAdd:Bool = true;
function update(elapsed) {
	if (toAdd) {
		if (PlayState.instance.boyfriend.curCharacter == this.curCharacter) {
			PlayState.instance.lossSFX = 'fnf_loss_sfx-pico';
			PlayState.instance.gameOverSong = 'gameOver-pico';
			PlayState.instance.retrySFX = 'gameOverEnd-pico';
			toAdd = false;
			disableScript();
		}
	}
}
