function new() {
	if (FlxG.save.data.choiceExample == 'jersey') {
		importScript('data/scripts/jersey');
	}
	if (mobile && FlxG.save.data.touchGameplay) {
		importScript('data/scripts/mobile');
	}
}