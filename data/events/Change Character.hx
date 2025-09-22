// (originally) by rodney, imaginative fella
import haxe.io.Path;
import funkin.backend.scripting.Script;
import funkin.backend.scripting.DummyScript;

var dummy = new FunkinSprite();

function postCreate() {
	add(dummy);
	for (event in events) {
		if (event.name == 'Change Character') {
			var ch = event.params[1] ?? 'bf';
			var xml = Character.getXMLFromCharName(ch);
			var sprite = xml.get('sprite') ?? ch;
			
			dummy.loadGraphic(Assets.exists(Paths.image('characters/' + sprite))?Paths.image('characters/' + sprite):Paths.image('characters/' + sprite + '/spritemap1'));
			dummy.graphic.destroyOnNoUse = false;
			dummy.graphic.useCount++;

			dummy.drawComplex(camGame);
		}
	}
	remove(dummy, true);
	dummy.destroy();
}

function onEvent(event) {
	switch (event.event.name) {
		case 'Change Character':
			var strumIndex = event.event.params[0];
			var ch = event.event.params[1] ?? 'bf';
			var memberIndex = event.event.params[2] ?? 0;
			var char = strumLines.members[strumIndex].characters[memberIndex];
			var xml = Character.getXMLFromCharName(ch);
			if (char != null) {
				try {
					if (char.scripts != null) {
						char.scripts.call('destroy');
						for (i in char.scripts.scripts) {
							char.scripts.scripts.remove(i, true);
							i.destroy();
						}
					}
					char.curCharacter = ch;
					char.scale.set(1, 1);
					char.antialiasing = true;
					for (i in char.getNameList()) {
						char.removeAnim(i);
					}
					char.applyXML(xml);
					char.dance();
					char.script = Script.create(Paths.script(Path.withoutExtension(Paths.xml('characters/' + char.curCharacter)), null, true)) ?? new DummyScript(char.curCharacter);

				} catch (e:Dynamic) {
					trace(e);
				}
			} else {
				var strumLine = strumLines.members[strumIndex];
				var strumData = strumLine.data;
				var charPosName = strumData.position == null ? (switch (strumData.type) {
					case 0: "dad";
					case 1: "boyfriend";
					case 2: "girlfriend";
				}) : strumData.position;
				var newChar = new Character(0, 0, stage.isCharFlipped(stage.characterPoses[ch] != null ? ch : charPosName, strumData.type == 1));
				stage.applyCharStuff(newChar, charPosName, memberIndex);
				strumLine.characters.insert(memberIndex, newChar);
			}
			scripts.call('onChangeCharacter', [
				{
					event: event.event,
					character: char,
					strumIndex: strumIndex,
					memberIndex: memberIndex
				}
			]);
	}
}