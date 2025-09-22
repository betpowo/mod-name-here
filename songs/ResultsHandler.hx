import funkin.backend.MusicBeatState;
import funkin.savedata.FunkinSave;
import funkin.game.ComboRating;
import funkin.savedata.HighscoreChange;
import Date;
import Type;

var data = [
	'total' => 0,
	'max' => 0,
	'sick' => 0,
	'good' => 0,
	'bad' => 0,
	'shit' => 0,
	'miss' => 0,
	'score' => 0,
	'accuracy' => 0.0
];

function onSongEnd(e) {
	if (!e.cancelled) {
		e.cancel();
		FlxG.save.data.resultsShit = data;

		endingSong = true;
		canPause = false;

		for (strumLine in strumLines.members) strumLine.vocals.stop();
		inst.stop();
		vocals.stop();

		if (validScore) {
			#if !switch
			FunkinSave.setSongHighscore(PlayState.SONG.meta.name, PlayState.difficulty, PlayState.variation, {
				score: songScore,
				misses: misses,
				accuracy: accuracy,
				hits: [],
				date: Date.now().toString()
			}, PlayState.getSongChanges());
			#end
		}

		startCutscene("end-", endCutscene, checkShit, false, false);
	}
}


function checkShit() {
	nextSong();

	if (!PlayState.isStoryMode) {
		data['score'] = songScore;
		data['miss'] = misses;
		data['accuracy'] = accuracy;
	} else {
		data['score'] = PlayState.campaignScore;
		data['miss'] = PlayState.campaignMisses;
		data['accuracy'] = PlayState.campaignAccuracy;
	}

	if (!PlayState.chartingMode && (PlayState.isStoryMode ? PlayState.storyPlaylist.length <= 0 : true)) {
		MusicBeatState.skipTransIn = MusicBeatState.skipTransOut = false;
		FlxG.save.data.resultsShit = null;
		FlxG.switchState(new ModState('ResultsState', data));
	}
}

function onPostNoteHit(e) {
	if (!e.note.isSustainNote && e.player && !e.cancelled) {
		data[e.rating] += 1;
		data['total'] += 1;
		data['max'] = Math.max(data['max'], combo);
		// trace(data);
	}
}

function onPlayerMiss(e) {
	if (!e.cancelled && (e.note != null && !e.note.avoid)) {
		data['miss'] += 1;
		// trace(data);
	}
}

function postCreate() {
	if (FlxG.save.data.compact) {
		for (i in [missesTxt, accuracyTxt]) {
			i.visible = i.active = i.alive = i.exists = false;
		}
	}
	comboRatings = [
		new ComboRating(0.00, 'L', 0xff0099ff),
		new ComboRating(0.69, 'G', 0xffef6644),
		new ComboRating(0.80, 'G', 0xffaaaaaa),
		new ComboRating(0.90, 'E', 0xffffcc44),
		new ComboRating(0.99, 'P', 0xffff66ee),
		new ComboRating(1.00, 'P', 0xffffffcc),
	];
	scripts.remove(__script__);
	scripts.insert(scripts.scripts.length, __script__);

	if (PlayState.isStoryMode) {
		if (PlayState.storyPlaylist.length != PlayState.storyWeek.songs.length) {
			for (n => v in FlxG.save.data.resultsShit) {
				data[n] = v;
			}
		} else {
			for (n => v in data) {
				data[n] = 0;
			}
		}
	}
}
