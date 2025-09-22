import funkin.backend.MusicBeatTransition;

function create(e) {
	if (e.cancelled)
		return;
	if (currentUI == 'pixel')
		e.music = 'breakfast-pixel';
	if (PlayState.difficulty.toLowerCase() == 'pico')
		e.music = 'breakfast-pico';
}

function postCreate() {
	if (deathCounter == null)
		return;
	deathCounter.text = PlayState.deathCounter + ' Blue Balls';
	levelDifficulty.text = 'by ' + (PlayState.SONG.meta?.customValues?.composer ?? 'Unknown');
	for (label in [deathCounter, levelDifficulty]) {
		label.x = FlxG.width - (label.width + 20);
	}
}

function onChangeItem(e) {
	CoolUtil.playMenuSFX();
}
