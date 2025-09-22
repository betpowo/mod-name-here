final _type = 'Hey!';

function onNoteHit(e) {
	if (e.note.noteType == _type) {
		e.cancelAnim();
		for (c in e.characters) {
			if (c != null) {
				c.playAnim('hey', true, 'SING');
			}
		}
	}
}
