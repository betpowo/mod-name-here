import funkin.menus.ModSwitchMenu;

function create() {
	add(new FunkinSprite(0, 0, Paths.image('UPDATE YUOR FUCJIN codename ENGINE')));
	FlxG.sound.play(Paths.sound('sad_trombone'));
}

function update(elapsed) {
	if (controls.ACCEPT) {
		CoolUtil.openURL('https://codename-engine.com');
	}
	if (controls.SWITCHMOD) {
		openSubState(new ModSwitchMenu());
		persistentUpdate = false;
		persistentDraw = true;
	}
}
