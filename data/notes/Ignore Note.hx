final _type = 'Ignore Note';

function onPostNoteCreation(e) {
	if (e.noteType == _type) {
		e.note.avoid = true;
		e.note.earlyPressWindow = e.note.latePressWindow = -1;
	}
}

function onPlayerHit(e) {
	if (e.note.noteType == _type) {
		e.deleteNote = false;
		e.cancelStrumGlow();
		e.cancel();
		e.note.wasGoodHit = false;
		e.autoHitLastSustain = false;
		e.cancelVocalsUnmute();
		e.showRating = false;
	}
}

function onNoteHit(e) {
	if (e.note.noteType == _type) {
		e.showSplash = false;
	}
}

function onPlayerMiss(e) {
	if (e.noteType == _type) {
		e.cancel();
		if (e.deleteNote && e.note != null && e.note.strumLine != null)
			e.note.strumLine.deleteNote(e.note);
	}
}
