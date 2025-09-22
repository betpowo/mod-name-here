import funkin.backend.MusicBeatTransition;

function postCreate() {
	if (selectCall == null) {
		selectCall = (e) -> {
			if (e.name == 'Change Options') {
				e.cancel();
				FlxG.switchState(new ModState('mnh/Options', {
					exitCallback: (_) -> {
						FlxG.sound.music.stop();
						FlxG.switchState(new PlayState());
					}
				}));
			}
			if (e.name == 'Exit to menu') {
				MusicBeatTransition.script = 'data/states/StickerTransition';
			}
		}
	}
}
