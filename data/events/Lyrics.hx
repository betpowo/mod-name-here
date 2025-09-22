var text = new FunkinText();
var textBG = new FunkinSprite();

function postCreate() {
	textBG.makeSolid(1, 1, 0xffffffff);
	textBG.blend = 14;
	textBG.alpha = 0.6;

	text.size = 32;
	text.alignment = 'center';
	for (i in [textBG, text]) {
		add(i);
		i.camera = camHUD;
	}

	textBG.visible = text.visible = false;
}

function onEvent(e) {
	if (e.event.name != 'Lyrics' || !FlxG.save.data.enableSubs) return;
	var p = e.event.params;
	var sub = p[0] ?? '';
	var maxWidth = FlxG.width * 0.9;
	if (sub != '') {
		textBG.visible = text.visible = true;
		text.fieldWidth = -1;
		text.text = sub;
		if (text.width > maxWidth) {
			text.fieldWidth = maxWidth;
		}
		text.size = p[1] ?? 32;
		text.color = p[2] ?? 0xffffff;

		text.updateHitbox();
		text.screenCenter();
		text.y = FlxG.height - 150 - text.height;

		scripts.call('onLyricSetup', [
			{
				params: p,
				text: text,
				background: textBG
			}
		]);
	} else {
		textBG.visible = text.visible = false;
	}
}

var padding:Float = 16;

function update(e) {
	textBG.scale.set(text.width + padding, text.height + padding);
	textBG.updateHitbox();
	textBG.setPosition(text.x - (padding / 2), text.y - (padding / 2));
}